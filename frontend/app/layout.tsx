import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Parking Management | Premium Solution",
  description: "Advanced parking management by JMRS",
};

import Navbar from "@/components/layout/Navbar";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body className={inter.className}>
        <Navbar />
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
