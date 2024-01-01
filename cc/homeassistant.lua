local homeassistant = {
	running = false,
	sensors = {},
	value_callbacks = {}, -- { sensor_id = callback }
}
local url = "wss://likes-murray-bd-systematic.trycloudflare.com"

local function run()
	if homeassistant.running then
		return false, "already running"
	end

	success, err = http.websocketAsync(url)
	if not success then
		return false, err
	end

	local event, url, ws
	repeat
		event, url, ws = os.pullEvent("websocket_success", "websocket_failure")

		if event == "websocket_failure" then
			return false, "failed to connect"
		end

	until url == url

	-- Send our hello message
	hello = {
		type = "hello",
		computerId = os.getComputerID(),
		computerLabel = os.getComputerLabel(),
		sensors = homeassistant.sensors,
	}

	print("Sending hello message")

	json = textutils.serializeJSON(hello)
	ws.send(json)

	homeassistant.ws = ws
	homeassistant.running = true

	while true do
		local event, url, ws, message = os.pullEvent("websocket_message")

		print("Got message: " .. message)
		message = textutils.unserializeJSON(message)

		if message.type == "value" then
			local callback = homeassistant.value_callbacks[message.id]
			if callback then
				callback(message.value)
			else
				print("No callback for sensor " .. message.id)
			end
		end
	end
end

-- value_callback can be nil, when not nil, homeassistant will be
-- informed that it cannot be written to
local function register_sensor(id, label, type, value_callback)
	if homeassistant.running then
		return false, "can only register sensors before initialization"
	end

	sensor = {
		id = id,
		label = label,
		type = type,
	}
	homeassistant.sensors[#homeassistant.sensors + 1] = sensor
	homeassistant.value_callbacks[id] = value_callback
end

local function send_value(sensorId, value)
	if not homeassistant.running then
		return false, "not running"
	end

	message = {
		type = "value",
		sensorId = sensorId,
		value = tostring(value),
	}

	json = textutils.serializeJSON(message)
	homeassistant.ws.send(json)
end

return {
	run = run,
	register_sensor = register_sensor,
	send_value = send_value,
}
