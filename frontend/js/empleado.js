const API = 'http://localhost:8080/api';

function classifyType(codigoEstacion){
  // Heurística temporal: pares → Abonado, impares → Ocasional
  try {
    const num = parseInt((codigoEstacion||'').replace(/\D/g,'').slice(-1),10);
    return (num % 2 === 0) ? 'ABONADO' : 'OCASIONAL';
  } catch(e){ return 'OCASIONAL'; }
}

function buildParkingCard(p){
  // Agregar conteos por estado
  let libres=0, ocupadas=0, mant=0, libresAb=0, libresOc=0;
  const stations = [];

  (p.zonas||[]).forEach(z => {
    (z.estaciones||[]).forEach(e => {
      const estado = (e.estadoActual||'').toUpperCase();
      const tipo = classifyType(e.codigoEstacion);
      if (estado === 'L') { 
        libres++; 
        if (tipo==='ABONADO') libresAb++; else libresOc++;
      }
      else if (estado === 'O') { ocupadas++; }
      else if (estado === 'M') { mant++; }
      stations.push({ codigo: e.codigoEstacion, estado, tipo });
    });
  });

  const wrap = document.createElement('div');
  wrap.className = 'emp-card';
  wrap.innerHTML = `
    <h3>${p.nombre}</h3>
    <div class="kpis">
      <div class="kpi">Capacidad Total: <strong>${p.capacidadTotal ?? '—'}</strong></div>
      <div class="kpi">Libres: <strong>${libres}</strong> <span class="badge b-libre">L</span></div>
      <div class="kpi">Ocupadas: <strong>${ocupadas}</strong> <span class="badge b-ocupada">O</span></div>
      <div class="kpi">Mantenimiento: <strong>${mant}</strong> <span class="badge b-mant">M</span></div>
      <div class="kpi">Libres Ocasionales: <strong>${libresOc}</strong></div>
      <div class="kpi">Libres Abonados: <strong>${libresAb}</strong></div>
    </div>
    <div class="legend">
      <span><span class="dot dot-l"></span> Libre (L)</span>
      <span><span class="dot dot-o"></span> Ocupada (O)</span>
      <span><span class="dot dot-m"></span> Mantenimiento (M)</span>
    </div>
    <div class="stations" id="st-${p.idParking}"></div>
  `;

  const grid = wrap.querySelector(`#st-${p.idParking}`);
  stations.forEach(s => {
    const item = document.createElement('div');
    item.className = 'station';
    item.innerHTML = `
      <div class="st-head">
        <strong class="st-code">${s.codigo}</strong>
        <span class="tag ${s.tipo==='ABONADO'?'t-ab':'t-oc'}">${s.tipo}</span>
      </div>
      <small>Estado: <span class="st-status st-status-${s.estado}">${s.estado}</span></small>
    `;
    grid.appendChild(item);
  });

  return wrap;
}

function load(){
  const root = document.getElementById('emp-root');
  if (!root) return;
  root.innerHTML = '<div class="card">Conectando con servidor...</div>';
  fetch(`${API}/parkings/status`)
    .then(r => r.json())
    .then(j => {
      if (j.success) {
        root.innerHTML = '';
        const grid = document.createElement('div');
        grid.className = 'emp-grid';
        j.data.forEach(p => grid.appendChild(buildParkingCard(p)));
        root.appendChild(grid);
      } else {
        root.innerHTML = `<div class="card">${j.message||'No hay datos'}</div>`;
      }
    })
    .catch(() => {
      root.innerHTML = '<div class="card card-error">Error de conexión con API</div>';
    });
}

document.addEventListener('DOMContentLoaded', load);
