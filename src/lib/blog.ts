import fs from 'fs'
import path from 'path'
import matter from 'gray-matter'

const postsDirectory = path.join(process.cwd(), 'src/content/blog')

export type Post = {
    slug: string
    meta: {
        title: string
        date: string
        description: string
        [key: string]: unknown
    }
    content: string
}

export function getAllPosts(): Post[] {
    // Ensure directory exists
    if (!fs.existsSync(postsDirectory)) {
        return []
    }

    const fileNames = fs.readdirSync(postsDirectory)
    const allPostsData = fileNames.filter(fileName => fileName.endsWith('.mdx')).map((fileName) => {
        const slug = fileName.replace(/\.mdx$/, '')
        const fullPath = path.join(postsDirectory, fileName)
        const fileContents = fs.readFileSync(fullPath, 'utf8')
        const { data, content } = matter(fileContents)

        return {
            slug,
            meta: data as Post['meta'],
            content,
        }
    })

    // Sort posts by date
    return allPostsData.sort((a, b) => {
        if (a.meta.date < b.meta.date) {
            return 1
        } else {
            return -1
        }
    })
}

export function getPostBySlug(slug: string): Post | null {
    const fullPath = path.join(postsDirectory, `${slug}.mdx`)

    if (!fs.existsSync(fullPath)) {
        return null
    }

    const fileContents = fs.readFileSync(fullPath, 'utf8')
    const { data, content } = matter(fileContents)

    return {
        slug,
        meta: data as Post['meta'],
        content,
    }
}
