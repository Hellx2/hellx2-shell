import qs.common
import Quickshell.Services.UPower

NButton {
	property var device: UPower.devices.values.filter(x => x.isLaptopBattery)[0]
	content: `${(device.percentage < 80 ? (device.percentage < 60 ? (device.percentage < 40 ? (device.percentage < 20 ? "" : "") : "") : "") : "")}`
		+ ` ${UPower.onBattery ? '-' : '+'}: ${Math.round(device.percentage * 100)}% `
		+ `(${UPower.onBattery ? Math.floor(device.timeToEmpty / 3600) : Math.floor(device.timeToFull / 3600)}`
		+ `:${String(Math.floor(UPower.onBattery ? device.timeToEmpty / 60 % 60 : device.timeToFull / 60 % 60)).padStart(2, 0)})`

}
