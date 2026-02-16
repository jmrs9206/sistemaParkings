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
        <Link href="/" className="flex items-center gap-2">
          <div className="w-8 h-8 bg-parking-gold rounded-sm transform rotate-45"></div>
          <span className="text-xl font-bold tracking-tighter text-parking-gold">
            JMRS <span className="text-white font-light">PARKINGS</span>
          </span>
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
