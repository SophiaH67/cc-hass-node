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
	local computer_model
	if turtle then
		if term.isColor() then
			computer_model = "Advanced_Turtle"
		else
			computer_model = "Basic_Turtle"
		end
	else
		if term.isColor() then
			computer_model = "Advanced_Computer"
		else
			computer_model = "Basic_Computer"
		end
	end

	hello = {
		type = "hello",
		computerId = os.getComputerID(),
		computerLabel = os.getComputerLabel(),
		computerModel = computer_model,
		sensors = homeassistant.sensors,
	}

	print("Sending hello message")

	json = textutils.serializeJSON(hello)
	ws.send(json)

	homeassistant.ws = ws
	homeassistant.running = true

	while true do
		local event, url, message
		repeat
			event, url, message = os.pullEvent("websocket_message")
		until url == url

		message = textutils.unserializeJSON(message)

		if message.type == "value" then
			local callback = homeassistant.value_callbacks[message.sensorId]
			if callback then
				print("Got message")
				print(textutils.serializeJSON(message))
				callback(message.value)
			else
				print("No callback for sensor " .. message.sensorId)
			end
		end
	end
end

-- value_callback can be nil, when not nil, homeassistant will be
-- informed that it cannot be written to
local function register_sensor(
	id,
	label,
	type,
	value_callback,
	device_class,
	value_template,
	command_template,
	min,
	max
)
	if homeassistant.running then
		return false, "can only register sensors before initialization"
	end

	sensor = {
		id = id,
		label = label,
		type = type,
		readonly = value_callback == nil,
		device_class = device_class,
		value_template = value_template,
		command_template = command_template,
		min = min,
		max = max,
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
