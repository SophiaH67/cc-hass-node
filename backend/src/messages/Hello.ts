export interface CtSHello {
  type: "hello";
  computerId: number;
  computerLabel: string;
  sensors: CtSSensorRegistration[];
}

export interface CtSSensorRegistration {
  id: string; // Used in home assistant
  label: string; // Used in the UI
  type: string; // Sensor type
}

export interface StCHello {
  type: "hello";
  ok: boolean;
}
