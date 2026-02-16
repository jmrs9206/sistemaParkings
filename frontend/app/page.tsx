"use client";

export default function Home() {
  return (
    <div className="space-y-24 pb-20">
      {/* Hero / Landing Section */}
      <section className="grid lg:grid-cols-2 gap-12 items-center py-10">
        <div className="space-y-8">
          <h1 className="text-6xl font-black leading-tight">
            Bienvenido a <span className="text-parking-gold">Phoenix</span> Parking.
          </h1>
          <p className="text-white/60 text-lg max-w-lg">
            Ahorra tiempo y dinero con nuestro sistema inteligente de abonados. Reconocimiento automático de matrícula y facturación simplificada.
          </p>
          <div className="flex gap-4">
             <a href="/abonados/registro" className="btn-gold">Hazte Abonado Ahora</a>
             <a href="#ventajas" className="px-6 py-2 rounded-lg border border-white/10 hover:bg-white/5 transition-all text-center flex items-center">Explorar Ventajas</a>
          </div>
        </div>

        <div className="glass p-8 rounded-3xl relative overflow-hidden group">
            <div className="absolute top-0 right-0 w-32 h-32 bg-parking-gold/10 blur-3xl group-hover:bg-parking-gold/20 transition-all"></div>
            <h3 className="text-xl font-bold mb-6 text-parking-gold italic">¿Por qué elegir JMRS?</h3>
            <ul className="space-y-4">
                <Advantage icon="⚡" title="Sin colas" desc="Reconocimiento de matrícula para entrar y salir sin ticket." />
                <Advantage icon="💰" title="Precio Fijo" desc="Cuotas mensuales sin sorpresas, hasta un 40% más barato." />
                <Advantage icon="🛡️" title="Seguridad 24/7" desc="Vigilancia avanzada y zonas exclusivas para abonados." />
                <Advantage icon="📱" title="Gestión Digital" desc="Tu factura siempre disponible en tu portal privado." />
            </ul>
        </div>
      </section>

      {/* Trust Section */}
      <section id="ventajas" className="grid md:grid-cols-3 gap-8">
        <FeatureCard 
            title="Sencillez" 
            desc="Regístrate en 3 minutos. Domicilia el pago y olvídate de los cajeros automáticos para siempre." 
        />
        <FeatureCard 
            title="Transparencia" 
            desc="Control absoluto de tus consumos. Descarga tus facturas en PDF desde cualquier lugar." 
        />
        <FeatureCard 
            title="Flexibilidad" 
            desc="Cancela tu abono cuando quieras. Sin permanencias ocultas ni letras pequeñas." 
        />
      </section>

      {/* Call to Action */}
      <section className="glass p-12 rounded-[2rem] text-center space-y-8 border-parking-gold/10 relative overflow-hidden">
        <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-parking-gold to-transparent opacity-30"></div>
        <h2 className="text-3xl font-bold">Empieza a disfrutar de <span className="text-parking-gold underline decoration-parking-gold/30">un parking sin estrés</span></h2>
        <p className="text-white/50 max-w-2xl mx-auto italic">
            "Únete a los más de 500 abonados que ya han simplificado su día a día con nuestra tecnología."
        </p>
        <a href="/abonados/registro" className="btn-gold inline-block scale-125 hover:scale-110 active:scale-95 transition-transform mt-4">
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

function FeatureCard({ title, desc }: { title: string, desc: string }) {
    return (
        <div className="glass p-8 rounded-2xl border-white/5 hover:border-parking-gold/20 transition-all group">
            <div className="w-12 h-1 bg-parking-gold/30 group-hover:w-full transition-all duration-500 mb-6"></div>
            <h4 className="text-xl font-bold mb-3">{title}</h4>
            <p className="text-white/40 text-sm leading-relaxed">{desc}</p>
        </div>
    );
}
