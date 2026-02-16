"use client";

import { StationStatus } from "@/types/parking";

interface StationLEDProps {
  codigo: string;
  status: StationStatus;
}

export default function StationLED({ codigo, status }: StationLEDProps) {
  const statusColors = {
    L: "bg-parking-green shadow-[0_0_15px_rgba(74,222,128,0.5)]", // Libre
    O: "bg-parking-red shadow-[0_0_15px_rgba(248,113,113,0.5)]",   // Ocupada
    M: "bg-parking-yellow shadow-[0_0_15px_rgba(250,204,21,0.5)]", // Mantenimiento
  };

  const statusLabels = {
    L: "Libre",
    O: "Ocupado",
    M: "Mantenimiento",
  };

  return (
    <div className="relative group p-4 glass rounded-xl flex flex-col items-center gap-3 transition-all hover:scale-105">
      <div className={`w-4 h-4 rounded-full ${statusColors[status]} animate-pulse`}></div>
      <div className="text-xs font-bold tracking-widest text-white/40 uppercase">{codigo}</div>
      
      {/* Tooltip on hover */}
      <div className="absolute -top-12 opacity-0 group-hover:opacity-100 transition-opacity bg-black/90 px-3 py-1 rounded text-[10px] whitespace-nowrap z-10 border border-parking-gold/20">
        Status: <span className="font-bold text-parking-gold">{statusLabels[status]}</span>
      </div>
    </div>
  );
}
