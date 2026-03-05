import Link from 'next/link'

export default function NotFound() {
    return (
        <div className="flex min-h-screen flex-col items-center justify-center bg-surface text-text p-4 font-[family-name:var(--font-geist-sans)]">
            <div className="text-center space-y-6">
                <h1 className="text-6xl font-bold text-text-muted">404</h1>
                <h2 className="text-2xl font-semibold text-white">Zone Not Found</h2>
                <p className="text-text-muted max-w-md mx-auto">
                    The requested page could not be found.
                </p>
                <div className="pt-8">
                    <Link href="/" className="px-6 py-3 rounded-md bg-[#238636] text-white font-medium hover:bg-[#2ea043] transition-colors">
                        Return to Hub
                    </Link>
                </div>
            </div>
        </div>
    )
}
