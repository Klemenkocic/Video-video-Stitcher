'use client';

type GenerateButtonProps = {
  canGenerate: boolean;
  isGenerating: boolean;
  onClick: () => void;
};

export default function GenerateButton({
  canGenerate,
  isGenerating,
  onClick,
}: GenerateButtonProps) {
  const disabled = !canGenerate || isGenerating;
  const label = !canGenerate
    ? "Upload both photos"
    : isGenerating
      ? "Creating..."
      : "✨ Create My Memory";

  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      className={`w-full rounded-full px-8 py-4 text-lg font-semibold transition shadow-sm ${
        disabled
          ? "bg-[#e7e2dc] text-[var(--text-subtle)] cursor-not-allowed"
          : "bg-[var(--accent)] text-white hover:bg-[var(--accent-hover)] hover:shadow-md"
      }`}
    >
      {label}
    </button>
  );
}
