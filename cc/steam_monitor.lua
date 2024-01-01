local homeassistant = require("homeassistant")

homeassistant.register_sensor("network_stress", "America Network Stress", "number")
homeassistant.register_sensor("network_stress_capacity", "America Network Stress Capacity", "number")

function watch_stress()
	local p = peripheral.wrap("right")
	while true do
		local stress = p.getStress()
		local stress_capacity = p.getStressCapacity()
		homeassistant.send_value("network_stress", stress)
		homeassistant.send_value("network_stress_capacity", stress_capacity)

		os.sleep(1)
	end
end

homeassistant.register_sensor("engine_speed", "America Engine Speed", "number")

function watch_speed()
	local p = peripheral.wrap("left")
	while true do
		local speed = p.getSpeed()
    print("Sending speed: ", speed)
		homeassistant.send_value("engine_speed", speed)

		os.sleep(1)
	end
end

print("Starting watcher")
parallel.waitForAny(homeassistant.run, watch_stress, watch_speed)
print("Watcher stopped")
