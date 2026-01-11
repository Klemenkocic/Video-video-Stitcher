import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { Stripe } from "https://esm.sh/stripe@11.1.0?target=deno"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

console.log("Stripe Webhook Handler Initialized")

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') ?? '', {
    httpClient: Stripe.createFetchHttpClient(),
})

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''

const supabase = createClient(supabaseUrl, supabaseServiceKey)

serve(async (req) => {
    const signature = req.headers.get('stripe-signature')

    if (!signature) {
        return new Response('No signature', { status: 400 })
    }

    const body = await req.text()

    try {
        const event = stripe.webhooks.constructEvent(
            body,
            signature,
            Deno.env.get('STRIPE_WEBHOOK_SECRET') ?? ''
        )

        console.log(`Event received: ${event.type}`)

        // Handle payment_intent.succeeded event
        if (event.type === 'payment_intent.succeeded') {
            const paymentIntent = event.data.object

            // Calculate credits: 100 cents = 10 credits (10 cents per credit)
            const amountInCents = paymentIntent.amount
            const credits = Math.floor(amountInCents / 10)

            // Get user ID from metadata
            const userId = paymentIntent.metadata.user_id

            if (userId) {
                console.log(`Adding ${credits} credits to user ${userId} for payment ${paymentIntent.id}`)

                // Use admin RPC function to add credits (bypasses auth.uid())
                const { error } = await supabase.rpc('top_up_credits_admin', {
                    user_id_param: userId,
                    amount_param: credits,
                    description_param: `Stripe Payment: ${paymentIntent.id}`
                })

                if (error) {
                    console.error('Error adding credits:', error)
                    return new Response(
                        JSON.stringify({ error: 'Failed to add credits' }),
                        { headers: { 'Content-Type': 'application/json' }, status: 500 }
                    )
                }

                console.log(`Successfully added ${credits} credits`)
            } else {
                console.error('No user_id in payment metadata')
                return new Response(
                    JSON.stringify({ error: 'No user_id in payment metadata' }),
                    { headers: { 'Content-Type': 'application/json' }, status: 400 }
                )
            }
        }

        return new Response(JSON.stringify({ received: true }), {
            headers: { 'Content-Type': 'application/json' },
            status: 200
        })
    } catch (err) {
        console.error(`Webhook Error: ${err.message}`)
        return new Response(JSON.stringify({ error: err.message }), {
            headers: { 'Content-Type': 'application/json' },
            status: 400
        })
    }
})
