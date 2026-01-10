import { getPostBySlug, getAllPosts } from '@/lib/blog'
import { MDXRemote } from 'next-mdx-remote/rsc'
import Link from 'next/link'
import { notFound } from 'next/navigation'

export async function generateStaticParams() {
    const posts = getAllPosts()
    return posts.map((post) => ({
        slug: post.slug,
    }))
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) {
    const { slug } = await params
    const post = getPostBySlug(slug)
    if (!post) {
        return {
            title: 'Post Not Found',
        }
    }
    return {
        title: `${post.meta.title} | Kelvin B. Ward`,
        description: post.meta.description,
    }
}

export default async function BlogPost({ params }: { params: Promise<{ slug: string }> }) {
    const { slug } = await params
    const post = getPostBySlug(slug)

    if (!post) {
        notFound()
    }

    return (
        <div className="min-h-screen bg-[#0d1117] text-[#c9d1d9] p-8 font-[family-name:var(--font-geist-sans)]">
            <main className="max-w-3xl mx-auto">
                <Link href="/blog" className="text-[#58a6ff] hover:underline mb-8 inline-block">&larr; Back to Blog</Link>

                <article className="prose prose-invert max-w-none">
                    <header className="mb-8 border-b border-[#30363d] pb-8">
                        <h1 className="text-3xl font-bold text-white mb-2">{post.meta.title}</h1>
                        <time className="text-[#8b949e] text-sm">{post.meta.date}</time>
                    </header>

                    <MDXRemote source={post.content} />
                </article>
            </main>
        </div>
    )
}
