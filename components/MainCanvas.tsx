type MainCanvasProps = {
  children: React.ReactNode;
};

export default function MainCanvas({ children }: MainCanvasProps) {
  return (
    <section className="w-full lg:w-[65%] flex flex-col gap-4">
      {children}
    </section>
  );
}
