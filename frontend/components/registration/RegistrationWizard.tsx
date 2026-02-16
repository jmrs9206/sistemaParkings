"use client";

import { useState } from "react";

export default function RegistrationWizard() {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    nombre: "",
    dni: "",
    email: "",
    iban: "",
    archivo: null as File | null,
  });

  const nextStep = () => setStep(step + 1);
  const prevStep = () => setStep(step - 1);

  return (
    <div className="max-w-xl mx-auto space-y-10 animate-in fade-in slide-in-from-bottom-8 duration-700">
      {/* Progress Bar */}
      <div className="flex gap-2">
        {[1, 2, 3].map((s) => (
          <div 
            key={s} 
            className={`h-1 flex-1 rounded-full transition-all duration-500 ${s <= step ? 'bg-parking-gold' : 'bg-white/10'}`}
          />
        ))}
      </div>

      <div className="space-y-4">
        <h2 className="text-3xl font-bold">Registro de <span className="text-parking-gold">Abonado</span></h2>
        <p className="text-white/40 text-sm">Paso {step} de 3 — {
          step === 1 ? "Datos Personales" : 
          step === 2 ? "Datos de Pago" : 
          "Documentación"
        }</p>
      </div>

      <div className="glass p-8 rounded-3xl space-y-8 border-parking-gold/5">
        {step === 1 && (
          <div className="space-y-6">
            <div className="space-y-2">
              <label className="text-xs uppercase tracking-widest font-bold text-white/50">Nombre o Razón Social</label>
              <input 
                type="text" 
                placeholder="Ej: Juan Pérez" 
                className="w-full bg-white/5 border border-white/10 rounded-xl p-4 focus:border-parking-gold outline-none transition-all"
                onChange={(e) => setFormData({...formData, nombre: e.target.value})}
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                    <label className="text-xs uppercase tracking-widest font-bold text-white/50">DNI / CIF</label>
                    <input 
                        type="text" 
                        placeholder="12345678X" 
                        className="w-full bg-white/5 border border-white/10 rounded-xl p-4 focus:border-parking-gold outline-none transition-all"
                    />
                </div>
                <div className="space-y-2">
                    <label className="text-xs uppercase tracking-widest font-bold text-white/50">Email</label>
                    <input 
                        type="email" 
                        placeholder="juan@email.com" 
                        className="w-full bg-white/5 border border-white/10 rounded-xl p-4 focus:border-parking-gold outline-none transition-all"
                    />
                </div>
            </div>
            <button onClick={nextStep} className="btn-gold w-full py-4 mt-4">Continuar</button>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-6">
             <div className="bg-parking-gold/10 p-4 rounded-xl border border-parking-gold/20 flex gap-4 items-center">
                <span className="text-2xl">🏦</span>
                <p className="text-[12px] text-parking-gold font-medium leading-tight">
                    El pago de abonos se realiza exclusivamente por domiciliación bancaria para tu comodidad.
                </p>
            </div>
            <div className="space-y-2">
              <label className="text-xs uppercase tracking-widest font-bold text-white/50">IBAN para domiciliación</label>
              <input 
                type="text" 
                placeholder="ES21 0000 ...." 
                className="w-full bg-white/5 border border-white/10 rounded-xl p-4 focus:border-parking-gold outline-none transition-all font-mono"
              />
            </div>
            <div className="flex gap-4">
                <button onClick={prevStep} className="flex-1 px-6 py-4 rounded-xl border border-white/10 hover:bg-white/5 transition-all">Atrás</button>
                <button onClick={nextStep} className="flex-[2] btn-gold py-4">Validar y Continuar</button>
            </div>
          </div>
        )}

        {step === 3 && (
          <div className="space-y-6 text-center">
            <div className="space-y-4">
                <div className="w-20 h-20 bg-white/5 rounded-full flex items-center justify-center mx-auto text-3xl border border-dashed border-white/20">
                    📂
                </div>
                <div>
                    <h4 className="font-bold">Sube tu DNI o CIF</h4>
                    <p className="text-sm text-white/30">Necesitamos verificar tu identidad para activar el contrato SEPA.</p>
                </div>
            </div>
            
            <label className="block w-full cursor-pointer group">
                <div className="border-2 border-dashed border-white/10 rounded-2xl p-10 group-hover:border-parking-gold/50 group-hover:bg-white/5 transition-all">
                    <span className="text-sm text-white/50">Haz click para seleccionar archivos</span>
                    <input type="file" className="hidden" />
                </div>
            </label>

            <div className="flex gap-4">
                <button onClick={prevStep} className="flex-1 px-6 py-4 rounded-xl border border-white/10 hover:bg-white/5 transition-all">Atrás</button>
                <button 
                  onClick={() => alert('¡Registro solicitado con éxito! En revisión administrativa.')} 
                  className="flex-[2] btn-gold py-4"
                >
                    Finalizar Registro
                </button>
            </div>
          </div>
        )}
      </div>

      <div className="text-center text-white/20 text-[10px] uppercase tracking-[0.2em]">
        Conexión Segura SSL • Protección de Datos GDPR
      </div>
    </div>
  );
}
