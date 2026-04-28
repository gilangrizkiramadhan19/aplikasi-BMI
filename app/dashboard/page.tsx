'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { MapPin, Clock, Wrench, Plus, LogOut } from 'lucide-react'
import Link from 'next/link'
import Image from 'next/image'

interface Task {
  id: string
  title: string
  machine: string
  location: string
  status: 'pending' | 'in-progress' | 'completed' | 'archived'
  date: string
  priority: 'high' | 'medium' | 'low'
}

const mockTasks: Task[] = [
  {
    id: '1',
    title: 'Perawatan Mesin Produksi',
    machine: 'CNC Machine A-01',
    location: 'Lantai 3',
    status: 'pending',
    date: '2024-04-28',
    priority: 'high',
  },
  {
    id: '2',
    title: 'Perbaikan Conveyor Belt',
    machine: 'Conveyor System B-02',
    location: 'Gudang',
    status: 'in-progress',
    date: '2024-04-27',
    priority: 'medium',
  },
  {
    id: '3',
    title: 'Penggantian Oli Mesin',
    machine: 'Hydraulic Pump C-03',
    location: 'Lantai 2',
    status: 'completed',
    date: '2024-04-26',
    priority: 'low',
  },
  {
    id: '4',
    title: 'Inspeksi Rutin Kompressor',
    machine: 'Air Compressor D-04',
    location: 'Ruang Teknis',
    status: 'pending',
    date: '2024-04-25',
    priority: 'medium',
  },
  {
    id: '5',
    title: 'Sertifikasi Peralatan',
    machine: 'Electrical Panel E-05',
    location: 'Pusat Kontrol',
    status: 'archived',
    date: '2024-04-20',
    priority: 'high',
  },
]

function getStatusBadge(status: Task['status']) {
  const config = {
    pending: { label: 'Menunggu', color: 'bg-amber-100 text-amber-800 border-amber-300' },
    'in-progress': { label: 'Diproses', color: 'bg-blue-100 text-blue-800 border-blue-300' },
    completed: { label: 'Selesai', color: 'bg-green-100 text-green-800 border-green-300' },
    archived: { label: 'Arsip', color: 'bg-slate-100 text-slate-800 border-slate-300' },
  }
  return config[status]
}

function getPriorityColor(priority: Task['priority']) {
  const colors = {
    high: 'text-red-600 bg-red-50',
    medium: 'text-amber-600 bg-amber-50',
    low: 'text-green-600 bg-green-50',
  }
  return colors[priority]
}

function TaskCard({ task }: { task: Task }) {
  const statusConfig = getStatusBadge(task.status)
  const priorityColor = getPriorityColor(task.priority)

  return (
    <Link href={`/dashboard/task/${task.id}`}>
      <Card className="p-5 hover:shadow-lg transition-all duration-200 cursor-pointer border-slate-200 bg-white">
        <div className="flex justify-between items-start mb-3">
          <h3 className="text-base font-semibold text-slate-900 flex-1 line-clamp-2">
            {task.title}
          </h3>
          <Badge variant="outline" className={statusConfig.color}>
            {statusConfig.label}
          </Badge>
        </div>

        <div className="space-y-2 mb-4">
          <div className="flex items-center gap-2 text-sm text-slate-600">
            <Wrench className="w-4 h-4 text-blue-600" />
            <span className="font-medium">{task.machine}</span>
          </div>
          <div className="flex items-center gap-2 text-sm text-slate-600">
            <MapPin className="w-4 h-4 text-slate-400" />
            <span>{task.location}</span>
          </div>
          <div className="flex items-center gap-2 text-sm text-slate-600">
            <Clock className="w-4 h-4 text-slate-400" />
            <span>{new Date(task.date).toLocaleDateString('id-ID')}</span>
          </div>
        </div>

        <div className="flex items-center justify-between">
          <span className={`text-xs font-semibold px-2 py-1 rounded-md ${priorityColor}`}>
            {task.priority === 'high' ? 'Prioritas Tinggi' : task.priority === 'medium' ? 'Prioritas Sedang' : 'Prioritas Rendah'}
          </span>
          <Button variant="ghost" size="sm" className="text-blue-600 hover:bg-blue-50">
            Detail →
          </Button>
        </div>
      </Card>
    </Link>
  )
}

