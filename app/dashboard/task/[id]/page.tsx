'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { ArrowLeft, Calendar, MapPin, Wrench, CheckCircle, Clock, AlertCircle } from 'lucide-react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import Image from 'next/image'
import { toast } from 'sonner'

interface TaskDetail {
  id: string
  title: string
  description: string
  machine: string
  location: string
  status: 'pending' | 'in-progress' | 'completed'
  priority: 'high' | 'medium' | 'low'
  date: string
  dueDate: string
  assignedTo: string
  createdBy: string
  estimatedTime: string
}

const mockTaskDetail: TaskDetail = {
  id: '1',
  title: 'Perawatan Mesin Produksi',
  description:
    'Melakukan perawatan rutin dan pengecekan komponen mesin produksi untuk memastikan performa optimal. Termasuk pembersihan, penggantian oli, dan inspeksi sistem kelistrikan.',
  machine: 'CNC Machine A-01',
  location: 'Lantai 3, Area Produksi',
  status: 'pending',
  priority: 'high',
  date: '2024-04-28',
  dueDate: '2024-05-02',
  assignedTo: 'Teknisi Bambang',
  createdBy: 'Supervisor Ahmad',
  estimatedTime: '4 jam',
}

function getStatusConfig(status: TaskDetail['status']) {
  const config = {
    pending: { label: 'Menunggu', color: 'bg-amber-100 text-amber-800 border-amber-300', icon: Clock },
    'in-progress': { label: 'Sedang Dikerjakan', color: 'bg-blue-100 text-blue-800 border-blue-300', icon: Wrench },
    completed: { label: 'Selesai', color: 'bg-green-100 text-green-800 border-green-300', icon: CheckCircle },
  }
  return config[status]
}

function getPriorityConfig(priority: TaskDetail['priority']) {
  const config = {
    high: {
      label: 'Prioritas Tinggi',
      color: 'bg-red-100 text-red-800 border-red-300',
      icon: AlertCircle,
      description: 'Urgent - Selesaikan segera',
    },
    medium: {
      label: 'Prioritas Sedang',
      color: 'bg-amber-100 text-amber-800 border-amber-300',
      description: 'Normal - Selesaikan sesuai jadwal',
    },
    low: {
      label: 'Prioritas Rendah',
      color: 'bg-green-100 text-green-800 border-green-300',
      description: 'Rendah - Fleksibel',
    },
  }
  return config[priority]
}

