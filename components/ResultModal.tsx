'use client';

type ResultModalProps = {
  videoUrl: string;
  onClose: () => void;
  onCreateAnother: () => void;
};

export default function ResultModal({
  videoUrl,
  onClose,
  onCreateAnother,
}: ResultModalProps) {
  if (!videoUrl) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="relative w-full max-w-3xl rounded-2xl bg-white p-6 shadow-2xl">
        <button
          className="absolute right-4 top-4 h-9 w-9 rounded-full bg-[var(--background)] text-lg text-[var(--text)] hover:bg-[#f0e8df]"
          onClick={onClose}
          aria-label="Close"
        >
          ×
        </button>
        <div className="overflow-hidden rounded-xl border border-[var(--border)]">
          <video
            src={videoUrl}
            controls
            autoPlay
            muted
            playsInline
            className="w-full"
          />
        </div>
        <div className="mt-4 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-end">
          <a
            href={videoUrl}
            download
            className="inline-flex items-center justify-center rounded-full border border-[var(--border)] px-5 py-3 text-[var(--text)] hover:bg-[var(--background)]"
          >
            Download MP4
          </a>
          <button
            onClick={onCreateAnother}
            className="inline-flex items-center justify-center rounded-full bg-[var(--accent)] px-5 py-3 font-semibold text-white hover:bg-[var(--accent-hover)]"
          >
            Create Another
          </button>
        </div>
      </div>
    </div>
  );
}
