"use client";

import { Parking } from "@/types/parking";
import StationLED from "./StationLED";

interface ParkingMapProps {
  parking: Parking;
}

export default function ParkingMap({ parking }: ParkingMapProps) {
  return (
    <div className="space-y-12 animate-in fade-in slide-in-from-bottom-4 duration-1000">
      <div className="flex items-center justify-between border-b border-white/5 pb-6">
        <div>
          <h2 className="text-3xl font-bold text-white">{parking.nombre}</h2>
          <p className="text-white/40 text-sm italic">Estado Operativo en Tiempo Real</p>
        </div>
        <div className="flex gap-4">
            <Legend color="bg-parking-green" label="Libre" />
            <Legend color="bg-parking-red" label="Ocupado" />
            <Legend color="bg-parking-yellow" label="Mantenimiento" />
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {parking.zonas.map((zona) => (
          <div key={zona.idZona} className="space-y-6">
            <div className="flex items-center gap-3">
              <span className="w-1 h-6 bg-parking-gold"></span>
              <h3 className="text-xl font-semibold">{zona.nombre}</h3>
              <span className="text-xs text-white/30 bg-white/5 px-2 py-0.5 rounded uppercase tracking-widest">
                {zona.estaciones.length} Plazas
              </span>
            </div>
            
            <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 gap-4">
              {zona.estaciones.map((estacion) => (
                <StationLED 
                  key={estacion.idEstacion} 
                  codigo={estacion.codigoEstacion} 
                  status={estacion.estadoActual} 
                />
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function Legend({ color, label }: { color: string; label: string }) {
    return (
        <div className="flex items-center gap-2 text-[10px] uppercase font-bold tracking-widest text-white/40">
            <div className={`w-2 h-2 rounded-full ${color}`}></div>
            {label}
        </div>
    );
}
