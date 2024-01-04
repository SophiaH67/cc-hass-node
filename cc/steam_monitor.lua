local homeassistant = require("homeassistant")

homeassistant.register_sensor("network_stress", "America Network Stress", "number", nil, "battery")
homeassistant.register_sensor(
	"network_stress_capacity",
	"America Network Stress Capacity",
	"number",
	nil,
	nil,
	nil,
	nil,
	0,
	2147483647
)

function watch_stress()
	local p = peripheral.wrap("right")
	while true do
		local stress_capacity = p.getStressCapacity()
		local stress = p.getStress()
		local stress_percentage = stress / stress_capacity * 100
		homeassistant.send_value("network_stress", stress_percentage)
		homeassistant.send_value("network_stress_capacity", stress_capacity)

		os.sleep(1)
	end
end

homeassistant.register_sensor("engine_speed", "America Engine Speed", "number", nil, nil, nil, nil, 0, 256)

function watch_speed()
	local p = peripheral.wrap("left")
	while true do
		local speed = p.getSpeed()
		-- Convert speed to positive
		if speed < 0 then
			speed = speed * -1
		end
		homeassistant.send_value("engine_speed", speed)

		os.sleep(1)
	end
end

print("Starting watcher")
parallel.waitForAny(homeassistant.run, watch_stress, watch_speed)
print("Watcher stopped")
