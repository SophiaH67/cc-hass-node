import { HassDeviceClasses } from "../homeassistant";

export interface CtSHello {
  type: "hello";
  computerId: number;
  computerLabel: string;
  computerModel: string;
  sensors: CtSSensorRegistration[];
}

export interface CtSSensorRegistration {
  id: string; // Used in home assistant
  label: string; // Used in the UI
  type: string; // Sensor type
  readonly: boolean; // Whether the sensor is readonly
  device_class?: HassDeviceClasses | undefined;
  value_template?: string | undefined;
  command_template?: string | undefined;
}
