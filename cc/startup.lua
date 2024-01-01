local url = "wss://likes-murray-bd-systematic.trycloudflare.com"

http.websocketAsync(url)

-- Make sure connection is established
local event, url, ws
repeat
	event, url, ws = os.pullEvent("websocket_success", "websocket_failure")

	if event == "websocket_failure" then
		print("Failed to connect to ", url)
		os.exit(1)
	end

until url == url

print("Succesfully connected")

-- Send our hello message
hello = {
	type = "hello",
	computerId = os.getComputerID(),
	computerLabel = os.getComputerLabel(),
	sensors = {
		{
			id = "test_sensor",
			label = "Test",
			type = "sensor",
		},
	},
}

print("Sending hello message")

json = textutils.serializeJSON(hello)
ws.send(json)

print("Waiting 10 seconds")
-- Wait a bit
os.sleep(10)

print("Closing connection")
-- Close the connection
ws.close()
