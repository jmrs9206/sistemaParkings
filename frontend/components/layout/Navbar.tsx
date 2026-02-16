"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";

type Role = "public" | "subscriber" | "staff";

export default function Navbar() {
  const [role, setRole] = useState<Role>("public");
  const pathname = usePathname();

  // Load role from localStorage on mount
  useEffect(() => {
    const savedRole = localStorage.getItem("user-role") as Role;
    if (savedRole) setRole(savedRole);
  }, []);

  const handleRoleChange = (newRole: Role) => {
    setRole(newRole);
    localStorage.setItem("user-role", newRole);
    // Redirect based on role if needed, or let user click
    if (newRole === "subscriber") window.location.href = "/dashboard/subscriber";
    if (newRole === "staff") window.location.href = "/dashboard/staff";
    if (newRole === "public") window.location.href = "/";
  };

  return (
    <header className="fixed top-0 w-full z-50 glass">
      <nav className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
        <Link href="/" className="flex items-center gap-3 group">
          <div className="relative w-12 h-12 overflow-hidden rounded-full border border-parking-gold/20 group-hover:border-parking-gold/50 transition-all shadow-[0_0_15px_rgba(224,179,76,0.1)]">
            <img 
              src="/branding/logo_phoenix.png" 
              alt="Phoenix Parking Logo" 
              className="object-cover w-full h-full transform group-hover:scale-110 transition-transform duration-500"
            />
          </div>
          <div className="flex flex-col">
            <span className="text-xl font-bold tracking-tighter text-parking-gold leading-none">
              PHOENIX <span className="text-white font-light">PARKING</span>
            </span>
            <span className="text-[10px] text-white/30 uppercase tracking-[0.2em] font-black">Powered by JMRS</span>
          </div>
        </Link>

        <div className="hidden md:flex items-center gap-8">
          {role === "public" && (
            <>
              <a href="#ventajas" className="nav-link">Ventajas</a>
              <Link href="/abonados/registro" className="nav-link">Precios</Link>
              <button 
                onClick={() => handleRoleChange("subscriber")}
                className="btn-gold"
              >
                Acceso Abonado
              </button>
              <button 
                onClick={() => handleRoleChange("staff")}
                className="text-white/30 text-[10px] uppercase font-bold hover:text-white transition-colors"
              >
                Staff Login
              </button>
            </>
          )}

          {role === "subscriber" && (
            <>
              <Link href="/dashboard/subscriber" className={`nav-link ${pathname === "/dashboard/subscriber" ? "text-parking-gold" : ""}`}>Mis Facturas</Link>
              <Link href="/" className="nav-link">Ventajas</Link>
              <div className="flex items-center gap-4">
                <span className="text-xs text-white/40">Hola, <span className="text-white font-bold">Juan</span></span>
                <button 
                  onClick={() => handleRoleChange("public")}
                  className="px-4 py-1.5 rounded-lg border border-white/10 text-xs hover:bg-white/5"
                >
                  Salir
                </button>
              </div>
            </>
          )}

          {role === "staff" && (
            <>
              <Link href="/dashboard/staff" className={`nav-link ${pathname === "/dashboard/staff" ? "text-parking-gold" : ""}`}>Mapa Operativo</Link>
              <Link href="#" className="nav-link">Gestión Abonados</Link>
              <Link href="#" className="nav-link">BI Reports</Link>
              <div className="flex items-center gap-4">
                <span className="text-xs text-parking-gold font-bold bg-parking-gold/10 px-2 py-1 rounded">MODO ADMIN</span>
                <button 
                  onClick={() => handleRoleChange("public")}
                  className="px-4 py-1.5 rounded-lg border border-white/10 text-xs hover:bg-white/5"
                >
                  Cerrar Sesión
                </button>
              </div>
            </>
          )}
        </div>
      </nav>
    </header>
  );
}