export default function TaskDetailPage({ params }: { params: { id: string } }) {
  const [status, setStatus] = useState<TaskDetail['status']>(mockTaskDetail.status)
  const [loading, setLoading] = useState(false)
  const router = useRouter()

  const statusConfig = getStatusConfig(status)
  const priorityConfig = getPriorityConfig(mockTaskDetail.priority)
  const StatusIcon = statusConfig.icon
  const PriorityIcon = priorityConfig.icon

  const handleAcceptTask = () => {
    setLoading(true)
    setTimeout(() => {
      setStatus('in-progress')
      setLoading(false)
      toast.success('Tugas berhasil diambil! Status diubah ke "Sedang Dikerjakan"')
    }, 800)
  }

  const handleCompleteTask = () => {
    setLoading(true)
    setTimeout(() => {
      setStatus('completed')
      setLoading(false)
      toast.success('Tugas berhasil diselesaikan!')
    }, 800)
  }

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-white border-b border-slate-200 shadow-sm">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <Link
              href="/dashboard"
              className="flex items-center gap-2 text-blue-600 hover:text-blue-700 font-medium transition-colors"
            >
              <ArrowLeft className="w-5 h-5" />
              Kembali ke Dashboard
            </Link>
            <div className="flex items-center gap-3">
              <div className="relative w-8 h-8">
                <Image src="/logo-bmi.png" alt="BMI Logo" fill className="object-contain" />
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Title Section */}
        <div className="mb-8">
          <div className="flex items-start justify-between gap-4 mb-4">
            <div className="flex-1">
              <h1 className="text-3xl font-bold text-slate-900 mb-3">{mockTaskDetail.title}</h1>
              <p className="text-slate-600">{mockTaskDetail.description}</p>
            </div>
          </div>
        </div>

        {/* Status and Priority Badges */}
        <div className="grid grid-cols-2 gap-4 mb-8">
          <Card className="p-5 border-slate-200">
            <div className="flex items-center gap-3 mb-2">
              <StatusIcon className="w-5 h-5" style={{ color: status === 'completed' ? '#10b981' : status === 'in-progress' ? '#3b82f6' : '#f59e0b' }} />
              <span className="text-sm text-slate-600 font-medium">Status Tugas</span>
            </div>
            <Badge className={`border ${statusConfig.color}`}>{statusConfig.label}</Badge>
          </Card>

          <Card className="p-5 border-slate-200">
            <div className="flex items-center gap-3 mb-2">
              <PriorityIcon className="w-5 h-5 text-red-600" />
              <span className="text-sm text-slate-600 font-medium">Prioritas</span>
            </div>
            <div>
              <Badge className={`border ${priorityConfig.color}`}>{priorityConfig.label}</Badge>
              <p className="text-xs text-slate-500 mt-2">{priorityConfig.description}</p>
            </div>
          </Card>
        </div>

        {/* Details Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          {/* Machine Info */}
          <Card className="p-6 border-slate-200">
            <div className="flex items-start gap-3 mb-6">
              <div className="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center">
                <Wrench className="w-5 h-5 text-blue-600" />
              </div>
              <div className="flex-1">
                <h3 className="text-sm text-slate-600 font-medium mb-1">Mesin / Peralatan</h3>
                <p className="text-lg font-bold text-slate-900">{mockTaskDetail.machine}</p>
              </div>
            </div>

            <div className="space-y-4">
              <div>
                <label className="text-xs text-slate-600 font-medium">Lokasi</label>
                <div className="flex items-center gap-2 mt-1">
                  <MapPin className="w-4 h-4 text-slate-400" />
                  <span className="text-slate-800">{mockTaskDetail.location}</span>
                </div>
              </div>

              <div>
                <label className="text-xs text-slate-600 font-medium">Estimasi Waktu</label>
                <p className="text-slate-800 mt-1">{mockTaskDetail.estimatedTime}</p>
              </div>
            </div>
          </Card>

          {/* Timeline Info */}
          <Card className="p-6 border-slate-200">
            <div className="space-y-5">
              <div>
                <label className="text-xs text-slate-600 font-medium">Tanggal Dibuat</label>
                <div className="flex items-center gap-2 mt-2">
                  <Calendar className="w-4 h-4 text-slate-400" />
                  <span className="text-slate-800">{new Date(mockTaskDetail.date).toLocaleDateString('id-ID', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</span>
                </div>
              </div>

              <div>
                <label className="text-xs text-slate-600 font-medium">Target Selesai</label>
                <div className="flex items-center gap-2 mt-2">
                  <Calendar className="w-4 h-4 text-red-400" />
                  <span className="text-slate-800 font-medium">{new Date(mockTaskDetail.dueDate).toLocaleDateString('id-ID', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</span>
                </div>
              </div>
            </div>
          </Card>
        </div>

        {/* Assignment Info */}
        <Card className="p-6 border-slate-200 mb-8">
          <h3 className="font-bold text-slate-900 mb-4">Informasi Penugasan</h3>
          <div className="grid grid-cols-2 gap-6">
            <div>
              <label className="text-xs text-slate-600 font-medium block mb-2">Ditugaskan Kepada</label>
              <p className="text-slate-900 font-medium">{mockTaskDetail.assignedTo}</p>
            </div>
            <div>
              <label className="text-xs text-slate-600 font-medium block mb-2">Dibuat Oleh</label>
              <p className="text-slate-900 font-medium">{mockTaskDetail.createdBy}</p>
            </div>
          </div>
        </Card>

        {/* Action Buttons */}
        <div className="flex gap-4">
          {status === 'pending' && (
            <Button
              onClick={handleAcceptTask}
              disabled={loading}
              className="flex-1 h-12 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-lg transition-colors"
            >
              {loading ? 'Menerima Tugas...' : 'Ambil Tugas'}
            </Button>
          )}

          {status === 'in-progress' && (
            <Button
              onClick={handleCompleteTask}
              disabled={loading}
              className="flex-1 h-12 bg-green-600 hover:bg-green-700 text-white font-semibold rounded-lg transition-colors"
            >
              {loading ? 'Menyelesaikan...' : 'Selesaikan Tugas'}
            </Button>
          )}

          {status === 'in-progress' && (
            <Link href={`/dashboard/task/${params.id}/upload`} className="flex-1">
              <Button className="w-full h-12 bg-slate-600 hover:bg-slate-700 text-white font-semibold rounded-lg transition-colors">
                Upload Bukti Foto
              </Button>
            </Link>
          )}

          {status === 'completed' && (
            <Button disabled className="flex-1 h-12 bg-slate-300 text-slate-600 font-semibold rounded-lg">
              ✓ Tugas Selesai
            </Button>
          )}

          <Button
            variant="outline"
            className="h-12 border-slate-300 text-slate-600 hover:bg-slate-100 font-semibold rounded-lg"
            asChild
          >
            <Link href="/dashboard">Kembali</Link>
          </Button>
        </div>
      </main>
    </div>
  )
}
