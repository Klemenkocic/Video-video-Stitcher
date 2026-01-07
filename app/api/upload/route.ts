import { fal } from "@fal-ai/client";

fal.config({
  credentials: process.env.FAL_KEY,
});

const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
const ALLOWED_TYPES = ["image/jpeg", "image/png", "image/webp"];

export async function POST(request: Request) {
  try {
    const formData = await request.formData();
    const file = formData.get("file") as File;

    if (!file) {
      return Response.json({ error: "No file provided" }, { status: 400 });
    }

    if (!ALLOWED_TYPES.includes(file.type)) {
      return Response.json(
        { error: "Please use a JPG, PNG, or WebP image" },
        { status: 400 }
      );
    }

    if (file.size > MAX_FILE_SIZE) {
      return Response.json(
        { error: "Image must be under 10MB" },
        { status: 400 }
      );
    }

    const url = await fal.storage.upload(file);

    return Response.json({ url });
  } catch (error) {
    console.error("Upload failed:", error);
    return Response.json(
      { error: "Failed to upload image. Please try again." },
      { status: 500 }
    );
  }
}
