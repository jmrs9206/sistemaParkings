export type StationStatus = 'L' | 'O' | 'M';

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  timestamp: string;
}

export interface Parking {
  idParking: number;
  nombre: string;
  zonas: Zona[];
}

export interface Zona {
  idZona: number;
  nombre: string;
  estaciones: Estacion[];
}

export interface Estacion {
  idEstacion: number;
  codigoEstacion: string;
  estadoActual: 'L' | 'O' | 'M';
}
