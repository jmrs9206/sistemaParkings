"use client";

import { useEffect, useState } from "react";
import { Parking, ApiResponse, Zona, Estacion } from "@/types/parking";
import ParkingMap from "@/components/dashboard/ParkingMap";

// DML-matched Mock Data V12.0 (DTO Pattern)
const MOCK_RESPONSE: ApiResponse<Parking> = {
  success: true,
  message: "Mock data loaded",
  timestamp: new Date().toISOString(),
  data: {
    idParking: 1,
    nombre: "Parking Centro Sol",
    zonas: [
      {
        idZona: 1,
        nombre: "Planta 0 - Principal",
        estaciones: [
          { idEstacion: 1, codigoEstacion: "P0-01", estadoActual: "O" },
          { idEstacion: 2, codigoEstacion: "P0-02", estadoActual: "L" },
          { idEstacion: 3, codigoEstacion: "P0-03", estadoActual: "L" },
          { idEstacion: 4, codigoEstacion: "P0-04", estadoActual: "M" },
          { idEstacion: 5, codigoEstacion: "P0-05", estadoActual: "L" },
        ]
      },
      {
          idZona: 2,
          nombre: "Planta -1 - VIP",
          estaciones: [
            { idEstacion: 6, codigoEstacion: "P1-01", estadoActual: "O" },
            { idEstacion: 7, codigoEstacion: "P1-02", estadoActual: "O" },
            { idEstacion: 8, codigoEstacion: "P1-03", estadoActual: "L" },
          ]
        }
    ]
  }
};

export default function StaffDashboard() {
  const [parkingData, setParkingData] = useState<Parking | null>(null);
  const [isLive, setIsLive] = useState(false);

  useEffect(() => {
    // Initial load
    setParkingData(MOCK_RESPONSE.data);

    if (isLive) {
      const interval = setInterval(() => {
        setParkingData(prev => {
          if (!prev) return prev;
          const zIdx = Math.floor(Math.random() * prev.zonas.length);
          const eIdx = Math.floor(Math.random() * prev.zonas[zIdx].estaciones.length);
          
          const newZonas = prev.zonas.map((zona: Zona, i: number) => {
            if (i !== zIdx) return zona;
            const newEstaciones = zona.estaciones.map((est: Estacion, j: number) => {
              if (j !== eIdx) return est;
              return { ...est, estadoActual: (est.estadoActual === 'L' ? 'O' : 'L') as 'L' | 'O' | 'M' };
            });
            return { ...zona, estaciones: newEstaciones };
          });
          
          return { ...prev, zonas: newZonas };
        });
      }, 3000);
      return () => clearInterval(interval);
    }
  }, [isLive]);

  return (
    <div className="space-y-12 pb-20">
      <header className="flex items-end justify-between">
          <div className="space-y-4">
              <h1 className="text-4xl font-bold tracking-tight">Portal <span className="text-parking-gold">Staff JMRS</span></h1>
              <p className="text-white/40">Visualización en tiempo real y toma de decisiones operativa.</p>
          </div>
          <div className="flex items-center gap-4 bg-white/5 p-3 rounded-2xl border border-white/10">
              <div className="flex flex-col items-end">
                <span className={`text-[10px] font-bold uppercase tracking-widest ${isLive ? 'text-parking-green' : 'text-white/30'}`}>
                    {isLive ? '• Monitoreo Vivo' : 'Pausa de Sensores'}
                </span>
                <span className="text-[9px] text-white/20">Muestreo cada 3s</span>
              </div>
              <button 
                  onClick={() => setIsLive(!isLive)}
                  className={`w-14 h-7 rounded-full transition-all relative ${isLive ? 'bg-parking-green' : 'bg-white/10'}`}
              >
                  <div className={`absolute top-1 w-5 h-5 bg-white rounded-full shadow-lg transition-all ${isLive ? 'left-8' : 'left-1'}`}></div>
              </button>
          </div>
      </header>

      <section className="grid lg:grid-cols-4 gap-6">
          <MetricCard title="Ocupación Total" value="78%" trend="+5%" color="gold" />
          <MetricCard title="Ingresos Hoy" value="1.240€" trend="+12%" color="green" />
          <MetricCard title="Abonados VIP" value="124" trend="+2" color="blue" />
          <MetricCard title="Incidencias" value="0" trend="0" color="red" />
      </section>

      <section className="space-y-6">
        <h2 className="text-2xl font-bold flex items-center gap-3">
          <span className="w-2 h-8 bg-parking-gold"></span>
          Mapa de Ocupación
        </h2>
        {parkingData && <ParkingMap parking={parkingData} />}
      </section>
    </div>
  );
}

function MetricCard({ title, value, trend, color }: { title: string, value: string, trend: string, color: 'gold' | 'green' | 'blue' | 'red' }) {
    const colorClass = {
        gold: 'border-parking-gold/20 text-parking-gold',
        green: 'border-parking-green/20 text-parking-green',
        blue: 'border-parking-blue/20 text-parking-blue',
        red: 'border-parking-red/20 text-parking-red'
    }[color];

    return (
        <div className={`glass p-6 rounded-2xl border-l-4 ${colorClass}`}>
            <p className="text-white/40 text-xs uppercase font-bold tracking-widest mb-1">{title}</p>
            <div className="flex items-baseline gap-3">
                <span className="text-3xl font-black text-white">{value}</span>
                <span className="text-[10px] font-bold">{trend}</span>
            </div>
        </div>
    );
}
