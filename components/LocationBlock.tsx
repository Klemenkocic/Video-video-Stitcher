'use client';

import {
  ChangeEvent,
  DragEvent,
  KeyboardEvent,
  useCallback,
  useRef,
  useState,
} from "react";
import Image from "next/image";
import { ALLOWED_FILE_TYPES, MAX_FILE_SIZE_MB } from "@/lib/constants";
import type { UploadedImage } from "@/lib/types";

type LocationBlockProps = {
  label: "Where it begins" | "Where it ends";
  image: UploadedImage | null;
  onUpload: (file: File) => Promise<void>;
  onRemove: () => void;
  isUploading: boolean;
};

const dashedStyles =
  "border-2 border-dashed border-[var(--border)] hover:border-[var(--accent)]";

export default function LocationBlock({
  label,
  image,
  onUpload,
  onRemove,
  isUploading,
}: LocationBlockProps) {
  const inputRef = useRef<HTMLInputElement | null>(null);
  const [isDragging, setIsDragging] = useState(false);
  const [localError, setLocalError] = useState<string | null>(null);

  const validateFile = (file: File) => {
    if (!ALLOWED_FILE_TYPES.includes(file.type)) {
      return "Please use a JPG, PNG, or WebP image";
    }
    const sizeMb = file.size / (1024 * 1024);
    if (sizeMb > MAX_FILE_SIZE_MB) {
      return `Image must be under ${MAX_FILE_SIZE_MB}MB`;
    }
    return null;
  };

  const handleFile = useCallback(
    async (file: File | null) => {
      if (!file) return;
      const validationError = validateFile(file);
      if (validationError) {
        setLocalError(validationError);
        return;
      }
      setLocalError(null);
      await onUpload(file);
    },
    [onUpload]
  );

  const handleInputChange = async (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0] ?? null;
    await handleFile(file);
    // Reset input so selecting the same file again still triggers change
    if (inputRef.current) {
      inputRef.current.value = "";
    }
  };

  const handleDrop = async (event: DragEvent<HTMLDivElement>) => {
    event.preventDefault();
    setIsDragging(false);
    const file = event.dataTransfer.files?.[0] ?? null;
    await handleFile(file);
  };

  const commonContainerClasses =
    "relative rounded-2xl overflow-hidden transition border bg-white shadow-sm";

  return (
    <div className="flex flex-col gap-2">
      <div
        className={`${commonContainerClasses} ${
          image ? "border-[var(--border)]" : dashedStyles
        } ${isDragging ? "border-[var(--accent)] bg-[#fff7f1]" : ""}`}
        onDragOver={(e) => {
          e.preventDefault();
          setIsDragging(true);
        }}
        onDragLeave={() => setIsDragging(false)}
        onDrop={handleDrop}
        onClick={() => inputRef.current?.click()}
        role="button"
        tabIndex={0}
        aria-label={`Upload ${label.toLowerCase()}`}
        onKeyDown={(e: KeyboardEvent<HTMLDivElement>) => {
          if (e.key === "Enter" || e.key === " ") {
            e.preventDefault();
            inputRef.current?.click();
          }
        }}
      >
        <input
          ref={inputRef}
          type="file"
          accept={ALLOWED_FILE_TYPES.join(",")}
          className="hidden"
          onChange={handleInputChange}
        />

        <div className="aspect-[16/9] w-full">
          {image ? (
            <div className="relative h-full w-full">
              <Image
                src={image.preview}
                alt={image.name}
                fill
                unoptimized
                className="object-cover"
              />
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  onRemove();
                }}
                className="absolute right-3 top-3 h-8 w-8 rounded-full bg-white shadow-md text-[var(--text)] hover:bg-[#f5eee6] border border-[var(--border)]"
                aria-label="Remove image"
              >
                ×
              </button>
            </div>
          ) : (
            <div className="flex h-full w-full flex-col items-center justify-center gap-3 bg-[var(--background)]">
              <div className="flex h-12 w-12 items-center justify-center rounded-full border border-[var(--border)] bg-white text-[var(--text-subtle)]">
                <span className="text-2xl">↑</span>
              </div>
              <div className="text-center">
                <p className="font-medium text-[var(--text)]">
                  Click or drag to upload
                </p>
                <p className="text-sm text-[var(--text-subtle)]">
                  JPG, PNG, or WebP up to {MAX_FILE_SIZE_MB}MB
                </p>
              </div>
            </div>
          )}
        </div>

        {isUploading && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/40 backdrop-blur-sm">
            <div className="h-12 w-12 animate-spin rounded-full border-4 border-white border-t-transparent" />
          </div>
        )}
      </div>

      <div className="flex items-center justify-between">
        <span className="text-sm font-medium text-[var(--text)]">{label}</span>
        {image && (
          <span className="text-xs text-[var(--text-subtle)]">{image.name}</span>
        )}
      </div>

      {localError && (
        <p className="text-sm text-[var(--error)]" role="alert">
          {localError}
        </p>
      )}
    </div>
  );
}
