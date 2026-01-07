const listClasses = "text-sm leading-relaxed text-[var(--text)]";

export default function InstructionsSidebar() {
  return (
    <aside className="w-full lg:w-[35%] max-w-[320px] rounded-2xl border border-[var(--border)] bg-white p-6 shadow-sm">
      <h2 className="text-lg font-semibold mb-4 text-[var(--text)]">
        How it works
      </h2>
      <ol className="space-y-4 text-[var(--text)]">
        <li className={listClasses}>
          <div className="font-medium">1. Upload your first location photo</div>
          <p className="text-[var(--text-subtle)]">
            The starting point of your journey
          </p>
        </li>
        <li className={listClasses}>
          <div className="font-medium">2. Describe the shot (optional)</div>
          <p className="text-[var(--text-subtle)]">
            Tell the AI how to move between locations
          </p>
        </li>
        <li className={listClasses}>
          <div className="font-medium">3. Upload your second location photo</div>
          <p className="text-[var(--text-subtle)]">The destination</p>
        </li>
        <li className={listClasses}>
          <div className="font-medium">4. Click &quot;Create My Memory&quot;</div>
          <p className="text-[var(--text-subtle)]">Takes about 1-2 minutes</p>
        </li>
      </ol>

      <div className="my-6 border-t border-[var(--border)]" />

      <h3 className="text-lg font-semibold mb-3 text-[var(--text)]">Tips</h3>
      <ul className="space-y-2 text-sm text-[var(--text-subtle)]">
        <li>• Landscape photos work best</li>
        <li>• Outdoor scenes — cities, beaches, mountains</li>
        <li>• Similar lighting in both photos helps</li>
        <li>• Min 300×300px, max 10MB per image</li>
      </ul>
    </aside>
  );
}
