local homeassistant = require("homeassistant")

local max_capacity = 360000

homeassistant.register_sensor("america_lava", "America Lava", "number", nil, "battery")
homeassistant.register_sensor(
	"america_lava_stored",
	"America Lava Stored",
	"number",
	nil,
	"volume_storage",
	nil,
	nil,
	0,
	max_capacity
)

function watch_lava()
	local p = peripheral.wrap("right")
	while true do
		local lava = 0
		local tanks = p.tanks()
		for i = 1, #tanks do
			lava = lava + tanks[i].amount
		end
		percentage = lava / max_capacity * 100
		homeassistant.send_value("america_lava_stored", lava)
		homeassistant.send_value("america_lava", percentage)
		os.sleep(1)
	end
end

print("Starting watcher")
parallel.waitForAny(homeassistant.run, watch_lava)
print("Watcher stopped")