export default function DashboardPage() {
  const [activeTab, setActiveTab] = useState('pending')

  const filteredTasks = mockTasks.filter((task) => {
    if (activeTab === 'all') return true
    return task.status === activeTab
  })

  const stats = {
    pending: mockTasks.filter((t) => t.status === 'pending').length,
    inProgress: mockTasks.filter((t) => t.status === 'in-progress').length,
    completed: mockTasks.filter((t) => t.status === 'completed').length,
  }

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-white border-b border-slate-200 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="relative w-10 h-10">
                <Image
                  src="/logo-bmi.png"
                  alt="BMI Logo"
                  fill
                  className="object-contain"
                />
              </div>
              <div>
                <h1 className="text-xl font-bold text-slate-900">Dashboard Teknisi</h1>
                <p className="text-xs text-slate-500">Bumi Menara Internusa</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Button
                variant="outline"
                size="sm"
                className="gap-2 border-blue-200 text-blue-600 hover:bg-blue-50"
                asChild
              >
                <Link href="/dashboard/task/new">
                  <Plus className="w-4 h-4" />
                  Tugas Baru
                </Link>
              </Button>
              <Button
                variant="ghost"
                size="sm"
                className="gap-2 text-slate-600 hover:text-slate-900"
                onClick={() => (window.location.href = '/')}
              >
                <LogOut className="w-4 h-4" />
                Keluar
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
          <Card className="p-6 border-l-4 border-l-amber-500 bg-gradient-to-br from-amber-50 to-white">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-600 mb-1">Menunggu Dikerjakan</p>
                <p className="text-3xl font-bold text-amber-600">{stats.pending}</p>
              </div>
              <div className="w-12 h-12 rounded-lg bg-amber-100 flex items-center justify-center">
                <Clock className="w-6 h-6 text-amber-600" />
              </div>
            </div>
          </Card>

          <Card className="p-6 border-l-4 border-l-blue-500 bg-gradient-to-br from-blue-50 to-white">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-600 mb-1">Sedang Dikerjakan</p>
                <p className="text-3xl font-bold text-blue-600">{stats.inProgress}</p>
              </div>
              <div className="w-12 h-12 rounded-lg bg-blue-100 flex items-center justify-center">
                <Wrench className="w-6 h-6 text-blue-600" />
              </div>
            </div>
          </Card>

          <Card className="p-6 border-l-4 border-l-green-500 bg-gradient-to-br from-green-50 to-white">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-600 mb-1">Sudah Selesai</p>
                <p className="text-3xl font-bold text-green-600">{stats.completed}</p>
              </div>
              <div className="w-12 h-12 rounded-lg bg-green-100 flex items-center justify-center">
                <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                </svg>
              </div>
            </div>
          </Card>
        </div>

        {/* Tasks Section */}
        <Card className="border-slate-200 overflow-hidden">
          <div className="p-6 border-b border-slate-200">
            <h2 className="text-xl font-bold text-slate-900">Daftar Tugas Maintenance</h2>
          </div>

          <div className="px-6 pt-6">
            <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
              <TabsList className="grid w-full grid-cols-4 bg-slate-100 p-1 rounded-lg">
                <TabsTrigger value="pending" className="rounded-md data-[state=active]:bg-white data-[state=active]:text-blue-600">
                  Menunggu
                  <span className="ml-2 px-2 py-0.5 bg-amber-100 text-amber-700 text-xs rounded-full font-semibold">
                    {stats.pending}
                  </span>
                </TabsTrigger>
                <TabsTrigger value="in-progress" className="rounded-md data-[state=active]:bg-white data-[state=active]:text-blue-600">
                  Diproses
                  <span className="ml-2 px-2 py-0.5 bg-blue-100 text-blue-700 text-xs rounded-full font-semibold">
                    {stats.inProgress}
                  </span>
                </TabsTrigger>
                <TabsTrigger value="completed" className="rounded-md data-[state=active]:bg-white data-[state=active]:text-blue-600">
                  Selesai
                  <span className="ml-2 px-2 py-0.5 bg-green-100 text-green-700 text-xs rounded-full font-semibold">
                    {stats.completed}
                  </span>
                </TabsTrigger>
                <TabsTrigger value="archived" className="rounded-md data-[state=active]:bg-white data-[state=active]:text-blue-600">
                  Arsip
                </TabsTrigger>
              </TabsList>

              <div className="mt-6 space-y-4 pb-6">
                {filteredTasks.length > 0 ? (
                  filteredTasks.map((task) => <TaskCard key={task.id} task={task} />)
                ) : (
                  <div className="text-center py-12">
                    <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-slate-100 mb-4">
                      <Wrench className="w-8 h-8 text-slate-400" />
                    </div>
                    <p className="text-slate-600 font-medium">Tidak ada tugas</p>
                    <p className="text-sm text-slate-500">Belum ada tugas di kategori ini</p>
                  </div>
                )}
              </div>
            </Tabs>
          </div>
        </Card>
      </main>
    </div>
  )
}
