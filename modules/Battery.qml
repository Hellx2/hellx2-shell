import qs.common
import Quickshell.Services.UPower

NButton {
	property var device: UPower.devices.values.filter(x => x.isLaptopBattery)[0]
	content: `${(device.percentage < 0.8 ? (device.percentage < 0.6 ? (device.percentage < 0.4 ? (device.percentage < 0.2 ? "" : "") : "") : "") : "")}`
		+ ` ${UPower.onBattery ? '-' : '+'}: ${Math.round(device.percentage * 100)}% `
		+ `(${UPower.onBattery ? Math.floor(device.timeToEmpty / 3600) : Math.floor(device.timeToFull / 3600)}`
		+ `:${String(Math.floor(UPower.onBattery ? device.timeToEmpty / 60 % 60 : device.timeToFull / 60 % 60)).padStart(2, 0)})`

}
