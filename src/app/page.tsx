import Link from "next/link";
import { Briefcase, Terminal, Gamepad2, FlaskConical, Github, Linkedin, Cpu } from "lucide-react";

export default function Home() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-[#0d1117] text-[#c9d1d9] p-4 font-[family-name:var(--font-geist-sans)] selection:bg-[#58a6ff] selection:text-white">
      <main className="flex flex-col items-center gap-8 text-center max-w-5xl w-full">

        {/* Header Section */}
        <header className="space-y-4 animate-fade-in">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#161b22] border border-[#30363d] text-xs font-mono text-[#8b949e]">
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
            </span>
            SYSTEM ONLINE
          </div>
          <h1 className="text-5xl md:text-7xl font-bold tracking-tight text-white">
            Kelvin B. Ward
          </h1>
          <p className="text-lg md:text-xl text-[#8b949e] max-w-2xl mx-auto">
            Federated System Hub
          </p>
        </header>

        {/* Bento Grid Command Center */}
        <div className="grid grid-cols-1 md:grid-cols-6 gap-4 w-full h-full md:h-[500px] animate-fade-in [animation-delay:150ms]">

          {/* PROFESSIONAL HUB - Large Card (Span 4) */}
          <a
            href="/resume/index.html"
            className="group relative md:col-span-4 rounded-2xl border border-[#30363d] bg-[#161b22] p-8 flex flex-col justify-between overflow-hidden hover:border-orange-500/50 transition-all duration-300"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-orange-500/10 to-amber-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500" />

            <div className="relative z-10 flex items-start justify-between">
              <div className="p-3 rounded-lg bg-orange-500/10 text-orange-400 group-hover:text-orange-300 group-hover:bg-orange-500/20 transition-colors">
                <Briefcase size={32} />
              </div>
              <div className="px-3 py-1 rounded-full bg-[#0d1117] border border-[#30363d] text-xs text-[#8b949e] font-mono">
                PRO_ZONE
              </div>
            </div>

            <div className="relative z-10 text-left mt-8">
              <h2 className="text-3xl font-bold text-white mb-2 group-hover:text-orange-400 transition-colors">
                Professional Resume
              </h2>
              <p className="text-[#8b949e] mb-6 max-w-md group-hover:text-[#c9d1d9] transition-colors">
                Full-Stack Engineering & Technical Leadership.
                Specializing in ServiceNow, Enterprise Architecture, and Storage.
              </p>

              <div className="flex gap-2">
                <span className="px-2 py-1 rounded text-xs bg-[#0d1117] border border-[#30363d] text-orange-400/80">AI Enthusiast & Enthusiast of All Things Tech.</span>
              </div>
            </div>
          </a>

          {/* CREATIVE HUB (GOOBFACE) - Tall Card (Span 2) */}
          <a
            href="https://www.goobface.com"
            target="_blank"
            rel="noopener noreferrer"
            className="group relative md:col-span-2 md:row-span-2 rounded-2xl border border-[#30363d] bg-[#161b22] p-6 flex flex-col justify-between overflow-hidden hover:border-green-500/50 transition-all duration-300"
          >
            <div className="absolute inset-0 bg-[url('/grid.svg')] opacity-10" />
            <div className="absolute inset-0 bg-gradient-to-b from-green-500/5 to-emerald-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500" />

            <div className="relative z-10 flex items-center justify-between">
              <div className="p-3 rounded-lg bg-green-500/10 text-green-400 group-hover:bg-green-500/20 transition-colors">
                <Gamepad2 size={28} />
              </div>
              <div className="text-right">
                <span className="block text-xs font-mono text-green-500/50 group-hover:text-green-400 transition-colors">STATUS: CHAOS</span>
              </div>
            </div>

            <div className="relative z-10 text-left mt-auto">
              <h2 className="text-2xl font-bold text-white mb-2 group-hover:text-green-400 transition-colors tracking-tight">
                GOOBFACE
              </h2>
              <p className="text-[#8b949e] text-sm mb-4 leading-relaxed group-hover:text-[#c9d1d9]">
                Personal Sandbox. Game Dev, 3D Printing, and creative experiments.
              </p>
              <div className="w-full h-1 bg-[#30363d] rounded-full overflow-hidden">
                <div className="h-full bg-green-500 w-2/3 group-hover:w-full transition-all duration-700 ease-out" />
              </div>
            </div>
          </a>

          {/* ENGINEERING BLOG - Medium Card (Span 4) */}
          <Link
            href="/blog"
            className="group relative md:col-span-2 rounded-2xl border border-[#30363d] bg-[#161b22] p-6 flex flex-col justify-between overflow-hidden hover:border-[#58a6ff]/50 transition-all duration-300"
          >
            <div className="absolute inset-0 bg-gradient-to-tr from-[#58a6ff]/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />

            <div className="relative z-10 flex items-center gap-3 mb-4">
              <Terminal size={24} className="text-[#8b949e] group-hover:text-[#58a6ff] transition-colors" />
              <span className="text-sm font-mono text-[#8b949e]">/var/log/engineering</span>
            </div>

            <div className="relative z-10 text-left">
              <h3 className="text-lg font-semibold text-white group-hover:text-[#58a6ff] transition-colors">
                Engineering Blog
              </h3>
              <p className="text-xs text-[#8b949e] mt-2">
                Latest: One Week, Three Architectures
              </p>
            </div>
          </Link>

          {/* EXPERIMENTS (LAB) - Small Card (Span 2) */}
          <a
            href="https://kelvinbward.github.io/creativeAudioJS"
            target="_blank"
            rel="noopener noreferrer"
            className="group relative md:col-span-2 rounded-2xl border border-[#30363d] bg-[#161b22] p-6 flex flex-col justify-between overflow-hidden hover:border-purple-500/50 transition-all duration-300"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-purple-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />

            <div className="relative z-10 flex items-center justify-between mb-2">
              <FlaskConical size={24} className="text-[#8b949e] group-hover:text-purple-400 transition-colors" />
              <Cpu size={16} className="text-[#8b949e]/50" />
            </div>

            <div className="relative z-10 text-left">
              <h3 className="text-lg font-semibold text-white group-hover:text-purple-400 transition-colors">
                The Lab
              </h3>
              <p className="text-xs text-[#8b949e] mt-1">
                Audio Synthesis & JS Experiments
              </p>
            </div>
          </a>

        </div>

        {/* Footer Links */}
        <footer className="flex gap-6 mt-8 animate-fade-in [animation-delay:300ms]">
          <a href="https://github.com/kelvinbward" target="_blank" rel="noopener noreferrer" aria-label="GitHub" className="text-[#8b949e] hover:text-white transition-colors">
            <Github size={20} />
          </a>
          <a href="https://linkedin.com/in/kelvinbward" target="_blank" rel="noopener noreferrer" aria-label="LinkedIn" className="text-[#8b949e] hover:text-[#0a66c2] transition-colors">
            <Linkedin size={20} />
          </a>
        </footer>

      </main>
    </div>
  );
}
