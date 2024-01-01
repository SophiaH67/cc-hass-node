import { WebSocketServer, WebSocket } from "ws";
import { CtSBaseMessage } from "./messages";
import { StCHello } from "./messages/Hello";
import { HassEntity } from "./homeassistant";

const wss = new WebSocketServer({ port: 8080 });

interface Computer {
  ws: WebSocket;
  id: number;
  label: string;
  // sensors
}

function waitForEnter() {
  return new Promise((resolve) => {
    process.stdin.once("data", () => {
      resolve(1);
    });
  });
}



// // Map of computers; key is the computer's ID, value is the WebSocket
// const clients = new Map<number, Computer>();

// wss.on("connection", function connection(ws) {
//   ws.on("error", console.error);

//   ws.on("message", function message(data) {
//     const message = JSON.parse(data.toString()) as CtSBaseMessage;

//     switch (message.type) {
//       case "hello":
//         clients.set(message.computerId, ws);
//         ws.send(
//           JSON.stringify({
//             type: "hello",
//             ok: true,
//           } as StCHello)
//         );
//         break;
//     }
//   });

//   ws.on("open", function open() {
//     console.log(`Client connected from ${ws.url}`);
//   });
// });
