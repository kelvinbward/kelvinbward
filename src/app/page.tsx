

export default function Home() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-[#0d1117] text-[#c9d1d9] p-4 font-[family-name:var(--font-geist-sans)]">
      <main className="flex flex-col items-center gap-12 text-center max-w-4xl w-full">

        <header className="space-y-4">
          <h1 className="text-5xl font-bold tracking-tight text-white">Kelvin B. Ward</h1>
          <p className="text-lg text-[#8b949e]">
            System Hub & Digital Portfolio
          </p>
        </header>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 w-full px-4 md:px-0">
          {/* Professional Hub Card */}
          <a
            href="/resume/"
            className="group flex flex-col items-start p-8 rounded-xl border border-[#30363d] bg-[#161b22] hover:bg-[#21262d] hover:border-[#8b949e] transition-all duration-200 shadow-lg text-left"
          >
            <h2 className="text-2xl font-semibold text-white mb-2 group-hover:text-[#58a6ff] transition-colors">
              Professional Hub &rarr;
            </h2>
            <p className="text-[#8b949e] mb-4">
              Full-Stack Engineering, Systems Architecture, and Technical Leadership.
            </p>
            <ul className="text-sm text-[#8b949e] opacity-70 list-disc list-inside space-y-1">
              <li>Interactive Resume</li>
              <li>Architecture Blog</li>
              <li>Case Studies</li>
            </ul>
          </a>

          {/* Personal Sandbox Card */}
          <a
            href="https://www.goobface.com"
            target="_blank"
            rel="noopener noreferrer"
            className="group flex flex-col items-start p-8 rounded-xl border border-[#30363d] bg-[#161b22] hover:bg-[#21262d] hover:border-[#e2b340] transition-all duration-200 shadow-lg text-left"
          >
            <h2 className="text-2xl font-semibold text-white mb-2 group-hover:text-[#e2b340] transition-colors">
              Personal Sandbox &rarr;
            </h2>
            <p className="text-[#8b949e] mb-4">
              A creative outlet for Game Development, 3D Printing, and Generative Audio.
            </p>
            <ul className="text-sm text-[#8b949e] opacity-70 list-disc list-inside space-y-1">
              <li>Goobface (Games)</li>
              <li>Creative Audio Experiments</li>
              <li>Maker Blog</li>
            </ul>
          </a>
        </div>

        <footer className="mt-12 text-sm text-[#8b949e] opacity-50">
          <p>Federated Architecture • Next.js • Astro • Vue.js</p>
        </footer>
      </main>
    </div>
  );
}
