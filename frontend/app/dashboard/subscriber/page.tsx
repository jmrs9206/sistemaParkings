"use client";

import { useState } from "react";
import { Factura, ApiResponse } from "@/types/parking";

const MOCK_INVOICES: ApiResponse<Factura[]> = {
  success: true,
  message: "Facturas cargadas",
  timestamp: new Date().toISOString(),
  data: [
    { idFactura: 1, numeroFactura: "FAC-2024-001", fechaEmision: "2024-01-01", totalFactura: 100.00, pagoConfirmado: true },
    { idFactura: 2, numeroFactura: "FAC-2024-002", fechaEmision: "2024-02-01", totalFactura: 100.00, pagoConfirmado: true },
    { idFactura: 3, numeroFactura: "FAC-2024-003", fechaEmision: "2024-03-01", totalFactura: 15.40, pagoConfirmado: false },
  ]
};

export default function SubscriberDashboard() {
  const [invoices] = useState<Factura[]>(MOCK_INVOICES.data);

  return (
    <div className="space-y-12 pb-20">
      <header className="space-y-4">
        <h1 className="text-4xl font-bold tracking-tight">Mi Portal de <span className="text-parking-gold">Abonado</span></h1>
        <p className="text-white/40">Bienvenido de nuevo, Juan Pérez. Aquí tienes tus facturas y consumos.</p>
      </header>

      <section className="glass rounded-3xl overflow-hidden">
        <div className="p-8 border-b border-white/10 bg-white/5">
          <h2 className="text-xl font-bold">Historial de Facturación</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="bg-white/5 text-white/40 text-sm uppercase tracking-wider">
                <th className="px-8 py-4 font-medium">Factura Nº</th>
                <th className="px-8 py-4 font-medium">Fecha Emisión</th>
                <th className="px-8 py-4 font-medium">Total</th>
                <th className="px-8 py-4 font-medium">Estado</th>
                <th className="px-8 py-4 font-medium text-right">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-white/10">
              {invoices.map((fac) => (
                <tr key={fac.idFactura} className="hover:bg-white/5 transition-colors group">
                  <td className="px-8 py-6 font-mono text-parking-gold">{fac.numeroFactura}</td>
                  <td className="px-8 py-6">{new Date(fac.fechaEmision).toLocaleDateString()}</td>
                  <td className="px-8 py-6 font-bold">{fac.totalFactura.toFixed(2)}€</td>
                  <td className="px-8 py-6">
                    <span className={`px-3 py-1 rounded-full text-[10px] font-bold uppercase ${
                      fac.pagoConfirmado ? 'bg-parking-green/20 text-parking-green' : 'bg-parking-red/20 text-parking-red'
                    }`}>
                      {fac.pagoConfirmado ? 'Pagada' : 'Pendiente'}
                    </span>
                  </td>
                  <td className="px-8 py-6 text-right">
                    <button className="text-parking-gold opacity-0 group-hover:opacity-100 transition-all flex items-center gap-2 ml-auto">
                      <span className="text-xs uppercase font-bold tracking-widest">Descargar PDF</span>
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="I7 16l-4-4m0 0l4-4m-4 4h18" />
                      </svg>
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <div className="grid md:grid-cols-2 gap-8">
        <div className="glass p-8 rounded-3xl space-y-4">
             <h3 className="text-lg font-bold">Mi Contrato</h3>
             <div className="space-y-2 text-sm">
                <p className="flex justify-between"><span className="text-white/40">Tarifa:</span> <span className="font-bold">Abono Mensual VIP</span></p>
                <p className="flex justify-between"><span className="text-white/40">Vehículo:</span> <span className="font-bold text-parking-gold">1234-BBB</span></p>
                <p className="flex justify-between"><span className="text-white/40">Día de Cobro:</span> <span className="font-bold">Día 1 de cada mes</span></p>
             </div>
        </div>
        <div className="glass p-8 rounded-3xl space-y-4 border-l-4 border-parking-gold/50">
             <h3 className="text-lg font-bold">Soporte Express</h3>
             <p className="text-sm text-white/40 italic">¿Tienes alguna duda con tu factura? Contacta con nuestro equipo VIP.</p>
             <button className="text-sm font-bold text-parking-gold underline">Abrir Chat de Soporte</button>
        </div>
      </div>
    </div>
  );
}
