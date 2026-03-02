/**
 * Portal Abonado - Lógica de Interfaz
 */

document.addEventListener('DOMContentLoaded', () => {
    const btnConsultar = document.getElementById('btn-consultar');
    const btnDescargar = document.getElementById('btn-descargar');
    const resContainer = document.getElementById('estancias-res');

    if (btnConsultar) {
        btnConsultar.addEventListener('click', () => {
            const inicio = document.getElementById('f-inicio').value;
            const fin = document.getElementById('f-fin').value;

            if (!inicio || !fin) {
                alert('Por favor, seleccione un rango de fechas.');
                return;
            }

            resContainer.innerHTML = '<p class="text-muted">Consultando estancias...</p>';
            
            // Simulación de consulta a API
            setTimeout(() => {
                resContainer.innerHTML = `
                    <table class="vehicle-table">
                        <thead>
                            <tr>
                                <th>Fecha</th>
                                <th>Estación</th>
                                <th>Tiempo</th>
                                <th>Importe</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>15/02/2026</td>
                                <td>P1-45</td>
                                <td>02:15h</td>
                                <td>Incluido</td>
                            </tr>
                            <tr>
                                <td>10/02/2026</td>
                                <td>P1-45</td>
                                <td>05:40h</td>
                                <td>Incluido</td>
                            </tr>
                        </tbody>
                    </table>
                `;
            }, 800);
        });
    }

    if (btnDescargar) {
        btnDescargar.addEventListener('click', () => {
            alert('Generando factura en PDF... La descarga comenzará en breve.');
        });
    }
});
