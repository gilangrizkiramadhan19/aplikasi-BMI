import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import Link from 'next/link'

export default function NotFound() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-slate-100 flex items-center justify-center px-4">
      <Card className="w-full max-w-md shadow-xl border-0 text-center">
        <div className="p-12">
          <div className="text-6xl font-bold text-slate-900 mb-4">404</div>
          <h1 className="text-2xl font-bold text-slate-900 mb-3">Halaman Tidak Ditemukan</h1>
          <p className="text-slate-600 mb-8">
            Maaf, halaman yang Anda cari tidak tersedia atau telah dipindahkan.
          </p>

          <div className="space-y-3">
            <Button asChild className="w-full bg-blue-600 hover:bg-blue-700">
              <Link href="/dashboard">Kembali ke Dashboard</Link>
            </Button>
            <Button asChild variant="outline" className="w-full border-slate-300">
              <Link href="/">Halaman Utama</Link>
            </Button>
          </div>
        </div>
      </Card>
    </div>
  )
}
