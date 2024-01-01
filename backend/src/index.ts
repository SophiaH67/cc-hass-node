import { WebSocketServer, WebSocket } from "ws";
import { CtSHello } from "./messages/Hello";
import { HassEntity } from "./homeassistant";
import { CtSBaseMessage } from "./messages/index";
import { CtSValue } from "./messages/Value";

const wss = new WebSocketServer({ port: 8080 });

// Map of computers; key is the computer's ID, value is the WebSocket
const clients = new Map<number, Computer>();

class Computer {
  public readonly id: number;
  public readonly label: string;
  private sensors: HassEntity[];

  constructor(public ws: WebSocket, message: CtSHello) {
    this.id = message.computerId;
    this.label = message.computerLabel;
    this.sensors = [];

    for (const sensor of message.sensors) {
      const entity = new HassEntity(
        this.id,
        this.label,
        message.computerModel,
        sensor.label,
        sensor.type,
        sensor.id,
        sensor.readonly,
        sensor.device_class,
        sensor.value_template,
        sensor.command_template,
        sensor.min,
        sensor.max,
        ws
      );
      this.sensors.push(entity);
    }

    if (clients.has(this.id))
      throw new Error(`Computer ${this.id} is already registered`);

    clients.set(this.id, this);
  }

  public async destroy() {
    this.ws.close();
    await Promise.all(this.sensors.map((s) => s.destroy()));
    clients.delete(this.id);
  }

  public getSensor(id: string) {
    return this.sensors.find((s) => s.non_unique_id === id);
  }
}

wss.on("connection", function connection(ws) {
  let client: Computer | undefined;
  console.log("New connection");
  ws.on("error", console.error);

  ws.on("message", async function message(data) {
    const message = JSON.parse(data.toString()) as CtSBaseMessage;

    switch (message.type) {
      case "hello":
        const hello = message as CtSHello;
        if (clients.has(hello.computerId)) {
          const existing = clients.get(hello.computerId)!;
          await existing.destroy();
        }

        client = new Computer(ws, hello);
        console.log(`Registered computer ${client.id} (${client.label})`);
        break;

      case "value":
        if (!client) throw new Error("Client not registered");
        const value = message as CtSValue;
        const entity = client!.getSensor(value.sensorId);
        if (entity) await entity.setValue(value.value);
        else
          throw new Error(
            `Computer ${client.id} (${client.label}) tried to set value for unknown sensor ${value.sensorId}`
          );
    }
  });

  ws.on("close", async function close() {
    console.log("Connection closed");
    for (const [_, client] of clients.entries()) {
      if (client.ws === ws) {
        await client.destroy();
        break;
      }
    }
  });
});
