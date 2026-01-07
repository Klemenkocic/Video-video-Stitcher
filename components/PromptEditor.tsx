'use client';

type PromptEditorProps = {
  value: string;
  onChange: (value: string) => void;
  onReset: () => void;
  isModified: boolean;
};

export default function PromptEditor({
  value,
  onChange,
  onReset,
  isModified,
}: PromptEditorProps) {
  return (
    <div className="rounded-2xl border border-[var(--border)] bg-white p-4 shadow-sm">
      <div className="flex items-center justify-between mb-2">
        <label className="text-sm font-semibold text-[var(--text)]">
          Describe the shot
        </label>
        {isModified && (
          <button
            type="button"
            onClick={onReset}
            className="text-sm text-[var(--accent)] hover:text-[var(--accent-hover)]"
          >
            Reset to default
          </button>
        )}
      </div>
      <textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="w-full min-h-[120px] resize-y rounded-xl border border-[var(--border)] bg-[var(--background)] p-3 text-[var(--text)] outline-none focus:ring-2 focus:ring-[var(--accent)]"
        placeholder="Tell the AI how to move between locations..."
      />
    </div>
  );
}
