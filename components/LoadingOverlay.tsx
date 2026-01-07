'use client';

import { useEffect, useState } from "react";
import { LOADING_MESSAGES } from "@/lib/constants";

type LoadingOverlayProps = {
  isVisible: boolean;
};

export default function LoadingOverlay({ isVisible }: LoadingOverlayProps) {
  const [messageIndex, setMessageIndex] = useState(0);

  useEffect(() => {
    if (!isVisible) return;
    const interval = setInterval(() => {
      setMessageIndex((prev) => (prev + 1) % LOADING_MESSAGES.length);
    }, 3000);
    return () => clearInterval(interval);
  }, [isVisible]);

  if (!isVisible) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm">
      <div className="flex flex-col items-center gap-4 rounded-2xl bg-white px-8 py-6 shadow-xl">
        <div className="h-12 w-12 animate-spin rounded-full border-4 border-[var(--accent)] border-t-transparent" />
        <p className="text-lg font-semibold text-[var(--text)]">
          {LOADING_MESSAGES[messageIndex]}
        </p>
        <p className="text-sm text-[var(--text-subtle)]">
          This usually takes 1-2 minutes
        </p>
      </div>
    </div>
  );
}
