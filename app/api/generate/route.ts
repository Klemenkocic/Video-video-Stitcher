import { fal } from "@fal-ai/client";
import { NEGATIVE_PROMPT } from "@/lib/constants";

fal.config({
  credentials: process.env.FAL_KEY,
});

export async function POST(request: Request) {
  try {
    const { startImageUrl, endImageUrl, prompt } = await request.json();

    if (!startImageUrl || !endImageUrl) {
      return Response.json(
        { error: "Both location images are required" },
        { status: 400 }
      );
    }

    const basePrompt =
      "Cinematic drone shot transition between @Image1 and @Image2.";
    const finalPrompt =
      prompt && prompt.trim().length > 0 ? prompt : basePrompt;

    const result = await fal.subscribe(
      "fal-ai/kling-video/o1/image-to-video",
      {
        input: {
          prompt: finalPrompt,
          // @ts-expect-error - negative_prompt is supported by the API but missing from types
          negative_prompt: NEGATIVE_PROMPT,
          start_image_url: startImageUrl,
          end_image_url: endImageUrl,
          duration: "5",
        },
        logs: true,
        onQueueUpdate: (update) => {
          if (update.status === "IN_PROGRESS") {
            console.log("Generation in progress...");
          }
        },
      }
    );

    const videoUrl = result.data?.video?.url;

    if (!videoUrl) {
      console.error("Unexpected response structure:", result.data);
      throw new Error("No video URL in response");
    }

    return Response.json({ videoUrl });
  } catch (error: unknown) {
    console.error("Generation failed:", error);
    return Response.json(
      { error: "Failed to create your memory. Please try again." },
      { status: 500 }
    );
  }
}
