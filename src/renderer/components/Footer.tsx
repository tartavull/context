import React, { useState, useEffect } from 'react'

export function Footer() {
  const [time, setTime] = useState(new Date())

  useEffect(() => {
    const timer = setInterval(() => {
      setTime(new Date())
    }, 1000)

    return () => clearInterval(timer)
  }, [])

  const formatTime = (date: Date) => {
    const minutes = date.getMinutes().toString().padStart(2, '0')
    const seconds = date.getSeconds().toString().padStart(2, '0')
    return `${minutes}:${seconds}`
  }

  return (
    <div 
      className="h-8 flex items-center justify-end px-4 border-t"
      style={{ 
        backgroundColor: '#1a1a1a',
        borderTopColor: '#0a0a0a' // darker grey line
      }}
    >
      <div className="text-xs text-gray-400 font-mono">
        {formatTime(time)}
      </div>
    </div>
  )
} 