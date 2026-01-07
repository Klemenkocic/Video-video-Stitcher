"use client";

import { useEffect, useState } from "react";
import Header from "@/components/Header";
import InstructionsSidebar from "@/components/InstructionsSidebar";
import LocationBlock from "@/components/LocationBlock";
import PromptEditor from "@/components/PromptEditor";
import GenerateButton from "@/components/GenerateButton";
import LoadingOverlay from "@/components/LoadingOverlay";
import ResultModal from "@/components/ResultModal";
import ErrorToast from "@/components/ErrorToast";
import MainCanvas from "@/components/MainCanvas";
import { DEFAULT_PROMPT } from "@/lib/constants";
import type { UploadedImage } from "@/lib/types";

const MAX_RETRIES = 2;

const getUserFriendlyError = (error: string): string => {
  const lower = error.toLowerCase();
  if (lower.includes("timeout")) {
    return "The request took too long. Please try again.";
  }
  if (lower.includes("rate limit")) {
    return "Too many requests. Please wait a moment and try again.";
  }
  if (lower.includes("invalid image") || lower.includes("image")) {
    return "There was a problem with your images. Try different photos.";
  }
  return "Something went wrong. Please try again.";
};

export default function Home() {
  const [firstImage, setFirstImage] = useState<UploadedImage | null>(null);
  const [secondImage, setSecondImage] = useState<UploadedImage | null>(null);
  const [isUploadingFirst, setIsUploadingFirst] = useState(false);
  const [isUploadingSecond, setIsUploadingSecond] = useState(false);

  const [prompt, setPrompt] = useState(DEFAULT_PROMPT);
  const isPromptModified = prompt !== DEFAULT_PROMPT;

  const [isGenerating, setIsGenerating] = useState(false);
  const [videoUrl, setVideoUrl] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [retryCount, setRetryCount] = useState(0);

  const canGenerate = Boolean(firstImage?.url && secondImage?.url);

  useEffect(() => {
    return () => {
      if (firstImage?.preview) URL.revokeObjectURL(firstImage.preview);
      if (secondImage?.preview) URL.revokeObjectURL(secondImage.preview);
    };
  }, [firstImage?.preview, secondImage?.preview]);

  const handleUpload = async (
    file: File,
    setImage: typeof setFirstImage,
    setIsUploading: typeof setIsUploadingFirst
  ) => {
    setIsUploading(true);
    setError(null);
    try {
      const preview = URL.createObjectURL(file);
      const formData = new FormData();
      formData.append("file", file);

      const res = await fetch("/api/upload", {
        method: "POST",
        body: formData,
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || "Upload failed");
      }

      setImage((prev) => {
        if (prev?.preview) URL.revokeObjectURL(prev.preview);
        return {
          url: data.url,
          preview,
          name: file.name,
        };
      });
    } catch (err: unknown) {
      const message =
        err instanceof Error ? err.message : "Failed to upload image";
      setError(getUserFriendlyError(message));
    } finally {
      setIsUploading(false);
    }
  };

  const handleRemove = (
    image: UploadedImage | null,
    setImage: typeof setFirstImage
  ) => {
    if (image?.preview) {
      URL.revokeObjectURL(image.preview);
    }
    setImage(null);
  };

  const handleGenerate = async () => {
    if (!canGenerate || isGenerating) return;
    setIsGenerating(true);
    setError(null);
    try {
      const res = await fetch("/api/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          startImageUrl: firstImage!.url,
          endImageUrl: secondImage!.url,
          prompt,
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || "Generation failed");
      }

      setVideoUrl(data.videoUrl);
      setRetryCount(0);
    } catch (err: unknown) {
      const message =
        err instanceof Error ? err.message : "Failed to create your memory";
      setError(getUserFriendlyError(message));
    } finally {
      setIsGenerating(false);
    }
  };

  const handleReset = () => {
    if (firstImage?.preview) URL.revokeObjectURL(firstImage.preview);
    if (secondImage?.preview) URL.revokeObjectURL(secondImage.preview);
    setFirstImage(null);
    setSecondImage(null);
    setPrompt(DEFAULT_PROMPT);
    setVideoUrl(null);
    setError(null);
    setRetryCount(0);
  };

  const handleRetry = () => {
    if (retryCount < MAX_RETRIES) {
      setRetryCount((count) => count + 1);
      setError(null);
      handleGenerate();
    } else {
      setError(
        "Still having trouble. Please try different images or try again later."
      );
    }
  };

  return (
    <div className="min-h-screen bg-[var(--background)] text-[var(--text)]">
      <div className="mx-auto flex max-w-6xl flex-col gap-6 px-4 pb-10 pt-4">
        <Header />
        <div className="flex flex-col gap-6 lg:flex-row">
          <MainCanvas>
            <div className="rounded-3xl border border-[var(--border)] bg-white p-4 shadow-sm lg:p-6">
              <LocationBlock
                label="Where it begins"
                image={firstImage}
                onUpload={(file) =>
                  handleUpload(file, setFirstImage, setIsUploadingFirst)
                }
                onRemove={() => handleRemove(firstImage, setFirstImage)}
                isUploading={isUploadingFirst}
              />

              <div className="my-6">
                <PromptEditor
                  value={prompt}
                  onChange={setPrompt}
                  onReset={() => setPrompt(DEFAULT_PROMPT)}
                  isModified={isPromptModified}
                />
              </div>

              <LocationBlock
                label="Where it ends"
                image={secondImage}
                onUpload={(file) =>
                  handleUpload(file, setSecondImage, setIsUploadingSecond)
                }
                onRemove={() => handleRemove(secondImage, setSecondImage)}
                isUploading={isUploadingSecond}
              />
            </div>
          </MainCanvas>

          <InstructionsSidebar />
        </div>

        <div className="lg:w-[65%]">
          <GenerateButton
            canGenerate={canGenerate}
            isGenerating={isGenerating}
            onClick={handleGenerate}
          />
        </div>
      </div>

      <LoadingOverlay isVisible={isGenerating} />

      {videoUrl && (
        <ResultModal
          videoUrl={videoUrl}
          onClose={() => setVideoUrl(null)}
          onCreateAnother={handleReset}
        />
      )}

      {error && (
        <ErrorToast
          message={error}
          onDismiss={() => setError(null)}
          onRetry={handleRetry}
        />
      )}
    </div>
  );
}
