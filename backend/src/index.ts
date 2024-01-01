import { WebSocketServer, WebSocket } from "ws";
import { CtSHello, StCHello } from "./messages/Hello";
import { HassEntity } from "./homeassistant";
import { CtSBaseMessage } from "./messages/index";

const wss = new WebSocketServer({ port: 8080 });

// Map of computers; key is the computer's ID, value is the WebSocket
const clients = new Map<number, Computer>();

class Computer {
  private id: number;
  private label: string;
  private sensors: HassEntity[];

  constructor(public ws: WebSocket, message: CtSHello) {
    this.id = message.computerId;
    this.label = message.computerLabel;
    this.sensors = [];

    for (const sensor of message.sensors) {
      const entity = new HassEntity(sensor.label, sensor.type, sensor.id);
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
}

wss.on("connection", function connection(ws) {
  console.log("New connection");
  ws.on("error", console.error);

  ws.on("message", async function message(data) {
    const message = JSON.parse(data.toString()) as CtSBaseMessage;
    let client: Computer | undefined;

    switch (message.type) {
      case "hello":
        const hello = message as CtSHello;
        if (clients.has(hello.computerId)) {
          const existing = clients.get(hello.computerId)!;
          await existing.destroy();
        }

        client = new Computer(ws, hello);
        break;
    }
  });

  ws.on("close", async function close() {
    for (const [_, client] of clients.entries()) {
      if (client.ws === ws) {
        await client.destroy();
        break;
      }
    }
  });
});
