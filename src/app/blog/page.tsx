import { getAllPosts } from '@/lib/blog'
import Link from 'next/link'

export const metadata = {
    title: 'Blog | Kelvin B. Ward',
    description: 'Architectural musings and engineering notes.',
}

export default function BlogIndex() {
    const posts = getAllPosts()

    return (
        <div className="min-h-screen bg-[#0d1117] text-[#c9d1d9] p-8 font-[family-name:var(--font-geist-sans)]">
            <main className="max-w-3xl mx-auto">
                <header className="mb-12">
                    <Link href="/" className="text-[#58a6ff] hover:underline mb-4 inline-block">&larr; Back to Hub</Link>
                    <h1 className="text-4xl font-bold text-white mb-2">Engineering Log</h1>
                    <p className="text-[#8b949e]">Notes on architecture, systems, and federation.</p>
                </header>

                <section className="space-y-8">
                    {posts.map((post) => (
                        <article key={post.slug} className="group border border-[#30363d] rounded-lg p-6 bg-[#161b22] hover:border-[#8b949e] transition-colors">
                            <Link href={`/blog/${post.slug}`}>
                                <div className="flex justify-between items-start mb-2">
                                    <h2 className="text-xl font-semibold text-white group-hover:text-[#58a6ff] transition-colors">
                                        {post.meta.title}
                                    </h2>
                                    <time className="text-sm text-[#8b949e] whitespace-nowrap ml-4">{post.meta.date}</time>
                                </div>
                                <p className="text-[#8b949e]">{post.meta.description}</p>
                            </Link>
                        </article>
                    ))}
                </section>
            </main>
        </div>
    )
}
