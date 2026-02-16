/**
 * Phoenix Parking - Gestión Frontend (Vanilla JS)
 * @version 14.3 (Premium Theme + Legal Modals)
 */

const API_BASE_URL = 'http://localhost:8080/api';

const LANDING_SECTIONS = ['hero', 'services', 'advantages', 'pricing', 'coming-soon'];
const FUNCTIONAL_SECTIONS = ['status-section', 'registration-section', 'login-section'];

function showSection(targetId) {
    // If opening registration or login, show as modal
    if (targetId === 'register') {
        const modal = document.getElementById('registration-modal');
        if (modal) {
            modal.classList.remove('hidden');
            modal.classList.add('flex');
            // Reset to step 1
            nextStep(1);
        }
        return;
    }

    if (targetId === 'login') {
        const modal = document.getElementById('login-modal');
        if (modal) {
            modal.classList.remove('hidden');
            modal.classList.add('flex');
        }
        return;
    }

    // Original logic for other sections
    [...LANDING_SECTIONS, ...FUNCTIONAL_SECTIONS].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.classList.add('hidden');
    });

    if (targetId === 'hero') {
        LANDING_SECTIONS.forEach(id => {
            const el = document.getElementById(id);
            if (el) el.classList.remove('hidden');
        });
        window.scrollTo(0, 0);
    } else {
        const el = document.getElementById(targetId === 'status' ? 'status-section' : targetId);
        if (el) el.classList.remove('hidden');
        if (targetId === 'status') loadParkingStatus();
    }
}

function nextStep(step) {
    for (let i = 1; i <= 4; i++) {
        const formStep = document.getElementById(`form-step-${i}`);
        const indicator = document.getElementById(`step-${i}`);
        if (formStep) formStep.classList.add('hidden');
        if (indicator) indicator.classList.remove('active');
    }
    const currentForm = document.getElementById(`form-step-${step}`);
    const currentIndicator = document.getElementById(`step-${step}`);
    if (currentForm) currentForm.classList.remove('hidden');
    if (currentIndicator) currentIndicator.classList.add('active');

    for (let i = 1; i < step; i++) {
        const prev = document.getElementById(`step-${i}`);
        if (prev) {
            prev.classList.add('active');
            prev.style.backgroundColor = 'var(--accent)';
            prev.style.color = 'black';
        }
    }
}

