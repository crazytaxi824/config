#!/usr/bin/osascript

-- 获取电池信息
on getBatteryInfo()
	try
		set batteryInfo to do shell script "pmset -g batt"
		
		-- 获取电池电量
		set batteryLevel to (do shell script "echo " & quoted form of batteryInfo & " | grep -Eo '[0-9]+%' | head -1 | sed 's/%//'") as integer
		
		-- 获取充电状态
		set chargingStatus to ""
		if batteryInfo contains "discharging" then
			set chargingStatus to "discharging"
		else
			set chargingStatus to "charging"
		end if
		
		return {batteryLevel, chargingStatus}
	on error
		-- 如果获取失败，返回错误值
		return {-1, "unknown"}
	end try
end getBatteryInfo

set {batteryLevel, chargingStatus} to getBatteryInfo()

-- 如果电池低于 n% 且未在充电，发送通知
if batteryLevel ≤ 35 and chargingStatus is not "charging" then
	display notification "当前电池电量：" & batteryLevel & "%，请及时充电！" with title "⚠️ 电池电量低" sound name "Glass"
end if