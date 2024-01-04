local homeassistant = require("homeassistant")

local max_capacity = 72000

homeassistant.register_sensor("saphic_cargo_lava", "Saphic Cargo Lava", "number", nil, "battery")
homeassistant.register_sensor(
	"saphic_cargo_lava_stored",
	"Saphic Lava Stored",
	"number",
	nil,
	"volume_storage",
	nil,
	nil,
	0,
	max_capacity
)

function watch_lava()
	local p = peripheral.wrap("bottom")
	while true do
		local lava = 0
		local tanks = p.tanks()
		for i = 1, #tanks do
			lava = lava + tanks[i].amount
		end
		percentage = lava / max_capacity * 100
		homeassistant.send_value("saphic_cargo_lava_stored", lava)
		homeassistant.send_value("saphic_cargo_lava", percentage)
		os.sleep(1)
	end
end

homeassistant.register_sensor("saphic_cargo_stress", "Saphic Cargo Stress", "number", nil, "battery")
homeassistant.register_sensor(
	"saphic_cargo_stress_capacity",
	"Saphic Cargo Stress",
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
		homeassistant.send_value("saphic_cargo_stress_capacity", stress_capacity)
		homeassistant.send_value("saphic_cargo_stress", stress_percentage)
		os.sleep(1)
	end
end

print("Starting watcher")
parallel.waitForAny(homeassistant.run, watch_lava, watch_stress)
print("Watcher stopped")
