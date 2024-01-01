import "dotenv/config";
import mqtt from "mqtt";

const homeassistant = mqtt.connect("mqtt://localhost:1883");

type HassDeviceClasses =
  | "date"
  | "enum"
  | "timestamp"
  | "apparent_power"
  | "aqi"
  | "atmospheric_pressure"
  | "battery"
  | "carbon_monoxide"
  | "carbon_dioxide"
  | "current"
  | "data_rate"
  | "data_size"
  | "distance"
  | "duration"
  | "energy"
  | "energy_storage"
  | "frequency"
  | "gas"
  | "humidity"
  | "illuminance"
  | "irradiance"
  | "moisture"
  | "monetary"
  | "nitrogen_dioxide"
  | "nitrogen_monoxide"
  | "nitrous_oxide"
  | "ozone"
  | "ph"
  | "pm1"
  | "pm10"
  | "pm25"
  | "power_factor"
  | "power"
  | "precipitation"
  | "precipitation_intensity"
  | "pressure"
  | "reactive_power"
  | "signal_strength"
  | "sound_pressure"
  | "speed"
  | "sulphur_dioxide"
  | "temperature"
  | "volatile_organic_compounds"
  | "volatile_organic_compounds_parts"
  | "voltage"
  | "volume"
  | "volume_storage"
  | "water"
  | "weight"
  | "wind_speed";

/**
 * This class is used to create a Home Assistant entity.
 *
 * When an instance of this class is created, it will automatically be
 * registered with Home Assistant.
 * 
 * @example
 * (async () => {
  const ha = new HassEntity(
    "Test Sensor",
    "sensor",
    "test_sensor",
  );

  await ha.setValue("on");
  await ha.setValue("off");
  await ha.destroy();
})();
 */
export class HassEntity {
  constructor(
    private hass_name: string,
    private sensor_type: string,
    private unique_id: string,
    private device_class?: HassDeviceClasses | undefined,
    private value_template?: string | undefined,
    private command_template?: string | undefined
  ) {
    homeassistant.publish(
      this.introductionTopic,
      JSON.stringify(this.hassIntroductionMessage)
    );
    homeassistant.publish(this.availabilityTopic, "online");
  }

  public async destroy() {
    await homeassistant.publishAsync(this.availabilityTopic, "offline");
  }

  private get hassIntroductionMessage() {
    return {
      name: this.hass_name,
      unique_id: this.unique_id,
      device_class: this.device_class,
      state_topic: this.stateTopic,
      command_topic: this.commandTopic,
      availability_topic: this.availabilityTopic,
      value_template: this.value_template,
      command_template: this.command_template,
    };
  }

  private get introductionTopic() {
    return `homeassistant/${this.sensor_type}/${this.unique_id}/config`;
  }

  private get stateTopic() {
    return `homeassistant/${this.sensor_type}/${this.unique_id}/state`;
  }

  private get commandTopic() {
    return `homeassistant/${this.sensor_type}/${this.unique_id}/set`;
  }

  private get availabilityTopic() {
    return `homeassistant/${this.sensor_type}/${this.unique_id}/availability`;
  }

  public async setValue(value: string) {
    await homeassistant.publishAsync(this.stateTopic, value);
  }
}
