local homeassistant = require("homeassistant")

homeassistant.register_sensor("redstone_left", "Redstone Left", "sensor", nil)

function watch_redstone()
	while true do
		os.pullEvent("redstone")
		local value = redstone.getAnalogInput("left")
		homeassistant.send_value("redstone_left", value)
	end
end

print("Starting watcher")
parallel.waitForAny(homeassistant.run, watch_redstone)
print("Watcher stopped")