function simulateSignature() {
    const firma = document.getElementById('reg-firma').value;
    if (!firma) {
        alert("Por favor, firme el contrato digitalmente.");
        return;
    }

    const abonadoData = {
        nombreRazonSocial: document.getElementById('reg-nombre').value,
        dniCif: document.getElementById('reg-dni').value,
        email: document.getElementById('reg-email').value,
        telefono: document.getElementById('reg-tel').value,
        idLocalidad: 1,
        idParking: parseInt(document.getElementById('reg-parking').value),
        matriculaPrincipal: document.getElementById('reg-m-principal').value,
        matriculaSecundaria1: document.getElementById('reg-m-sec1').value,
        matriculaSecundaria2: document.getElementById('reg-m-sec2').value
    };

    console.log("Procesando Alta Premium...", abonadoData);

    fetch(`${API_BASE_URL}/abonados/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(abonadoData)
    })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                const codigo = generatePremiumCode(data.data);
                document.getElementById('display-codigo-abonado').innerText = codigo;
                nextStep(4);
            } else {
                alert("Error: " + data.message);
            }
        })
        .catch(err => {
            console.warn("Modo Offline / Demo Activado");
            const demoData = { ...abonadoData, idAbonado: 9999 };
            const codigo = generatePremiumCode(demoData);
            document.getElementById('display-codigo-abonado').innerText = codigo;
            nextStep(4);
        });
}

function generatePremiumCode(data) {
    const parkingId = (data.idParking || 1).toString().padStart(2, '0');
    const id = (data.idAbonado || 0).toString().padStart(4, '0');
    const date = new Date().toISOString().slice(2, 10).replace(/-/g, '');
    return `PHX-${parkingId}-${date}-${id}`;
}

function finalizeRegistration() {
    const pass = document.getElementById('reg-password').value;
    if (!pass) {
        alert("Establezca una contraseña segura.");
        return;
    }
    alert("Bienvenido al Club Phoenix. Su cuenta ha sido activada.");
    showSection('login');
}

function loadParkingStatus() {
    const container = document.getElementById('parking-list');
    container.innerHTML = '<p class="text-muted">Conectando con satélite...</p>';

    fetch(`${API_BASE_URL}/parkings/status`)
        .then(r => r.json())
        .then(data => {
            if (data.success && data.data.length > 0) {
                container.innerHTML = '';
                data.data.forEach(p => {
                    const card = document.createElement('div');
                    card.className = 'card';
                    card.innerHTML = `
                        <h3 style="margin-bottom:0.5rem;">${p.nombre}</h3>
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <span class="text-muted">Capacidad Total: ${p.capacidadTotal}</span>
                            <span style="color: ${p.activo ? '#4ADE80' : '#EF4444'}; font-weight:bold;">
                                ${p.activo ? '● OPERATIVO' : '● MANTENIMIENTO'}
                            </span>
                        </div>
                    `;
                    container.appendChild(card);
                });
            } else {
                container.innerHTML = '<p>No se encontraron datos.</p>';
            }
        })
        .catch(() => {
            container.innerHTML = `
                <div class="card" style="border-color: red;">
                    <h3>Error de Conexión</h3>
                    <p class="text-muted">No se pudo contactar con el servidor central.</p>
                </div>
            `;
        });
}

function mockLogin() {
    const captcha = document.getElementById('login-captcha').value;
    if (captcha != "8") {
        alert("Verificación de seguridad incorrecta.");
        return;
    }

    const user = document.getElementById('login-username').value;
    window.location.href = user.toLowerCase().includes("admin") ? "views/admin.html" : "views/abonado.html";
}

/* =========================================
   LEGAL MODAL LOGIC
   ========================================= */

const LEGAL_TEXTS = {
    legal: `
        <h2>Aviso Legal</h2>
        <p>En cumplimiento de la Ley 34/2002, de 11 de julio, de servicios de la sociedad de la información y de comercio electrónico (LSSI), le informamos que:</p>
        <p><strong>PHOENIX PARKING S.L.</strong> es el titular del sitio web.</p>
        <p>Domicilio: Calle Gran Vía 1, 28013 Madrid.</p>
        <p>CIF: B-12345678</p>
        <p>Inscrita en el Registro Mercantil de Madrid, Tomo 1234, Folio 12, Hoja M-12345.</p>
    `,
    privacy: `
        <h2>Política de Privacidad</h2>
        <p>En Phoenix Parking nos tomamos muy en serio la privacidad de sus datos. De acuerdo con el Reglamento (UE) 2016/679 (RGPD), le informamos que:</p>
        <ol>
            <li><strong>Responsable:</strong> Phoenix Parking S.L.</li>
            <li><strong>Finalidad:</strong> Gestión de contratos de abono, facturación y control de accesos.</li>
            <li><strong>Legitimación:</strong> Ejecución de un contrato y consentimiento del interesado.</li>
            <li><strong>Destinatarios:</strong> No se cederán datos a terceros, salvo obligación legal.</li>
            <li><strong>Derechos:</strong> Acceder, rectificar y suprimir los datos, así como otros derechos detallados en la información adicional.</li>
        </ol>
    `,
    cookies: `
        <h2>Política de Cookies</h2>
        <p>Este sitio web utiliza cookies propias y de terceros para mejorar la experiencia de usuario y analizar el tráfico.</p>
        <p><strong>Cookies Técnicas:</strong> Necesarias para el funcionamiento del login y el proceso de registro.</p>
        <p><strong>Cookies de Análisis:</strong> Utilizamos Google Analytics de forma anonimizada para estadísticas de uso.</p>
        <p>Puede configurar su navegador para rechazar las cookies, aunque esto podría afectar a la funcionalidad de la web.</p>
    `,
    rgpd: `
        <h2>Reglamento General de Protección de Datos (RGPD)</h2>
        <p>Sus datos personales (Matrícula, DNI, Email) están protegidos con cifrado de grado militar.</p>
        <p>Tiene derecho a solicitar la exportación o eliminación de sus datos en cualquier momento contactando con dpo@phoenixparking.com.</p>
        <p>Conservación: Los datos de facturación se conservarán durante 5 años según normativa fiscal.</p>
    `
};

function showModal(type) {
    const modal = document.getElementById('legal-modal');
    const content = document.getElementById('modal-body-content');

    if (LEGAL_TEXTS[type]) {
        content.innerHTML = LEGAL_TEXTS[type];
        modal.classList.remove('hidden');
        modal.classList.add('flex');
    }
}

function closeModal(modalId = 'legal-modal') {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add('hidden');
        modal.classList.remove('flex');
    }
}

// Close modal when clicking outside
window.onclick = function (event) {
    const legalModal = document.getElementById('legal-modal');
    const registrationModal = document.getElementById('registration-modal');
    const loginModal = document.getElementById('login-modal');

    if (legalModal && event.target == legalModal) {
        closeModal('legal-modal');
    }
    if (registrationModal && event.target == registrationModal) {
        closeModal('registration-modal');
    }
    if (loginModal && event.target == loginModal) {
        closeModal('login-modal');
    }
};

/* =========================================
   FAQ LOGIC
   ========================================= */
window.toggleFaq = function (button) {
    const answer = button.nextElementSibling;
    const icon = button.querySelector('span:last-child');

    // Toggle hidden class
    if (answer.classList.contains('hidden')) {
        answer.classList.remove('hidden');
        icon.textContent = '-';
        icon.style.color = 'white';
    } else {
        answer.classList.add('hidden');
        icon.textContent = '+';
        icon.style.color = 'var(--accent)';
    }
};

/* =========================================
   PRICING LOGIC
   ========================================= */
window.updatePrice = function (vehicleType) {
    const priceUsage = document.getElementById('price-usage');
    const price24h = document.getElementById('price-24h');
    const priceWork = document.getElementById('price-work');
    const priceNight = document.getElementById('price-night');

    // Reset all vehicle cards
    document.querySelectorAll('.vehicle-card').forEach(card => {
        card.classList.remove('selected');
        card.style.background = '';
        card.style.transform = '';
        card.style.boxShadow = '';
        const badge = card.querySelector('p:last-child');
        if (badge && badge.textContent.includes('SELECCION')) {
            badge.textContent = 'SELECCIONAR';
            badge.style.background = 'transparent';
            badge.style.color = 'var(--accent)';
        }
    });

    // Highlight selected card
    const activeCard = document.getElementById(`card-${vehicleType}`);
    if (activeCard) {
        activeCard.classList.add('selected');
        const badge = activeCard.querySelector('p:last-child');
        if (badge) {
            badge.textContent = '✓ SELECCIONADO';
            badge.style.background = 'var(--accent)';
            badge.style.color = '#000';
            badge.style.fontWeight = 'bold';
        }
    }

    // Define Prices
    let pUsage, p24h, pWork, pNight;

    if (vehicleType === 'moto') {
        pUsage = '0,03€';
        p24h = '70€';
        pWork = '45€';
        pNight = '30€';
    } else if (vehicleType === 'van') {
        pUsage = '0,08€';
        p24h = '180€';
        pWork = '120€';
        pNight = '90€';
    } else { // Coche (Default)
        pUsage = '0,05€';
        p24h = '120€';
        pWork = '85€';
        pNight = '60€';
    }

    // Update DOM
    if (priceUsage) priceUsage.innerHTML = `${pUsage} <span style="font-size: 0.9rem; color: white;">/ min</span>`;
    if (price24h) price24h.innerHTML = `${p24h} <span style="font-size: 1rem; color: white;">/ mes</span>`;
    if (priceWork) priceWork.innerHTML = `${pWork} <span style="font-size: 1rem;">/ mes</span>`;
    if (priceNight) priceNight.innerHTML = `${pNight} <span style="font-size: 1rem;">/ mes</span>`;

    // Smooth scroll to pricing section
    const pricingSection = document.getElementById('pricing');
    if (pricingSection) {
        pricingSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
};
