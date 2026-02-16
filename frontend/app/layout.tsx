import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Parking Management | Premium Solution",
  description: "Advanced parking management by JMRS",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body className={inter.className}>
        <header className="fixed top-0 w-full z-50 glass">
          <nav className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-parking-gold rounded-sm transform rotate-45 rotate-3D"></div>
              <span className="text-xl font-bold tracking-tighter text-parking-gold">JMRS <span className="text-white font-light">PARKINGS</span></span>
            </div>
            <div className="hidden md:flex items-center gap-8">
              <a href="#" className="nav-link">Dashboard</a>
              <a href="#" className="nav-link">Abonados</a>
              <a href="#" className="nav-link">BI Reports</a>
              <button className="btn-gold">Acceso Personal</button>
            </div>
          </nav>
        </header>
        <main className="pt-32 min-h-screen px-6">
          <div className="max-w-7xl mx-auto">
            {children}
          </div>
        </main>
        <footer className="py-12 border-t border-white/5 bg-black/50">
          <div className="max-w-7xl mx-auto px-6 text-center text-white/40 text-sm">
            &copy; 2026 JMRS - Gestión Avanzada de Parkings (V11.0)
          </div>
        </footer>
      </body>
    </html>
  );
}
