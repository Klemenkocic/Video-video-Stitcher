
// Follow this setup guide to integrate the Deno runtime into your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This function creates a Stripe PaymentIntent and returns the client secret

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { Stripe } from "https://esm.sh/stripe@11.1.0?target=deno"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') ?? '', {
    // This is needed to use the Fetch API rather than Node's http client
    httpClient: Stripe.createFetchHttpClient(),
})

console.log("Payment Sheet Function Initialized")

serve(async (req) => {
    // CORS headers
    const corsHeaders = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    }

    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { amount, currency = 'eur' } = await req.json()

        // 1. Get user from Supabase Auth
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? '',
            { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
        )
        const { data: { user } } = await supabaseClient.auth.getUser()

        if (!user) throw new Error('User not authenticated');

        // 2. Check for existing customer ID
        const { data: profile } = await supabaseClient
            .from('profiles')
            .select('stripe_customer_id')
            .eq('id', user.id)
            .single()

        let customerId = profile?.stripe_customer_id

        // 3. Create Customer if needed
        if (!customerId) {
            const customer = await stripe.customers.create({
                email: user.email,
                metadata: { supabase_uid: user.id }
            })
            customerId = customer.id

            // Update profile
            await supabaseClient
                .from('profiles')
                .update({ stripe_customer_id: customerId })
                .eq('id', user.id)
        }

        // 4. Create Ephemeral Key
        const ephemeralKey = await stripe.ephemeralKeys.create(
            { customer: customerId },
            { apiVersion: '2022-11-15' }
        )

        // 5. Create PaymentIntent
        const paymentIntent = await stripe.paymentIntents.create({
            amount: amount,
            currency: currency,
            customer: customerId,
            metadata: {
                user_id: user.id
            },
            automatic_payment_methods: {
                enabled: true,
            },
        })

        // 4. Return the secrets to the client
        return new Response(
            JSON.stringify({
                paymentIntent: paymentIntent.client_secret,
                ephemeralKey: ephemeralKey.secret,
                customer: customerId,
                publishableKey: Deno.env.get('STRIPE_PUBLISHABLE_KEY'),
            }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 200,
            }
        )
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400,
        })
    }
})
