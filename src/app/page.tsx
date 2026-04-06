import Link from "next/link";
import { Briefcase, Terminal, Gamepad2, FlaskConical, Github, Linkedin, Cpu } from "lucide-react";

export default function Home() {
  return (
    <div className="min-h-screen flex items-center justify-center p-4 sm:p-8 bg-surface text-text font-[family-name:var(--font-geist-sans)] selection:bg-accent-blue selection:bg-opacity-30">
      <main className="flex flex-col items-center gap-8 text-center max-w-5xl w-full">

        {/* Header Section */}
        <header className="space-y-4 animate-fade-in">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-surface-raised border-border text-xs font-mono text-text-muted">
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
            </span>
            SYSTEM ONLINE
          </div>
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-extrabold tracking-tight text-text-white mb-4 animate-fade-in">
            Kelvin B. Ward
          </h1>
          <p className="text-xl md:text-2xl text-text-muted max-w-2xl mx-auto leading-relaxed animate-slide-up [animation-delay:100ms]">
            Federated System Hub
          </p>
        </header>

        {/* Bento Grid Command Center */}
        <div className="grid grid-cols-1 md:grid-cols-6 gap-4 w-full h-full md:h-[500px] animate-fade-in [animation-delay:150ms]">

          {/* PROFESSIONAL HUB - Large Card (Span 4) */}
          <a
            href="/resume/index.html"
            className="group relative md:col-span-4 rounded-2xl border border-border bg-surface-raised p-8 flex flex-col justify-between overflow-hidden hover:border-orange-500/50 transition-all duration-300"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-orange-500/10 to-amber-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500" />

            <div className="relative z-10 flex items-start justify-between">
              <div className="p-3 rounded-lg bg-orange-500/10 text-orange-400 group-hover:text-orange-300 group-hover:bg-orange-500/20 transition-colors">
                <Briefcase size={32} />
              </div>
              <div className="px-3 py-1 rounded-full bg-surface border border-border text-xs text-text-muted font-mono">
                PRO_ZONE
              </div>
            </div>

            <div className="relative z-10 text-left mt-8">
              <h2 className="text-3xl font-bold text-text-white mb-2 group-hover:text-orange-400 transition-colors">
                Professional Resume
              </h2>
              <p className="text-text-muted mb-6 max-w-md group-hover:text-text transition-colors">
                Full-Stack Engineering & Technical Leadership.
                Specializing in ServiceNow, Enterprise Architecture, and Storage.
              </p>

              <div className="flex gap-2">
                <span className="px-2 py-1 rounded text-xs bg-surface border border-border text-orange-400/80">AI Enthusiast & Enthusiast of All Things Tech.</span>
              </div>
            </div>
          </a>

          {/* CREATIVE HUB (GOOBFACE) - Tall Card (Span 2) */}
          <a
            href="https://www.goobface.com"
            target="_blank"
            rel="noopener noreferrer"
            className="group relative md:col-span-2 md:row-span-2 rounded-2xl border border-border bg-surface-raised p-6 flex flex-col justify-between overflow-hidden hover:border-green-500/50 transition-all duration-300"
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
              <h2 className="text-2xl font-bold text-text-white mb-2 group-hover:text-green-400 transition-colors tracking-tight">
                GOOBFACE
              </h2>
              <p className="text-text-muted text-sm mb-4 leading-relaxed group-hover:text-text">
                Personal Sandbox. Game Dev, 3D Printing, and creative experiments.
              </p>
              <div className="w-full h-1 bg-border rounded-full overflow-hidden">
                <div className="h-full bg-green-500 w-2/3 group-hover:w-full transition-all duration-700 ease-out" />
              </div>
            </div>
          </a>

          {/* ENGINEERING BLOG - Medium Card (Span 4) */}
          <Link
            href="/blog"
            className="group relative md:col-span-2 rounded-2xl border border-border bg-surface-raised p-6 flex flex-col justify-between overflow-hidden hover:border-accent-blue/50 transition-all duration-300"
          >
            <div className="absolute inset-0 bg-gradient-to-tr from-accent-blue/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />

            <div className="relative z-10 flex items-center gap-3 mb-4">
              <Terminal size={24} className="text-text-muted group-hover:text-accent-blue transition-colors" />
              <span className="text-sm font-mono text-text-muted">/var/log/engineering</span>
            </div>

            <div className="relative z-10 text-left">
              <h3 className="text-lg font-semibold text-text-white group-hover:text-accent-blue transition-colors">
                Engineering Blog
              </h3>
              <p className="text-xs text-text-muted mt-2">
                Latest: One Week, Three Architectures
              </p>
            </div>
          </Link>

          {/* EXPERIMENTS (LAB) - Small Card (Span 2) */}
          <a
            href="https://kelvinbward.github.io/creativeAudioJS"
            target="_blank"
            rel="noopener noreferrer"
            className="group relative md:col-span-2 rounded-2xl border border-border bg-surface-raised p-6 flex flex-col justify-between overflow-hidden hover:border-purple-500/50 transition-all duration-300"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-purple-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />

            <div className="relative z-10 flex items-center justify-between mb-2">
              <FlaskConical size={24} className="text-text-muted group-hover:text-purple-400 transition-colors" />
              <Cpu size={16} className="text-text-muted/50" />
            </div>

            <div className="relative z-10 text-left">
              <h3 className="text-lg font-semibold text-text-white group-hover:text-purple-400 transition-colors">
                The Lab
              </h3>
              <p className="text-xs text-text-muted mt-1">
                Audio Synthesis & JS Experiments
              </p>
            </div>
          </a>

        </div>

        {/* Footer Links */}
        <footer className="flex gap-6 mt-8 animate-fade-in [animation-delay:300ms]">
          <a href="https://github.com/kelvinbward" target="_blank" rel="noopener noreferrer" aria-label="GitHub" className="text-text-muted hover:text-text-white transition-colors">
            <Github size={20} />
          </a>
          <a href="https://linkedin.com/in/kelvinbward" target="_blank" rel="noopener noreferrer" aria-label="LinkedIn" className="text-text-muted hover:text-[#0a66c2] transition-colors">
            <Linkedin size={20} />
          </a>
        </footer>

      </main>
    </div>
  );
}
