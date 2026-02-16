export type StationStatus = 'L' | 'O' | 'M';

export interface Estacion {
  idEstacion: number;
  codigoEstacion: string;
  idSensor: string;
  estadoActual: StationStatus;
}

export interface Zona {
  idZona: number;
  nombre: string;
  activo: boolean;
  estaciones: Estacion[];
}

export interface Parking {
  idParking: number;
  nombre: string;
  idLocalidad: number;
  activo: boolean;
  zonas: Zona[];
}
