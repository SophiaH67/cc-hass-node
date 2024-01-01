# Cc-hass-node

This project lets you expose sensors and controls from computercraft to home assistant.

Communication is purely done over websockets, so that events can be pushed to and from home assistant.

## Local Development

To start up home assistant and mosquitto, simply run `docker-compose up -d` in the root of this project.

1. Go through the setup wizard of home assistant at http://localhost:8123
2. Add the mqtt integration with broker `mqtt` and port `1883`. No credentials are needed.
