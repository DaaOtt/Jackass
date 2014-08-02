surface.CreateFont("JackassMoney", {
	font = "321impact",
	size = 48,
	outline = true,
	antialias = false,
})
require("easings")
local w = ScrW()
local h = ScrH()
local money = {
	prefix = "$",
	font = "JackassMoney",
	w = w / 32,
	h = h / 32,
	c = Color(255, 255, 255),
}
local profit = {
	prefix = "+$",
	font = "JackassMoney",
	w = w / 32 - 24,
	h = h / 32 + 48,
	c = Color(0, 128, 0),
	a = 255,
}
local profit2 = setmetatable({}, {__index = profit})
local ease = 0
local easing = false


net.Receive("stunt_begin", function()
	profit2 = setmetatable({}, {__index = profit})
	easing = false
	ease = 0
end)

net.Receive("stunt_success", function(len)
	easing = true
	ease = 0
end)

net.Receive("stunt_failure", function(len)
	profit2.c = Color(255, 110, 110)
	timer.Simple(2, function() profit2.a = 0 end)
end)

local function drawmoney()
	draw.SimpleText(money.prefix .. LocalPlayer():GetNWInt("money"), money.font, money.w, money.h, money.c, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(profit2.prefix .. LocalPlayer():GetRagdollEntity():GetNWInt("profits"), profit2.font, profit2.w, profit2.h, Color(profit2.c.r, profit2.c.g, profit2.c.b, profit2.a), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	if easing then
		profit2.h = profit.h - easings.easeInBack(ease, 0.5, 0, 1) * 48
		profit2.a = profit.a - easings.easeInBack(ease, 0.5, 0, 1) * 255
		ease = ease + FrameTime()
		if ease >= 0.5 then
			easing = false
		end
	end
end
hook.Add("HUDPaint", "drawmoney", drawmoney) 
