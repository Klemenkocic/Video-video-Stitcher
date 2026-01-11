
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

// Initialize configuration
const FAL_KEY = Deno.env.get('FAL_KEY') ?? '';
const FAL_ENDPOINT = 'fal-ai/kling-video/v2.5-turbo/pro/image-to-video';

console.log("Fal Proxy Function Initialized");

serve(async (req) => {
    // CORS setup
    const corsHeaders = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    }

    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { action, prompt, imageUrl, tailImageUrl, requestId } = await req.json()

        // 1. GENERATE
        if (action === 'generate') {
            if (!imageUrl || !prompt) {
                throw new Error('Missing required fields');
            }

            const response = await fetch(`https://queue.fal.run/${FAL_ENDPOINT}`, {
                method: 'POST',
                headers: {
                    'Authorization': `Key ${FAL_KEY}`,
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    prompt: prompt,
                    image_url: imageUrl,
                    tail_image_url: tailImageUrl,
                    duration: '5',
                    negative_prompt: 'blur, distort, and low quality, watermarks, text',
                    cfg_scale: 0.5,
                }),
            });

            const data = await response.json();
            return new Response(JSON.stringify(data), {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: response.status,
            });
        }

        // 2. CHECK STATUS
        if (action === 'check_status') {
            if (!requestId) throw new Error('Missing requestId');

            const response = await fetch(`https://queue.fal.run/${FAL_ENDPOINT}/requests/${requestId}`, {
                method: 'GET',
                headers: {
                    'Authorization': `Key ${FAL_KEY}`,
                    'Content-Type': 'application/json',
                },
            });

            const data = await response.json();
            return new Response(JSON.stringify(data), {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: response.status,
            });
        }

        throw new Error(`Unknown action: ${action}`);

    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400,
        })
    }
})
