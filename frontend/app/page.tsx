"use client";

import { useEffect, useState } from "react";
import { Parking } from "@/types/parking";
import ParkingMap from "@/components/dashboard/ParkingMap";

// DML-matched Mock Data V11.0
const MOCK_PARKING: Parking = {
  idParking: 1,
  nombre: "Parking Centro Sol",
  idLocalidad: 1,
  activo: true,
  zonas: [
    {
      idZona: 1,
      nombre: "Planta 0 - Principal",
      activo: true,
      estaciones: [
        { idEstacion: 1, codigoEstacion: "P0-01", idSensor: "SENS-001", estadoActual: "O" },
        { idEstacion: 2, codigoEstacion: "P0-02", idSensor: "SENS-002", estadoActual: "L" },
        { idEstacion: 3, codigoEstacion: "P0-03", idSensor: "SENS-003", estadoActual: "L" },
        { idEstacion: 4, codigoEstacion: "P0-04", idSensor: "SENS-004", estadoActual: "M" },
        { idEstacion: 5, codigoEstacion: "P0-05", idSensor: "SENS-005", estadoActual: "L" },
      ]
    },
    {
        idZona: 2,
        nombre: "Planta -1 - VIP",
        activo: true,
        estaciones: [
          { idEstacion: 6, codigoEstacion: "P1-01", idSensor: "SENS-006", estadoActual: "O" },
          { idEstacion: 7, codigoEstacion: "P1-02", idSensor: "SENS-007", estadoActual: "O" },
          { idEstacion: 8, codigoEstacion: "P1-03", idSensor: "SENS-008", estadoActual: "L" },
        ]
      }
  ]
};

export default function Home() {
  const [parkingData, setParkingData] = useState<Parking | null>(null);
  const [isLive, setIsLive] = useState(false);

  useEffect(() => {
    // Initial load
    setParkingData(MOCK_PARKING);

    if (isLive) {
      const interval = setInterval(() => {
        // Simple simulation: flip a random station's status
        setParkingData(prev => {
          if (!prev) return prev;
          const newZonas = [...prev.zonas];
          const zIdx = Math.floor(Math.random() * newZonas.length);
          const eIdx = Math.floor(Math.random() * newZonas[zIdx].estaciones.length);
          
          const current = newZonas[zIdx].estaciones[eIdx].estadoActual;
          newZonas[zIdx].estaciones[eIdx].estadoActual = current === 'L' ? 'O' : 'L';
          
          return { ...prev, zonas: newZonas };
        });
      }, 3000);
      return () => clearInterval(interval);
    }
  }, [isLive]);

  return (
    <div className="space-y-24 pb-20">
      {/* Hero / Landing Section */}
      <section className="grid lg:grid-cols-2 gap-12 items-center">
        <div className="space-y-8">
          <h1 className="text-6xl font-black leading-tight">
            Gestión de <span className="text-parking-gold">Parkings</span> de Próxima Generación.
          </h1>
          <p className="text-white/60 text-lg max-w-lg">
            Control total en tiempo real, facturación inteligente y la mejor experiencia para tus abonados. Todo en un solo panel.
          </p>
          <div className="flex gap-4">
             <a href="/abonados/registro" className="btn-gold">Hazte Abonado</a>
            <button className="px-6 py-2 rounded-lg border border-white/10 hover:bg-white/5 transition-all">Ver Ventajas</button>
          </div>
        </div>

        <div className="glass p-8 rounded-3xl relative overflow-hidden group">
            <div className="absolute top-0 right-0 w-32 h-32 bg-padding-gold/10 blur-3xl group-hover:bg-parking-gold/20 transition-all"></div>
            <h3 className="text-xl font-bold mb-6 text-parking-gold italic">Ventajas de ser Abonado:</h3>
            <ul className="space-y-4">
                <Advantage icon="⚡" title="Acceso prioritario" desc="Entrada sin esperas mediante reconocimiento de matrícula." />
                <Advantage icon="💰" title="Tarifas Especiales" desc="Ahorra hasta un 40% con nuestras cuotas mensuales fijas." />
                <Advantage icon="🏢" title="Plaza Reservada" desc="Asegura tu sitio en las zonas más cómodas y seguras." />
                <Advantage icon="📱" title="Control total App" desc="Gestiona tus facturas y vehículos desde tu smartphone." />
            </ul>
        </div>
      </section>

      {/* Dashboard Section */}
      <section className="space-y-10">
        <div className="flex items-end justify-between">
            <div className="space-y-2">
                <h2 className="text-4xl font-bold tracking-tight">Panel de Control <span className="text-parking-gold font-light">Operativo</span></h2>
                <p className="text-white/40">Visualización en tiempo real del estado de las instalaciones.</p>
            </div>
            <div className="flex items-center gap-4 bg-white/5 p-2 rounded-xl border border-white/10">
                <span className={`text-[10px] font-bold uppercase tracking-widest ${isLive ? 'text-parking-green' : 'text-white/30'}`}>
                    {isLive ? '• Simulando Sensores' : 'Datos Estáticos'}
                </span>
                <button 
                    onClick={() => setIsLive(!isLive)}
                    className={`w-12 h-6 rounded-full transition-all relative ${isLive ? 'bg-parking-green' : 'bg-white/10'}`}
                >
                    <div className={`absolute top-1 w-4 h-4 bg-white rounded-full transition-all ${isLive ? 'left-7' : 'left-1'}`}></div>
                </button>
            </div>
        </div>

        {parkingData && <ParkingMap parking={parkingData} />}
      </section>

      {/* Registration Preview (Next Step) */}
      <section className="glass p-12 rounded-[2rem] text-center space-y-8 border-parking-gold/10">
        <h2 className="text-3xl font-bold">¿Listo para formar parte de <span className="text-parking-gold underline decoration-parking-gold/30">nuestro parking</span>?</h2>
        <p className="text-white/50 max-w-2xl mx-auto italic">
            "El registro es 100% digital. Ten a mano tu DNI y tu número de cuenta (IBAN). Nosotros nos encargamos del resto."
        </p>
        <a href="/abonados/registro" className="btn-gold inline-block scale-125 hover:scale-110 active:scale-95 transition-transform">
            Empezar Registro Digital
        </a>
      </section>
    </div>
  );
}

function Advantage({ icon, title, desc }: { icon: string; title: string, desc: string }) {
    return (
        <li className="flex gap-4">
            <div className="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center text-xl shrink-0">{icon}</div>
            <div>
                <h4 className="font-bold text-white/90">{title}</h4>
                <p className="text-sm text-white/40">{desc}</p>
            </div>
        </li>
    );
}
