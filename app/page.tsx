'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card } from '@/components/ui/card'
import { Lock, Mail } from 'lucide-react'
import Image from 'next/image'
import Link from 'next/link'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setTimeout(() => {
      setLoading(false)
      window.location.href = '/dashboard'
    }, 1000)
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-slate-100 flex items-center justify-center px-4 py-12">
      <Card className="w-full max-w-md shadow-xl border-0">
        <div className="p-8">
          {/* Logo */}
          <div className="flex justify-center mb-8">
            <div className="relative w-24 h-24">
              <Image
                src="/logo-bmi.png"
                alt="BMI Logo"
                fill
                className="object-contain"
                priority
              />
            </div>
          </div>

          {/* Title */}
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold text-slate-900 mb-2">
              Sistem Teknisi
            </h1>
            <p className="text-sm text-slate-600">
              Bumi Menara Internusa Maintenance
            </p>
          </div>

          {/* Form */}
          <form onSubmit={handleLogin} className="space-y-6">
            {/* Email Input */}
            <div className="space-y-2">
              <label htmlFor="email" className="block text-sm font-medium text-slate-700">
                Email
              </label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                <Input
                  id="email"
                  type="email"
                  placeholder="teknisi@bmi.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="pl-10 bg-slate-50 border-slate-200 rounded-lg h-11"
                  required
                />
              </div>
            </div>

            {/* Password Input */}
            <div className="space-y-2">
              <label htmlFor="password" className="block text-sm font-medium text-slate-700">
                Kata Sandi
              </label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                <Input
                  id="password"
                  type="password"
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="pl-10 bg-slate-50 border-slate-200 rounded-lg h-11"
                  required
                />
              </div>
            </div>

            {/* Login Button */}
            <Button
              type="submit"
              disabled={loading}
              className="w-full h-11 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-lg transition-colors"
            >
              {loading ? 'Masuk...' : 'Masuk ke Sistem'}
            </Button>
          </form>

          {/* Demo Info */}
          <div className="mt-8 pt-6 border-t border-slate-200">
            <p className="text-xs text-slate-500 text-center mb-3">
              Demo: Gunakan kredensial apapun
            </p>
            <div className="bg-amber-50 border border-amber-200 rounded-lg p-3">
              <p className="text-xs text-amber-800">
                <span className="font-semibold">Email:</span> teknisi@bmi.com
              </p>
              <p className="text-xs text-amber-800">
                <span className="font-semibold">Password:</span> demo123
              </p>
            </div>
          </div>

          {/* Footer */}
          <p className="text-xs text-slate-500 text-center mt-6">
            © 2024 Bumi Menara Internusa. Semua hak dilindungi.
          </p>
        </div>
      </Card>
    </div>
  )
}
