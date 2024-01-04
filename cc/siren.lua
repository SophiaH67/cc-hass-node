local dfpwm = require("cc.audio.dfpwm")
local homeassistant = require("homeassistant")

local stopRing = false

local speaker = peripheral.find("speaker")
function ring_loop()
	while true do
		os.pullEvent("siren_ring")
		homeassistant.send_value("meth_kitchen_siren", '{"state":"ON"}')
		local decoder = dfpwm.make_decoder()
		for chunk in io.lines("foorhout.dfpwm", 16 * 1024) do
			local buffer = decoder(chunk)

			while not speaker.playAudio(buffer) do
				os.pullEvent("speaker_audio_empty")
			end

			if stopRing then
				break
			end
		end

		stopRing = false
		homeassistant.send_value("meth_kitchen_siren", '{"state":"OFF"}')
	end
end

homeassistant.register_sensor("meth_kitchen_siren", "Meth Kitchen Siren", "siren", function(value)
	decoded = textutils.unserializeJSON(value)
	if decoded.state == "ON" then
		stopRing = false
		os.queueEvent("siren_ring")
	else
		stopRing = true
		speaker.stop()
		os.queueEvent("speaker_audio_empty")
	end
end, nil, nil, nil, 0, 1)

print("Starting watcher")
parallel.waitForAny(homeassistant.run, ring_loop)
print("Watcher stopped")
