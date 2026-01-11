
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

        // 1. Create a Customer (Optional, simplified for this demo)
        // In a real app, you'd check if the user already has a stripe_customer_id in your DB
        // and reuse it. For now, we create an ephemeral setup for the sheet.

        // 2. Create an Ephemeral Key
        // We need a customer ID for this. Let's create a guest customer or use a hardcoded one for testing.
        // Ideally, pass the user's email from the auth context.

        // For specific PaymentSheet flow:
        // https://stripe.com/docs/payments/accept-a-payment?platform=web&ui=payment-sheet

        // Let's create a customer for this session
        const customer = await stripe.customers.create()
        const ephemeralKey = await stripe.ephemeralKeys.create(
            { customer: customer.id },
            { apiVersion: '2022-11-15' }
        )

        // 3. Create the PaymentIntent
        // Amount should be in cents (e.g. 1000 = $10.00)

        // Extract user token from Authorization header (Bearer TOKEN)
        const authHeader = req.headers.get('Authorization')
        const token = authHeader?.replace('Bearer ', '')

        // Get user ID from Supabase Auth (safe way)
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? '',
            { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
        )
        const { data: { user } } = await supabaseClient.auth.getUser()

        const paymentIntent = await stripe.paymentIntents.create({
            amount: amount,
            currency: currency,
            customer: customer.id,
            metadata: {
                user_id: user?.id // Pass verified user ID
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
                customer: customer.id,
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
