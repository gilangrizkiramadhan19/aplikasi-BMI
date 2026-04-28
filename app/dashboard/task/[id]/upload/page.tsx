'use client'

import { useState, useRef } from 'react'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Textarea } from '@/components/ui/textarea'
import { ArrowLeft, Camera, ImagePlus, Upload, X } from 'lucide-react'
import Link from 'next/link'
import { toast } from 'sonner'
import Image from 'next/image'

interface UploadedImage {
  id: string
  url: string
  name: string
  size: number
}

export default function UploadEvidencePage({ params }: { params: { id: string } }) {
  const [images, setImages] = useState<UploadedImage[]>([])
  const [notes, setNotes] = useState('')
  const [loading, setLoading] = useState(false)
  const [dragActive, setDragActive] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleDrag = (e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
    if (e.type === 'dragenter' || e.type === 'dragover') {
      setDragActive(true)
    } else if (e.type === 'dragleave') {
      setDragActive(false)
    }
  }

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
    setDragActive(false)

    const files = e.dataTransfer.files
    if (files) {
      handleFiles(files)
    }
  }

  const handleFiles = (files: FileList) => {
    Array.from(files).forEach((file) => {
      if (file.type.startsWith('image/')) {
        const reader = new FileReader()
        reader.onload = (e) => {
          const newImage: UploadedImage = {
            id: Math.random().toString(36),
            url: e.target?.result as string,
            name: file.name,
            size: file.size,
          }
          setImages((prev) => [...prev, newImage])
          toast.success(`Foto "${file.name}" berhasil diunggah`)
        }
        reader.readAsDataURL(file)
      } else {
        toast.error('Hanya file gambar yang didukung')
      }
    })
  }

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      handleFiles(e.target.files)
    }
  }

  const removeImage = (id: string) => {
    setImages((prev) => prev.filter((img) => img.id !== id))
    toast.info('Foto dihapus')
  }

  const handleSubmit = async () => {
    if (images.length === 0) {
      toast.error('Silakan upload minimal 1 foto')
      return
    }

    if (notes.trim().length === 0) {
      toast.error('Silakan isi catatan pekerjaan')
      return
    }

    setLoading(true)
    setTimeout(() => {
      setLoading(false)
      toast.success('Bukti pekerjaan berhasil diunggah!')
      setTimeout(() => {
        window.location.href = `/dashboard/task/${params.id}`
      }, 1000)
    }, 1500)
  }

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-white border-b border-slate-200 shadow-sm">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <Link
            href={`/dashboard/task/${params.id}`}
            className="flex items-center gap-2 text-blue-600 hover:text-blue-700 font-medium transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
            Kembali ke Detail Tugas
          </Link>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-slate-900 mb-2">Upload Bukti Pekerjaan</h1>
          <p className="text-slate-600">
            Dokumentasikan pekerjaan Anda dengan foto dan catatan untuk verifikasi
          </p>
        </div>

        {/* Upload Area */}
        <Card className="border-2 border-dashed border-slate-300 p-8 mb-8">
          <div
            onDragEnter={handleDrag}
            onDragLeave={handleDrag}
            onDragOver={handleDrag}
            onDrop={handleDrop}
            className={`transition-all ${dragActive ? 'bg-blue-50 border-blue-400' : ''}`}
          >
            <div className="text-center">
              <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-blue-100 mb-4">
                <ImagePlus className="w-8 h-8 text-blue-600" />
              </div>

              <h2 className="text-lg font-semibold text-slate-900 mb-2">Seret foto ke sini</h2>
              <p className="text-slate-600 mb-6">atau</p>

              <input
                ref={fileInputRef}
                type="file"
                multiple
                accept="image/*"
                onChange={handleFileChange}
                className="hidden"
              />

              <div className="flex gap-3 justify-center flex-wrap">
                <Button
                  type="button"
                  onClick={() => fileInputRef.current?.click()}
                  className="gap-2 bg-blue-600 hover:bg-blue-700 text-white"
                >
                  <ImagePlus className="w-5 h-5" />
                  Pilih dari Galeri
                </Button>

                <Button
                  type="button"
                  variant="outline"
                  className="gap-2 border-slate-300 text-slate-700 hover:bg-slate-50"
                  onClick={() => fileInputRef.current?.click()}
                >
                  <Camera className="w-5 h-5" />
                  Buka Kamera
                </Button>
              </div>

              <p className="text-xs text-slate-500 mt-4">
                Format: JPG, PNG (max 5MB per file)
              </p>
            </div>
          </div>
        </Card>

        {/* Uploaded Images */}
        {images.length > 0 && (
          <Card className="p-6 mb-8 border-slate-200">
            <h3 className="font-semibold text-slate-900 mb-4">
              Foto Terupload ({images.length})
            </h3>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {images.map((image) => (
                <div
                  key={image.id}
                  className="relative rounded-lg overflow-hidden border border-slate-200 group"
                >
                  <div className="aspect-square relative bg-slate-100">
                    <Image
                      src={image.url}
                      alt={image.name}
                      fill
                      className="object-cover group-hover:scale-105 transition-transform duration-200"
                    />
                  </div>

                  {/* Delete Button */}
                  <button
                    onClick={() => removeImage(image.id)}
                    className="absolute top-2 right-2 p-2 bg-red-600 hover:bg-red-700 text-white rounded-full opacity-0 group-hover:opacity-100 transition-opacity"
                  >
                    <X className="w-4 h-4" />
                  </button>

                  {/* Image Info */}
                  <div className="p-3 bg-slate-50 border-t border-slate-200">
                    <p className="text-xs font-medium text-slate-900 truncate">
                      {image.name}
                    </p>
                    <p className="text-xs text-slate-500">
                      {(image.size / 1024).toFixed(0)} KB
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </Card>
        )}

        {/* Notes Section */}
        <Card className="p-6 mb-8 border-slate-200">
          <h3 className="font-semibold text-slate-900 mb-4">Catatan Pekerjaan</h3>

          <div className="space-y-3">
            <label htmlFor="notes" className="block text-sm font-medium text-slate-700">
              Jelaskan pekerjaan yang telah dilakukan
            </label>
            <Textarea
              id="notes"
              placeholder="Contoh: Telah mengganti oli mesin, membersihkan filter, dan melakukan test run. Semua dalam kondisi normal."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              className="min-h-32 bg-slate-50 border-slate-200 rounded-lg resize-none focus-visible:ring-blue-500"
            />
            <p className="text-xs text-slate-500">
              Catatan minimal 20 karakter
            </p>
          </div>
        </Card>

        {/* Action Buttons */}
        <div className="flex gap-4">
          <Button
            onClick={handleSubmit}
            disabled={loading || images.length === 0 || notes.trim().length < 20}
            className="flex-1 h-12 bg-green-600 hover:bg-green-700 text-white font-semibold rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? (
              <>
                <span className="inline-block animate-spin mr-2">⟳</span>
                Mengunggah...
              </>
            ) : (
              <>
                <Upload className="w-5 h-5 mr-2" />
                Submit Bukti Pekerjaan
              </>
            )}
          </Button>

          <Button
            variant="outline"
            className="h-12 border-slate-300 text-slate-600 hover:bg-slate-100 font-semibold rounded-lg"
            asChild
          >
            <Link href={`/dashboard/task/${params.id}`}>Batal</Link>
          </Button>
        </div>

        {/* Info Box */}
        <div className="mt-8 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <h4 className="font-semibold text-blue-900 mb-2">💡 Tips Upload Foto</h4>
          <ul className="text-sm text-blue-800 space-y-1">
            <li>• Pastikan pencahayaan cukup untuk hasil foto yang jelas</li>
            <li>• Ambil minimal 2-3 sudut berbeda dari pekerjaan yang diselesaikan</li>
            <li>• Pastikan komponen/mesin terlihat dengan jelas di foto</li>
            <li>• Catatan harus menjelaskan detail apa yang telah dikerjakan</li>
          </ul>
        </div>
      </main>
    </div>
  )
}
