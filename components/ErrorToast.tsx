'use client';

import { useEffect } from "react";

type ErrorToastProps = {
  message: string;
  onDismiss: () => void;
  onRetry: () => void;
};

export default function ErrorToast({
  message,
  onDismiss,
  onRetry,
}: ErrorToastProps) {
  useEffect(() => {
    if (!message) return;
    const timer = setTimeout(() => {
      onDismiss();
    }, 10000);
    return () => clearTimeout(timer);
  }, [message, onDismiss]);

  if (!message) return null;

  return (
    <div className="fixed bottom-6 right-6 z-50 max-w-sm rounded-xl border border-[var(--border)] bg-white p-4 shadow-lg">
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="font-semibold text-[var(--text)]">Something went wrong</p>
          <p className="text-sm text-[var(--text-subtle)]">{message}</p>
        </div>
        <button
          onClick={onDismiss}
          aria-label="Dismiss error"
          className="text-lg text-[var(--text-subtle)] hover:text-[var(--text)]"
        >
          ×
        </button>
      </div>
      <div className="mt-3 flex gap-2">
        <button
          onClick={onRetry}
          className="rounded-full bg-[var(--accent)] px-4 py-2 text-sm font-semibold text-white hover:bg-[var(--accent-hover)]"
        >
          Try Again
        </button>
        <button
          onClick={onDismiss}
          className="rounded-full border border-[var(--border)] px-4 py-2 text-sm text-[var(--text)] hover:bg-[var(--background)]"
        >
          Dismiss
        </button>
      </div>
    </div>
  );
}
