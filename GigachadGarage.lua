--=====================================================================--
--  GIGACHAD GARAGE  |  UNIVERSAL HUB  |  v1.6.0
--  Taller Spacious UI + Fly Modes + Sprint + Crosshair + ESP Boxes.
--
--  Toggle UI : Right Shift
--  Executor  : Solara (works on most executors too)
--=====================================================================--

-- // Boot loader — appears instantly, shows every init step --------------
local Boot = {} do
	local TweenService0 = game:GetService("TweenService")

	local sg = Instance.new("ScreenGui")
	sg.Name = "GCG_Boot"
	sg.IgnoreGuiInset = true
	sg.ResetOnSpawn = false
	sg.DisplayOrder = 1000
	do
		local hooked = pcall(function()
			sg.Parent = (gethui and gethui()) or game:GetService("CoreGui")
		end)
		if not hooked or not sg.Parent then
			sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		end
	end

	local root
	if not pcall(function() root = Instance.new("CanvasGroup") end) or not root then
		root = Instance.new("Frame")
	end
	root.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	root.BackgroundTransparency = 0
	root.BorderSizePixel = 0
	root.Size = UDim2.fromScale(1, 1)
	root.ZIndex = 200
	root.Parent = sg

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.fromScale(0.5, 0.44)
	title.Size = UDim2.fromOffset(420, 22)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 15
	title.TextColor3 = Color3.fromRGB(238, 238, 242)
	title.Text = "G I G A C H A D  G A R A G E"
	title.Parent = root

	local status = Instance.new("TextLabel")
	status.BackgroundTransparency = 1
	status.AnchorPoint = Vector2.new(0.5, 0.5)
	status.Position = UDim2.fromScale(0.5, 0.475)
	status.Size = UDim2.fromOffset(420, 14)
	status.Font = Enum.Font.Gotham
	status.TextSize = 11
	status.TextColor3 = Color3.fromRGB(152, 152, 160)
	status.Text = "CONNECTING"
	status.Parent = root

	local barBg = Instance.new("Frame")
	barBg.AnchorPoint = Vector2.new(0.5, 0.5)
	barBg.Position = UDim2.new(0.5, 0, 0.5, 24)
	barBg.Size = UDim2.fromOffset(190, 3)
	barBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	barBg.BackgroundTransparency = 0.92
	barBg.BorderSizePixel = 0
	barBg.Parent = root
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = barBg

	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.fromScale(0.05, 1)
	barFill.BackgroundColor3 = Color3.fromRGB(10, 132, 255)
	barFill.BorderSizePixel = 0
	barFill.Parent = barBg
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = barFill

	local detail = Instance.new("TextLabel")
	detail.BackgroundTransparency = 1
	detail.AnchorPoint = Vector2.new(0.5, 0)
	detail.Position = UDim2.new(0.5, 0, 0.5, 44)
	detail.Size = UDim2.new(0.8, 0, 0, 0)
	detail.AutomaticSize = Enum.AutomaticSize.Y
	detail.TextWrapped = true
	detail.Font = Enum.Font.Gotham
	detail.TextSize = 11
	detail.TextColor3 = Color3.fromRGB(255, 138, 128)
	detail.Text = ""
	detail.Visible = false
	detail.Parent = root

	function Boot.Step(text, alpha)
		status.Text = string.upper(text)
		pcall(function()
			TweenService0:Create(barFill,
				TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Size = UDim2.fromScale(alpha, 1) }):Play()
		end)
		task.wait(0.09)
	end

	function Boot.Finish()
		pcall(function()
			TweenService0:Create(root,
				TweenInfo.new(0.38, Enum.EasingStyle.Quint),
				{ GroupTransparency = 1 }):Play()
		end)
		task.delay(0.42, function() sg:Destroy() end)
	end

	function Boot.Error(errText)
		warn("[Gigachad Garage] LOAD ERROR:\n" .. tostring(errText))
		status.TextColor3 = Color3.fromRGB(255, 69, 58)
		status.Text = "LOAD ERROR — SEE CONSOLE (F9)"
		detail.Text = tostring(errText)
		detail.Visible = true
	end
end

-- // Bounded waits — never hangs forever ----------------------------------
Boot.Step("Connecting", 0.05)
do
	local t0 = os.clock()
	while not game:IsLoaded() and os.clock() - t0 < 10 do
		task.wait(0.1)
	end
end
Boot.Step("Waiting for game", 0.12)
do
	local t0 = os.clock()
	while os.clock() - t0 < 5 do
		local cam = workspace.CurrentCamera
		if cam and cam.ViewportSize.X > 0 and cam.ViewportSize.Y > 0 then break end
		task.wait(0.1)
	end
end

-- // Kill any previous session ------------------------------------------
if getgenv and getgenv().GIGACHAD_GARAGE then
	pcall(function() getgenv().GIGACHAD_GARAGE.Unload() end)
	task.wait(0.2)
end

-- // Main body — everything below runs inside a protected call -----------
local ok, err = xpcall(function()

-- // Services -----------------------------------------------------------
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()
local Camera      = workspace.CurrentCamera

local ExecutorName = "Unknown"
pcall(function() ExecutorName = identifyexecutor() end)

-- // Helpers -------------------------------------------------------------
local function new(class, props, children)
	local inst = Instance.new(class)
	local parent = props and props.Parent
	if props then
		props.Parent = nil
		for k, v in pairs(props) do inst[k] = v end
	end
	if children then
		for _, c in ipairs(children) do c.Parent = inst end
	end
	if parent then inst.Parent = parent end
	return inst
end

local function tween(obj, ti, props, style, dir, delay)
	local t = TweenService:Create(obj,
		TweenInfo.new(ti, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out, 0, false, delay or 0),
		props)
	t:Play()
	return t
end

local function damp(current, target, speed, dt)
	local alpha = 1 - math.exp(-speed * math.max(dt, 0))
	return current + (target - current) * alpha
end

local function toHex(c)
	return string.format("#%02X%02X%02X",
		math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

-- // Theme ---------------------------------------------------------------
local Theme = {
	Window     = Color3.fromRGB(16, 16, 20),
	Surface    = Color3.fromRGB(26, 26, 32),
	SurfaceAlt = Color3.fromRGB(43, 43, 51),
	TabBar     = Color3.fromRGB(12, 12, 15),
	Island     = Color3.fromRGB(8, 8, 10),
	Stroke     = Color3.fromRGB(255, 255, 255),
	TextMain   = Color3.fromRGB(242, 242, 248),
	TextDim    = Color3.fromRGB(156, 156, 168),
	TextFaint  = Color3.fromRGB(106, 106, 118),
	Danger     = Color3.fromRGB(255, 69, 58),
	Success    = Color3.fromRGB(48, 209, 88),
	White      = Color3.fromRGB(255, 255, 255),
}

local ACCENTS = {
	{ name = "iOS Blue",    color = Color3.fromRGB(10, 132, 255) },
	{ name = "Purple",      color = Color3.fromRGB(191, 90, 242) },
	{ name = "Pink",        color = Color3.fromRGB(255, 55, 95) },
	{ name = "Chad Red",    color = Color3.fromRGB(255, 69, 58) },
	{ name = "Gold",        color = Color3.fromRGB(255, 214, 10) },
	{ name = "Sigma Green", color = Color3.fromRGB(48, 209, 88) },
}

local Accent = ACCENTS[1].color
local accentTargets = {}
local liveAccents   = {}

local function trackAccent(inst, prop)
	inst[prop] = Accent
	table.insert(accentTargets, { inst, prop })
end

local function setAccent(c)
	Accent = c
	for _, t in ipairs(accentTargets) do
		pcall(function() t[1][t[2]] = c end)
	end
	for _, fn in ipairs(liveAccents) do fn(c) end
end

-- // Connection tracker --------------------------------------------------
local Connections = {}
local function bind(signal, fn)
	local c = signal:Connect(fn)
	table.insert(Connections, c)
	return c
end

local KeybindListening = 0
local LastCaptureTick = 0
local notifyEnabled = true
local islandEnabled = true
local radarEnabled = false
local crosshairEnabled = false

Boot.Step("Building interface", 0.25)

-- // GUI root ------------------------------------------------------------
local Viewport = Camera.ViewportSize
if not Viewport or Viewport.X < 1 or Viewport.Y < 1 then
	Viewport = Vector2.new(1280, 720)
end
local Gui = new("ScreenGui", {
	Name = "GigachadGarage",
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
})
do
	local okParent = pcall(function()
		Gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
	end)
	if not okParent or not Gui.Parent then
		Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
end

bind(Camera:GetPropertyChangedSignal("ViewportSize"), function()
	Viewport = Camera.ViewportSize
end)

-- // Center Crosshair ----------------------------------------------------
local CrosshairHolder = new("Frame", {
	Visible = false,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(24, 24),
	BackgroundTransparency = 1,
	ZIndex = 45,
	Parent = Gui,
})
local chTop = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.fromOffset(2, 6), BackgroundColor3 = Accent, BorderSizePixel = 0, Parent = CrosshairHolder })
local chBot = new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.fromOffset(2, 6), BackgroundColor3 = Accent, BorderSizePixel = 0, Parent = CrosshairHolder })
local chLeft = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(6, 2), BackgroundColor3 = Accent, BorderSizePixel = 0, Parent = CrosshairHolder })
local chRight = new("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(6, 2), BackgroundColor3 = Accent, BorderSizePixel = 0, Parent = CrosshairHolder })
local chCenter = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(3, 3), BackgroundColor3 = Theme.White, BorderSizePixel = 0, Parent = CrosshairHolder })
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = chCenter })
for _, bar in ipairs({ chTop, chBot, chLeft, chRight }) do
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
	trackAccent(bar, "BackgroundColor3")
end

-- // iPhone Dynamic Island -----------------------------------------------
local IslandHolder = new("Frame", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 10),
	Size = UDim2.fromOffset(440, 120),
	ZIndex = 75,
	Parent = Gui,
})

local IslandPill = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 0),
	Size = UDim2.fromOffset(196, 36),
	BackgroundColor3 = Theme.Island,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Parent = IslandHolder,
})
local IslandCorner = new("UICorner", { CornerRadius = UDim.new(0, 18), Parent = IslandPill })
new("UIStroke", { Color = Theme.Stroke, Transparency = 0.88, Thickness = 1, Parent = IslandPill })

local IslandLed = new("Frame", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.fromOffset(12, 18),
	Size = UDim2.fromOffset(8, 8),
	BackgroundColor3 = Accent,
	BorderSizePixel = 0,
	Parent = IslandPill,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = IslandLed })
trackAccent(IslandLed, "BackgroundColor3")

local IslandTitle = new("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(26, 0),
	Size = UDim2.new(1, -36, 0, 36),
	Font = Enum.Font.GothamBold,
	TextSize = 11.5,
	TextColor3 = Theme.TextMain,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Text = "GIGACHAD ISLAND",
	Parent = IslandPill,
})

local IslandSub = new("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(14, 36),
	Size = UDim2.new(1, -28, 0, 16),
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = Theme.TextDim,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Text = "Ready • Right Shift for UI",
	Parent = IslandPill,
})

local IslandActions = new("Frame", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(14, 58),
	Size = UDim2.new(1, -28, 0, 28),
	Parent = IslandPill,
})
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 6),
	Parent = IslandActions,
})

local function makeIslandChip(text, onClick)
	local b = new("TextButton", {
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 10.5,
		TextColor3 = Theme.TextMain,
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(0.25, -4.5, 1, 0),
		AutoButtonColor = false,
		Parent = IslandActions,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = b })
	b.Activated:Connect(onClick)
	return b
end

local islandExpanded = false
local islandPulseToken = 0

local function setIslandExpanded(exp)
	if not islandEnabled then exp = false end
	islandExpanded = exp
	if exp then
		tween(IslandPill, 0.42, { Size = UDim2.fromOffset(376, 98) }, Enum.EasingStyle.Back)
		tween(IslandCorner, 0.35, { CornerRadius = UDim.new(0, 22) })
	else
		tween(IslandPill, 0.36, { Size = UDim2.fromOffset(196, 36) }, Enum.EasingStyle.Quint)
		tween(IslandCorner, 0.32, { CornerRadius = UDim.new(0, 18) })
	end
end

local IslandHit = new("TextButton", {
	Text = "",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 36),
	ZIndex = 3,
	Parent = IslandPill,
})
IslandHit.Activated:Connect(function()
	setIslandExpanded(not islandExpanded)
end)

local function islandPulse(titleText, subText, holdSec)
	if not islandEnabled then return end
	islandPulseToken += 1
	local token = islandPulseToken
	IslandTitle.Text = titleText
	if subText then IslandSub.Text = subText end
	if not islandExpanded then
		tween(IslandPill, 0.32, { Size = UDim2.fromOffset(278, 38) }, Enum.EasingStyle.Back)
	end
	task.delay(holdSec or 2.2, function()
		if token == islandPulseToken and not islandExpanded then
			IslandTitle.Text = "GIGACHAD ISLAND"
			tween(IslandPill, 0.32, { Size = UDim2.fromOffset(196, 36) }, Enum.EasingStyle.Quint)
		end
	end)
end

-- // Radar HUD -----------------------------------------------------------
local RadarFrame = new("Frame", {
	Visible = false,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -18, 1, -18),
	Size = UDim2.fromOffset(156, 156),
	BackgroundColor3 = Theme.Window,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	ZIndex = 40,
	Parent = Gui,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = RadarFrame })
new("UIStroke", { Color = Theme.Stroke, Transparency = 0.88, Thickness = 1.2, Parent = RadarFrame })

new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(1, -18, 0, 1),
	BackgroundColor3 = Theme.Stroke,
	BackgroundTransparency = 0.94,
	BorderSizePixel = 0,
	Parent = RadarFrame,
})
new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(0, 1, 1, -18),
	BackgroundColor3 = Theme.Stroke,
	BackgroundTransparency = 0.94,
	BorderSizePixel = 0,
	Parent = RadarFrame,
})
local RadarSelfDot = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(7, 7),
	BackgroundColor3 = Accent,
	BorderSizePixel = 0,
	ZIndex = 3,
	Parent = RadarFrame,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = RadarSelfDot })
trackAccent(RadarSelfDot, "BackgroundColor3")

local RadarDotsFolder = new("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 2,
	Parent = RadarFrame,
})

new("TextLabel", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -8),
	Size = UDim2.new(1, -20, 0, 12),
	Font = Enum.Font.GothamBold,
	TextSize = 8.5,
	TextColor3 = Theme.TextFaint,
	Text = "RADAR",
	Parent = RadarFrame,
})

-- // Notifications (iOS banners) -----------------------------------------
local NotifHolder = new("Frame", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 54),
	Size = UDim2.fromOffset(400, 600),
	ZIndex = 50,
	Parent = Gui,
})

local notifs = {}
local function layoutNotifs(animate)
	local y = 0
	for _, n in ipairs(notifs) do
		local target = UDim2.fromOffset(0, y)
		if animate then
			tween(n.frame, 0.42, { Position = target }, Enum.EasingStyle.Back)
		else
			n.frame.Position = target
		end
		y += n.frame.AbsoluteSize.Y + 8
	end
end

local function Notify(title, message, duration)
	if islandEnabled then
		islandPulse(title, message, duration or 2.4)
	end
	if not notifyEnabled then return end
	duration = duration or 3.5

	local notif = new("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromOffset(0, -80),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		ZIndex = 51,
		Parent = NotifHolder,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 18), Parent = notif })
	new("UIStroke", { Color = Theme.Stroke, Transparency = 0.9, Parent = notif })
	new("UIPadding", {
		PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		Parent = notif,
	})

	local icon = new("Frame", {
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Accent,
		BorderSizePixel = 0,
		Parent = notif,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = icon })
	trackAccent(icon, "BackgroundColor3")
	new("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.White,
		Text = "✓", Parent = icon,
	})

	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(36, 1),
		Size = UDim2.new(1, -36, 0, 15),
		Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.TextMain,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = title, Parent = notif,
	})
	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(36, 17),
		Size = UDim2.new(1, -36, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.TextDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = message, Parent = notif,
	})

	table.insert(notifs, { frame = notif })
	tween(notif, 0.45, { GroupTransparency = 0 })
	task.defer(function() layoutNotifs(true) end)

	if #notifs > 4 then
		local old = table.remove(notifs, 1)
		tween(old.frame, 0.25, { GroupTransparency = 1, Position = UDim2.fromOffset(0, -60) })
		task.delay(0.3, function() old.frame:Destroy() end)
		task.defer(function() layoutNotifs(true) end)
	end

	task.delay(duration, function()
		if not notif.Parent then return end
		for idx, n in ipairs(notifs) do
			if n.frame == notif then table.remove(notifs, idx) break end
		end
		tween(notif, 0.3, { GroupTransparency = 1, Position = UDim2.fromOffset(0, -40) })
		task.delay(0.32, function()
			if notif.Parent then notif:Destroy() end
		end)
		layoutNotifs(true)
	end)
end

-- // Window shell (taller & more spacious vertically) ------------------
local WINDOW_W, WINDOW_H = 680, 560
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local UIScaleValue = 1
if IsMobile then
	UIScaleValue = math.min((Viewport.X - 16) / WINDOW_W, (Viewport.Y - 16) / WINDOW_H, 1)
	if UIScaleValue < 0.5 then UIScaleValue = 0.5 end
end
local WinW, WinH = WINDOW_W * UIScaleValue, WINDOW_H * UIScaleValue

local Holder = new("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.fromOffset(WINDOW_W, WINDOW_H),
	Position = UDim2.fromOffset((Viewport.X - WinW) / 2, math.max((Viewport.Y - WinH) / 2, 52)),
	Parent = Gui,
})
new("UIScale", { Scale = UIScaleValue, Parent = Holder })

local Shadow = new("ImageLabel", {
	BackgroundTransparency = 1,
	Image = "rbxassetid://6014261993",
	ImageColor3 = Color3.new(0, 0, 0),
	ImageTransparency = 1,
	ScaleType = Enum.ScaleType.Slice,
	SliceCenter = Rect.new(49, 49, 450, 450),
	SliceScale = 1.28,
	Size = UDim2.new(1, 96, 1, 96),
	Position = UDim2.fromOffset(-48, -48),
	Parent = Holder,
})

local Window = new("CanvasGroup", {
	BackgroundColor3 = Theme.Window,
	BackgroundTransparency = 0.02,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	GroupTransparency = 1,
	ClipsDescendants = true,
	Parent = Holder,
})
new("UICorner", { CornerRadius = UDim.new(0, 28), Parent = Window })
new("UIStroke", { Color = Theme.Stroke, Transparency = 0.92, Thickness = 1, Parent = Window })
local WindowScale = new("UIScale", { Scale = 0.92, Parent = Window })

local TopLine = new("Frame", {
	BackgroundColor3 = Accent,
	BackgroundTransparency = 0.5,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 2),
	ZIndex = 3,
	Parent = Window,
})
trackAccent(TopLine, "BackgroundColor3")

-- // Header (status bar) -------------------------------------------------
local Header = new("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 52),
	ZIndex = 2,
	Parent = Window,
})

local TimeLabel = new("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(22, 0),
	Size = UDim2.new(0, 110, 1, 0),
	Font = Enum.Font.GothamBold,
	TextSize = 14.5,
	TextColor3 = Theme.TextMain,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "9:41",
	Parent = Header,
})

local BrandPill = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(208, 32),
	BackgroundColor3 = Theme.Surface,
	BorderSizePixel = 0,
	Parent = Header,
})
new("UICorner", { CornerRadius = UDim.new(0, 16), Parent = BrandPill })
new("UIStroke", { Color = Theme.Stroke, Transparency = 0.9, Parent = BrandPill })

local StatusDot = new("Frame", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.fromOffset(11, 16),
	Size = UDim2.fromOffset(6.5, 6.5),
	BackgroundColor3 = Theme.Success,
	BorderSizePixel = 0,
	Parent = BrandPill,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = StatusDot })

local BrandText = new("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(18, 0),
	Size = UDim2.new(1, -24, 1, 0),
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	TextColor3 = Theme.TextMain,
	RichText = true,
	Text = string.format('GIGACHAD <font color="%s">GARAGE</font>', toHex(Accent)),
	Parent = BrandPill,
})
liveAccents[#liveAccents + 1] = function(c)
	BrandText.Text = string.format('GIGACHAD <font color="%s">GARAGE</font>', toHex(c))
end

local FpsLabel = new("TextLabel", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -22, 0, 0),
	Size = UDim2.new(0, 155, 1, 0),
	Font = Enum.Font.Gotham,
	TextSize = 11.5,
	TextColor3 = Theme.TextDim,
	TextXAlignment = Enum.TextXAlignment.Right,
	Text = "60 FPS  •  0 ms",
	Parent = Header,
})

new("Frame", {
	BackgroundColor3 = Theme.Stroke,
	BackgroundTransparency = 0.94,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 1, -1),
	Size = UDim2.new(1, 0, 0, 1),
	Parent = Header,
})

-- // Search bar with clear button ----------------------------------------
local SearchBarWrap = new("Frame", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 52),
	Size = UDim2.new(1, 0, 0, 46),
	ZIndex = 3,
	Parent = Window,
})

local SearchBox = new("TextBox", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(1, -36, 0, 34),
	BackgroundColor3 = Theme.Surface,
	BorderSizePixel = 0,
	Font = Enum.Font.Gotham,
	TextSize = 12.5,
	TextColor3 = Theme.TextMain,
	PlaceholderText = "Search features across current tab...",
	PlaceholderColor3 = Theme.TextFaint,
	Text = "",
	ClearTextOnFocus = false,
	Parent = SearchBarWrap,
})
new("UICorner", { CornerRadius = UDim.new(0, 11), Parent = SearchBox })
new("UIStroke", { Color = Theme.Stroke, Transparency = 0.92, Parent = SearchBox })
new("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 34), Parent = SearchBox })

local ClearSearchBtn = new("TextButton", {
	Text = "✕",
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	TextColor3 = Theme.TextDim,
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -24, 0.5, 0),
	Size = UDim2.fromOffset(24, 24),
	Visible = false,
	ZIndex = 4,
	Parent = SearchBarWrap,
})
ClearSearchBtn.Activated:Connect(function()
	SearchBox.Text = ""
end)

-- // Content + Tab bar ---------------------------------------------------
local Content = new("Frame", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 98),
	Size = UDim2.new(1, 0, 1, -158),
	ClipsDescendants = true,
	ZIndex = 2,
	Parent = Window,
})

local TabBar = new("Frame", {
	BackgroundColor3 = Theme.TabBar,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 1, -60),
	Size = UDim2.new(1, 0, 0, 60),
	ZIndex = 2,
	Parent = Window,
})
new("Frame", {
	BackgroundColor3 = Theme.Stroke,
	BackgroundTransparency = 0.94,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 1),
	Parent = TabBar,
})

local Pill = new("Frame", {
	BackgroundColor3 = Theme.SurfaceAlt,
	BorderSizePixel = 0,
	Size = UDim2.fromOffset(62, 40),
	Position = UDim2.fromOffset(32, 10),
	ZIndex = 1,
	Parent = TabBar,
})
new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = Pill })
local PillAccentLine = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -3),
	Size = UDim2.fromOffset(22, 2.5),
	BackgroundColor3 = Accent,
	BorderSizePixel = 0,
	Parent = Pill,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = PillAccentLine })
trackAccent(PillAccentLine, "BackgroundColor3")

-- // Icons (pure vector, no images) --------------------------------------
local function buildIcon(kind, parent, color)
	local parts, strokes = {}, {}

	local function part(props)
		props.BackgroundColor3 = color
		props.BorderSizePixel = 0
		props.Parent = parent
		local p = new("Frame", props)
		table.insert(parts, p)
		return p
	end
	local function round(p, r)
		new("UICorner", { CornerRadius = UDim.new(0, r), Parent = p })
	end

	if kind == "player" then
		round(part({ Size = UDim2.fromOffset(7, 7), Position = UDim2.fromOffset(5, 1) }), 8)
		round(part({ Size = UDim2.fromOffset(11, 8), Position = UDim2.fromOffset(3, 10) }), 3)
	elseif kind == "visuals" then
		local ring = part({ Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(1, 2), BackgroundTransparency = 1 })
		local st = new("UIStroke", { Color = color, Thickness = 1.6, Parent = ring })
		table.insert(strokes, st)
		round(part({ Size = UDim2.fromOffset(5, 5), Position = UDim2.fromOffset(5.5, 6.5) }), 4)
	elseif kind == "teleport" then
		local ring = part({ Size = UDim2.fromOffset(10, 10), Position = UDim2.fromOffset(3, 1), BackgroundTransparency = 1 })
		local st = new("UIStroke", { Color = color, Thickness = 1.6, Parent = ring })
		table.insert(strokes, st)
		round(part({ Size = UDim2.fromOffset(5, 5), Position = UDim2.fromOffset(5.5, 7.5), Rotation = 45 }), 1)
		round(part({ Size = UDim2.fromOffset(3, 3), Position = UDim2.fromOffset(6.5, 4.5) }), 4)
	elseif kind == "misc" then
		local pos = { Vector2.new(1, 1), Vector2.new(10, 1), Vector2.new(1, 10), Vector2.new(10, 10) }
		for _, v in ipairs(pos) do
			round(part({ Size = UDim2.fromOffset(6, 6), Position = UDim2.fromOffset(v.X, v.Y) }), 2)
		end
	elseif kind == "settings" then
		local bars = { { y = 2, dot = 3 }, { y = 7.5, dot = 8 }, { y = 13, dot = 5 } }
		for _, b in ipairs(bars) do
			part({ Size = UDim2.fromOffset(15, 2), Position = UDim2.fromOffset(1, b.y), BackgroundTransparency = 0.35 })
			round(part({ Size = UDim2.fromOffset(4, 4), Position = UDim2.fromOffset(b.dot, b.y - 1) }), 4)
		end
	end

	return parts, strokes
end

local TAB_NAMES = { "Player", "Visuals", "Teleport", "Misc", "Settings" }
local TAB_ICONS = { "player", "visuals", "teleport", "misc", "settings" }

local tabButtons  = {}
local pages       = {}
local pageScrolls = {}
local pageItems   = { {}, {}, {}, {}, {} }

local function applySearchFilter()
	local q = string.lower((SearchBox.Text or ""):match("^%s*(.-)%s*$") or "")
	ClearSearchBtn.Visible = q ~= ""
	for pIdx = 1, 5 do
		for _, entry in ipairs(pageItems[pIdx]) do
			if q == "" then
				entry.node.Visible = true
			else
				entry.node.Visible = string.find(string.lower(entry.searchText), q, 1, true) ~= nil
			end
		end
	end
end

bind(SearchBox:GetPropertyChangedSignal("Text"), applySearchFilter)

for i = 1, 5 do
	local btn = new("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Position = UDim2.new((i - 1) / 5, 0, 0, 0),
		Size = UDim2.new(1 / 5, 0, 1, 0),
		ZIndex = 2,
		Parent = TabBar,
	})
	local iconHolder = new("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 9),
		Size = UDim2.fromOffset(17, 17),
		Parent = btn,
	})
	local parts, strokes = buildIcon(TAB_ICONS[i], iconHolder, Theme.TextDim)
	local label = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 30),
		Size = UDim2.new(1, 0, 0, 11),
		Font = Enum.Font.GothamMedium,
		TextSize = 9.5,
		TextColor3 = Theme.TextDim,
		Text = TAB_NAMES[i]:upper(),
		Parent = btn,
	})
	tabButtons[i] = { btn = btn, parts = parts, strokes = strokes, label = label }

	local page = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = Content,
	})
	local scroll = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0.25,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		Parent = page,
	})
	trackAccent(scroll, "ScrollBarImageColor3")
	new("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })
	new("UIPadding", {
		PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 16),
		PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18),
		Parent = scroll,
	})
	pages[i] = page
	pageScrolls[i] = scroll
end

local function computePillX(i)
	local cellW = WINDOW_W / 5
	return math.floor((i - 1) * cellW + (cellW - 62) / 2)
end

local activeTab = 0
local tabToken = 0
local function setTabColors(i, activeState)
	local tab = tabButtons[i]
	local c = activeState and Theme.White or Theme.TextDim
	for _, p in ipairs(tab.parts) do p.BackgroundColor3 = c end
	for _, s in ipairs(tab.strokes) do s.Color = c end
	tab.label.TextColor3 = c
end

local function selectTab(i)
	if i == activeTab then return end
	local prev = activeTab
	activeTab = i
	tabToken += 1
	local currentToken = tabToken

	tween(Pill, 0.44, { Position = UDim2.fromOffset(computePillX(i), 10) }, Enum.EasingStyle.Back)

	for idx = 1, 5 do setTabColors(idx, idx == i) end

	local dir = i > prev and 1 or -1
	local oldPage = pages[prev]
	local newPage = pages[i]

	if oldPage and oldPage.Visible then
		tween(oldPage, 0.22, { Position = UDim2.fromOffset(-22 * dir, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.23, function()
			if tabToken == currentToken and activeTab ~= prev then
				oldPage.Visible = false
			end
		end)
	end

	newPage.Visible = true
	newPage.Position = UDim2.fromOffset(26 * dir, 0)
	tween(newPage, 0.38, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end

for i = 1, 5 do
	tabButtons[i].btn.Activated:Connect(function() selectTab(i) end)
end

-- // Smooth dragging -----------------------------------------------------
do
	local dragging = false
	local startMouse, startPos, lastMouse
	local dragTarget = nil

	Header.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startMouse = Vector2.new(io.Position.X, io.Position.Y)
			startPos = Vector2.new(Holder.Position.X.Offset, Holder.Position.Y.Offset)
			lastMouse = startMouse
		end
	end)
	bind(UserInputService.InputChanged, function(io)
		if io.UserInputType == Enum.UserInputType.MouseMovement or io.UserInputType == Enum.UserInputType.Touch then
			lastMouse = Vector2.new(io.Position.X, io.Position.Y)
		end
	end)
	bind(UserInputService.InputEnded, function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	bind(RunService.RenderStepped, function(dt)
		if dragging and startMouse and lastMouse then
			local t = startPos + (lastMouse - startMouse)
			dragTarget = Vector2.new(
				math.clamp(t.X, -WinW * 0.5 + 12, Viewport.X - WinW * 0.5 - 12),
				math.clamp(t.Y, 54, Viewport.Y - 36)
			)
		end
		if dragTarget then
			local p = Holder.Position
			local nx = damp(p.X.Offset, dragTarget.X, 18, dt)
			local ny = damp(p.Y.Offset, dragTarget.Y, 18, dt)
			if not dragging and math.abs(dragTarget.X - nx) < 0.4 and math.abs(dragTarget.Y - ny) < 0.4 then
				nx, ny = dragTarget.X, dragTarget.Y
				dragTarget = nil
			end
			Holder.Position = UDim2.fromOffset(nx, ny)
		end
	end)
end

Boot.Step("Loading components", 0.5)

-- // Section library -----------------------------------------------------
local function Section(pageIndex, title)
	local cardList = pageScrolls[pageIndex]

	local holder = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = cardList,
	})
	new("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder })

	local labelWrap = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 15),
		Parent = holder,
	})
	new("UIPadding", { PaddingLeft = UDim.new(0, 18), Parent = labelWrap })
	new("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.TextFaint,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = string.upper(title), Parent = labelWrap,
	})

	local card = new("Frame", {
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = holder,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 18), Parent = card })
	new("UIStroke", { Color = Theme.Stroke, Transparency = 0.93, Parent = card })
	new("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })
	new("UIPadding", {
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18),
		Parent = card,
	})

	local section = { count = 0, card = card, pageIndex = pageIndex, title = title }
	local function separator(parent)
		if section.count > 0 then
			new("Frame", {
				BackgroundColor3 = Theme.Stroke,
				BackgroundTransparency = 0.94,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 1),
				Parent = parent,
			})
		end
	end

	local function registerSearch(node, labelText)
		table.insert(pageItems[pageIndex], {
			node = node,
			searchText = (section.title or "") .. " " .. (labelText or ""),
		})
	end

	function section:Toggle(cfg)
		local itemWrap = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = self.card,
		})
		new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = itemWrap })
		separator(itemWrap)
		self.count += 1
		registerSearch(itemWrap, cfg.text)

		local row = new("TextButton", {
			Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 48), Parent = itemWrap,
		})
		new("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, -68, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 14.5, TextColor3 = Theme.TextMain,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.text, Parent = row,
		})

		local track = new("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(52, 31),
			BackgroundColor3 = Color3.fromRGB(120, 120, 128),
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			Parent = row,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

		local knob = new("Frame", {
			Position = UDim2.fromOffset(2, 2.5),
			Size = UDim2.fromOffset(26, 26),
			BackgroundColor3 = Theme.White,
			BorderSizePixel = 0,
			Parent = track,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
		new("UIStroke", { Color = Color3.fromRGB(70, 70, 74), Transparency = 0.6, Parent = knob })
		local knobScale = new("UIScale", { Parent = knob })

		local state = cfg.default == true
		liveAccents[#liveAccents + 1] = function(c)
			if state then track.BackgroundColor3 = c end
		end

		local function render(instant)
			local targetX = state and 24 or 2
			if instant then
				knob.Position = UDim2.fromOffset(targetX, 2.5)
			else
				knobScale.Scale = 0.84
				tween(knobScale, 0.36, { Scale = 1 }, Enum.EasingStyle.Back)
				tween(knob, 0.36, { Position = UDim2.fromOffset(targetX, 2.5) }, Enum.EasingStyle.Back)
			end
			track.BackgroundColor3 = state and Accent or Color3.fromRGB(120, 120, 128)
			track.BackgroundTransparency = state and 0 or 0.55
		end

		row.Activated:Connect(function()
			state = not state
			render()
			if cfg.callback then cfg.callback(state) end
		end)
		render(true)

		return {
			Set = function(v, fire)
				local nv = v and true or false
				if nv ~= state then
					state = nv
					render(true)
					if fire ~= false and cfg.callback then cfg.callback(state) end
				end
			end,
			Get = function() return state end,
		}
	end

	function section:Slider(cfg)
		local itemWrap = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = self.card,
		})
		new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = itemWrap })
		separator(itemWrap)
		self.count += 1
		registerSearch(itemWrap, cfg.text)

		local row = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 66),
			Parent = itemWrap,
		})
		new("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 8),
			Size = UDim2.new(1, -86, 0, 15),
			Font = Enum.Font.GothamMedium, TextSize = 14.5, TextColor3 = Theme.TextMain,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.text, Parent = row,
		})
		local valueLabel = new("TextLabel", {
			BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 8), Size = UDim2.new(0, 86, 0, 15),
			Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.TextDim,
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = "", Parent = row,
		})

		local hit = new("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 31),
			Size = UDim2.new(1, 0, 0, 32),
			Parent = row,
		})
		local trackBg = new("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 5.5),
			BackgroundColor3 = Theme.White,
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			Parent = hit,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = trackBg })
		local fill = new("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = Accent,
			BorderSizePixel = 0,
			Parent = trackBg,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
		trackAccent(fill, "BackgroundColor3")

		local knob = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = Theme.White,
			BorderSizePixel = 0,
			Parent = hit,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
		new("UIStroke", { Color = Color3.fromRGB(120, 120, 128), Transparency = 0.5, Parent = knob })

		local min, max = cfg.min or 0, cfg.max or 100
		local step = cfg.step or 1
		local val = cfg.default or min
		local targetAlpha = (max ~= min) and ((val - min) / (max - min)) or 0
		local dragging = false

		local function setValue(v, fire)
			v = math.clamp(v, min, max)
			v = min + math.floor((v - min) / step + 0.5) * step
			v = tonumber(string.format("%.2f", v))
			val = v
			targetAlpha = (max ~= min) and ((v - min) / (max - min)) or 0
			fill.Size = UDim2.fromScale(targetAlpha, 1)
			knob.Position = UDim2.new(targetAlpha, 0, 0.5, 0)
			valueLabel.Text = tostring(v):gsub("%.00$", "") .. (cfg.suffix or "")
			if fire and cfg.callback then cfg.callback(v) end
		end

		local function fromInput(io)
			local rel = math.clamp(
				(io.Position.X - trackBg.AbsolutePosition.X) / math.max(trackBg.AbsoluteSize.X, 1), 0, 1)
			setValue(min + rel * (max - min), true)
		end

		hit.InputBegan:Connect(function(io)
			if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				fromInput(io)
			end
		end)
		bind(UserInputService.InputChanged, function(io)
			if dragging and (io.UserInputType == Enum.UserInputType.MouseMovement or io.UserInputType == Enum.UserInputType.Touch) then
				fromInput(io)
			end
		end)
		bind(UserInputService.InputEnded, function(io)
			if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		task.defer(function() setValue(cfg.default or min, false) end)

		return {
			Set = function(v, fire) setValue(v, fire ~= false) end,
			Get = function() return val end,
		}
	end

	function section:Button(cfg)
		local itemWrap = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = self.card,
		})
		new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = itemWrap })
		separator(itemWrap)
		self.count += 1
		registerSearch(itemWrap, cfg.text)

		if cfg.style == "filled" or cfg.style == "danger" then
			local wrap = new("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 56),
				Parent = itemWrap,
			})
			new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = wrap })
			local btn = new("TextButton", {
				Text = cfg.text,
				Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.White,
				BackgroundColor3 = (cfg.style == "danger") and Theme.Danger or Accent,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				AutoButtonColor = false,
				Parent = wrap,
			})
			new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = btn })
			if cfg.style ~= "danger" then trackAccent(btn, "BackgroundColor3") end
			local scale = new("UIScale", { Parent = btn })
			btn.Activated:Connect(function()
				tween(scale, 0.08, { Scale = 0.96 })
				task.delay(0.08, function() tween(scale, 0.34, { Scale = 1 }, Enum.EasingStyle.Back) end)
				if cfg.callback then cfg.callback() end
			end)
		else
			local row = new("TextButton", {
				Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 48), Parent = itemWrap,
			})
			new("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -26, 1, 0),
				Font = Enum.Font.GothamMedium, TextSize = 14.5, TextColor3 = Theme.TextMain,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Text = cfg.text, Parent = row,
			})
			new("TextLabel", {
				BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(14, 20),
				Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Theme.TextDim,
				Text = "›", Parent = row,
			})
			row.Activated:Connect(function()
				if cfg.callback then cfg.callback() end
			end)
		end
	end

	function section:Dropdown(cfg)
		local itemWrap = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = self.card,
		})
		new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = itemWrap })
		separator(itemWrap)
		self.count += 1
		registerSearch(itemWrap, cfg.text)

		local row = new("TextButton", {
			Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 48), Parent = itemWrap,
		})
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0.45, 0, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 14.5, TextColor3 = Theme.TextMain,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.text, Parent = row,
		})
		local valueLabel = new("TextLabel", {
			BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -20, 0.5, 0), Size = UDim2.new(0.55, -20, 0, 16),
			Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.TextDim,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.default or "—", Parent = row,
		})
		local chev = new("TextLabel", {
			BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(14, 16),
			Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.TextDim,
			Text = "▾", Parent = row,
		})

		local list = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			ClipsDescendants = true,
			Parent = itemWrap,
		})
		new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

		local open = false
		local selected = cfg.default

		local function closeList()
			open = false
			tween(list, 0.3, { Size = UDim2.new(1, 0, 0, 0) })
			tween(chev, 0.25, { Rotation = 0 })
		end

		local function openList()
			open = true
			for _, child in ipairs(list:GetChildren()) do
				if child:IsA("TextButton") then child:Destroy() end
			end
			local opts = (type(cfg.options) == "function") and cfg.options() or cfg.options
			for _, opt in ipairs(opts) do
				local orow = new("TextButton", {
					Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
					Size = UDim2.new(1, 0, 0, 34), Parent = list,
				})
				new("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -26, 1, 0),
					Font = Enum.Font.Gotham, TextSize = 13.5,
					TextColor3 = (opt == selected) and Theme.TextMain or Theme.TextDim,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Text = tostring(opt), Parent = orow,
				})
				local check = new("TextLabel", {
					BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(14, 16),
					Font = Enum.Font.GothamBold, TextSize = 14,
					TextColor3 = Accent, Text = "✓", Visible = opt == selected, Parent = orow,
				})
				trackAccent(check, "TextColor3")
				orow.Activated:Connect(function()
					selected = opt
					valueLabel.Text = tostring(opt)
					if cfg.callback then cfg.callback(opt) end
					closeList()
				end)
			end
			tween(chev, 0.25, { Rotation = 180 })
			local h = math.min(#opts * 36 + 6, 218)
			tween(list, 0.36, { Size = UDim2.new(1, 0, 0, h) }, Enum.EasingStyle.Quart)
		end

		row.Activated:Connect(function()
			if open then closeList() else openList() end
		end)

		return {
			Set = function(opt, fire)
				selected = opt
				valueLabel.Text = opt and tostring(opt) or "—"
				if fire and cfg.callback then cfg.callback(opt) end
			end,
			Get = function() return selected end,
		}
	end

	function section:Keybind(cfg)
		local itemWrap = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = self.card,
		})
		new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = itemWrap })
		separator(itemWrap)
		self.count += 1
		registerSearch(itemWrap, cfg.text)

		local row = new("TextButton", {
			Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 48), Parent = itemWrap,
		})
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -120, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 14.5, TextColor3 = Theme.TextMain,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.text, Parent = row,
		})

		local badge = new("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = Theme.SurfaceAlt,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 0, 28),
			Parent = row,
		})
		new("UICorner", { CornerRadius = UDim.new(0, 9), Parent = badge })
		local stroke = new("UIStroke", { Color = Accent, Transparency = 1, Parent = badge })
		trackAccent(stroke, "Color")
		new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = badge })
		local keyText = new("TextLabel", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.TextMain,
			Text = cfg.default or "RightShift", Parent = badge,
		})

		local listening = false
		local currentKeyName = cfg.default or "RightShift"

		row.Activated:Connect(function()
			listening = not listening
			if listening then
				KeybindListening += 1
				stroke.Transparency = 0.1
				keyText.Text = "PRESS A KEY"
				keyText.TextColor3 = Accent
			else
				KeybindListening -= 1
				stroke.Transparency = 1
				keyText.Text = currentKeyName
				keyText.TextColor3 = Theme.TextMain
			end
		end)

		bind(UserInputService.InputBegan, function(io, gp)
			if not listening or gp then return end
			if io.UserInputType ~= Enum.UserInputType.Keyboard then return end
			listening = false
			KeybindListening -= 1
			stroke.Transparency = 1
			keyText.TextColor3 = Theme.TextMain
			if io.KeyCode ~= Enum.KeyCode.Backspace then
				LastCaptureTick = os.clock()
				currentKeyName = io.KeyCode.Name
				keyText.Text = currentKeyName
				if cfg.callback then cfg.callback(io.KeyCode) end
			else
				keyText.Text = currentKeyName
			end
		end)
	end

	function section:AccentPicker(cfg)
		local itemWrap = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = self.card,
		})
		new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = itemWrap })
		separator(itemWrap)
		self.count += 1
		registerSearch(itemWrap, cfg.text)

		local row = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 52),
			Parent = itemWrap,
		})
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -200, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 14.5, TextColor3 = Theme.TextMain,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = cfg.text, Parent = row,
		})
		local holder = new("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(0, 6 * 24 + 5 * 10, 0, 26),
			Parent = row,
		})
		new("UIListLayout", {
			Padding = UDim.new(0, 10),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Parent = holder,
		})

		local function isSelected(c)
			return math.abs(c.R - Accent.R) < 0.01 and math.abs(c.G - Accent.G) < 0.01 and math.abs(c.B - Accent.B) < 0.01
		end

		local swatches = {}
		for _, acc in ipairs(ACCENTS) do
			local sw = new("TextButton", {
				Text = "", BackgroundTransparency = 0,
				BackgroundColor3 = acc.color,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(24, 24),
				AutoButtonColor = false,
				Parent = holder,
			})
			new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sw })
			local ring = new("UIStroke", { Color = Theme.White, Thickness = 1.8, Transparency = 1, Parent = sw })
			swatches[#swatches + 1] = { btn = sw, ring = ring, acc = acc }

			sw.Activated:Connect(function()
				setAccent(acc.color)
				for _, s in ipairs(swatches) do
					s.ring.Transparency = isSelected(s.acc.color) and 0.1 or 1
				end
				Notify("Appearance", acc.name .. " accent applied")
			end)
		end
		for _, s in ipairs(swatches) do
			s.ring.Transparency = isSelected(s.acc.color) and 0.1 or 1
		end
	end

	function section:Info(cfg)
		local itemWrap = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = self.card,
		})
		new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = itemWrap })
		separator(itemWrap)
		self.count += 1
		registerSearch(itemWrap, cfg.text)

		local row = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 42),
			Parent = itemWrap,
		})
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0.45, 0, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.TextMain,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = cfg.text, Parent = row,
		})
		local valLabel = new("TextLabel", {
			BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.55, 0, 0, 16),
			Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.TextDim,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.value, Parent = row,
		})
		return {
			Set = function(v) valLabel.Text = tostring(v) end,
		}
	end

	function section:Footer(text)
		separator(self.card)
		self.count += 1
		local row = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 28),
			Parent = self.card,
		})
		new("TextLabel", {
			BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
			Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Theme.TextFaint,
			Text = text, Parent = row,
		})
	end

	return section
end

Boot.Step("Loading modules", 0.7)

-- // Feature state -------------------------------------------------------
local BaseWS, BaseJP = 16, 50
do
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		BaseWS = hum.WalkSpeed or 16
		if hum.UseJumpPower then BaseJP = hum.JumpPower or 50 end
	end
end

local State = {
	WalkSpeed   = BaseWS,
	JumpPower   = BaseJP,
	SprintBoost = false,
	SprintMult  = 1.45,
	InfJump     = false,
	BunnyHop    = false,
	Noclip      = false,
	Fly         = false,
	FlyMode     = "Velocity",
	FlySpeed    = 60,
	SpinBot     = false,
	SpinSpeed   = 18,
	FloatMode   = false,
	WalkWater   = false,
	ClickTP     = false,
	AntiAFK     = true,
	NoFog       = false,
	Xray        = false,
	Freecam     = false,
	FreecamSpd  = 45,
	Spectating  = false,
	Aimbot = {
		Enabled     = false,
		HoldRMB     = true,
		TargetLock  = true,
		Smoothness  = 0.18,
		FOV         = 130,
		ShowFOV     = true,
		TargetPart  = "Head",
		TeamCheck   = true,
		WallCheck   = true,
	},
	ESP = {
		Master    = false,
		Boxes     = false,
		Names     = true,
		Distance  = false,
		Health    = true,
		Tracers   = false,
		TeamCheck = true,
	},
}

local function getChar() return LocalPlayer.Character end
local OriginalGravity = workspace.Gravity
local OriginalFOV     = Camera.FieldOfView
local function getHRP()
	local c = getChar()
	return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
	local c = getChar()
	return c and c:FindFirstChildOfClass("Humanoid")
end

-- // Movement & Shift Sprint ---------------------------------------------
local function setWalkSpeed(v)
	State.WalkSpeed = v
	local hum = getHum()
	if hum then hum.WalkSpeed = v end
end
local function setJumpPower(v)
	State.JumpPower = v
	local hum = getHum()
	if hum then
		pcall(function()
			hum.UseJumpPower = true
			hum.JumpPower = v
		end)
	end
end

bind(LocalPlayer.CharacterAdded, function()
	task.wait(0.3)
	if State.WalkSpeed ~= BaseWS then setWalkSpeed(State.WalkSpeed) end
	if State.JumpPower ~= BaseJP then setJumpPower(State.JumpPower) end
end)

bind(RunService.Heartbeat, function()
	if State.Freecam then return end
	local hum = getHum()
	if hum then
		local isSprinting = State.SprintBoost and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and hum.MoveDirection.Magnitude > 0.1
		local targetWS = isSprinting and (State.WalkSpeed * State.SprintMult) or State.WalkSpeed
		if math.abs(hum.WalkSpeed - targetWS) > 0.1 then
			hum.WalkSpeed = targetWS
		end
	end
end)

task.spawn(function()
	while Gui.Parent do
		task.wait(0.75)
		local hum = getHum()
		if hum then
			if State.JumpPower ~= BaseJP and math.floor(hum.JumpPower + 0.5) ~= State.JumpPower then
				pcall(function() hum.JumpPower = State.JumpPower end)
			end
			if State.BunnyHop and hum.MoveDirection.Magnitude > 0.1 and hum.FloorMaterial ~= Enum.Material.Air then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)

bind(UserInputService.JumpRequest, function()
	if State.InfJump then
		local hum = getHum()
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jump) end
	end
end)

-- // Noclip, Float, WalkWater & SpinBot ----------------------------------
local floatPart = nil
local waterPart = nil
bind(RunService.Stepped, function()
	if State.Noclip then
		local char = getChar()
		if char then
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
			end
		end
	end
	local hrp = getHRP()
	if State.FloatMode and hrp and not State.Noclip and not State.Fly then
		if not floatPart or not floatPart.Parent then
			floatPart = new("Part", {
				Name = "GCG_FloatPart",
				Size = Vector3.new(5.5, 0.5, 5.5),
				Anchored = true,
				Transparency = 0.85,
				CanCollide = true,
				Material = Enum.Material.Neon,
				Color = Accent,
				Parent = Gui,
			})
			trackAccent(floatPart, "Color")
		end
		floatPart.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 3.35, 0))
	elseif floatPart then
		floatPart:Destroy()
		floatPart = nil
	end

	if State.WalkWater and hrp then
		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Include
		rayParams.FilterDescendantsInstances = { workspace.Terrain }
		local hit = workspace:Raycast(hrp.Position + Vector3.new(0, 2, 0), Vector3.new(0, -14, 0), rayParams)
		if hit and hit.Material == Enum.Material.Water then
			if not waterPart or not waterPart.Parent then
				waterPart = new("Part", {
					Name = "GCG_WaterWalkPart",
					Size = Vector3.new(12, 0.6, 12),
					Anchored = true,
					Transparency = 0.8,
					CanCollide = true,
					Material = Enum.Material.Glass,
					Color = Accent,
					Parent = Gui,
				})
				trackAccent(waterPart, "Color")
			end
			waterPart.CFrame = CFrame.new(hrp.Position.X, hit.Position.Y - 0.1, hrp.Position.Z)
		elseif waterPart then
			waterPart:Destroy()
			waterPart = nil
		end
	elseif waterPart then
		waterPart:Destroy()
		waterPart = nil
	end
end)

bind(RunService.Heartbeat, function(dt)
	if State.SpinBot and not State.Fly then
		local hrp = getHRP()
		if hrp then
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(State.SpinSpeed * 60 * dt), 0)
		end
	end
end)

-- // Fly (Velocity & CFrame) ---------------------------------------------
local flyBV = nil
bind(RunService.Heartbeat, function(dt)
	local hrp = getHRP()
	if State.Fly and hrp then
		local camCF = Camera.CFrame
		local dir = Vector3.new(0, 0, 0)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camCF.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camCF.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camCF.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camCF.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
		local vel = (dir.Magnitude > 0) and (dir.Unit * State.FlySpeed) or Vector3.zero

		if State.FlyMode == "CFrame" then
			if flyBV then flyBV:Destroy() flyBV = nil end
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.CFrame = hrp.CFrame + vel * dt
		else
			if not flyBV or flyBV.Parent ~= hrp then
				if flyBV then flyBV:Destroy() end
				flyBV = new("BodyVelocity", {
					MaxForce = Vector3.new(1e9, 1e9, 1e9),
					Velocity = Vector3.new(0, 0, 0),
					Parent = hrp,
				})
			end
			flyBV.Velocity = vel
		end
	elseif flyBV then
		flyBV:Destroy()
		flyBV = nil
	end
end)

-- // Aimbot --------------------------------------------------------------
local HasDrawing = pcall(function()
	local l = Drawing.new("Line")
	l:Remove()
end)

local fovCircle = nil
if HasDrawing then
	pcall(function()
		fovCircle = Drawing.new("Circle")
		fovCircle.Thickness = 1.5
		fovCircle.NumSides = 64
		fovCircle.Filled = false
		fovCircle.Transparency = 0.75
		fovCircle.Color = Accent
		fovCircle.Visible = false
		trackAccent(fovCircle, "Color")
	end)
end

local lockedAimPart = nil

local function isVisible(originPos, targetPart, targetChar)
	if not State.Aimbot.WallCheck then return true end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore = {}
	if getChar() then table.insert(ignore, getChar()) end
	params.FilterDescendantsInstances = ignore
	local dir = targetPart.Position - originPos
	local res = workspace:Raycast(originPos, dir, params)
	if not res then return true end
	return targetChar and res.Instance:IsDescendantOf(targetChar)
end

local function isValidAimPart(part)
	if not part or not part.Parent then return false end
	local hum = part.Parent:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	local plr = Players:GetPlayerFromCharacter(part.Parent)
	if plr and State.Aimbot.TeamCheck and plr.Team ~= nil and LocalPlayer.Team ~= nil and plr.Team == LocalPlayer.Team then
		return false
	end
	return isVisible(Camera.CFrame.Position, part, part.Parent)
end

local function getAimTarget()
	if State.Aimbot.TargetLock and lockedAimPart and isValidAimPart(lockedAimPart) then
		return lockedAimPart
	end
	lockedAimPart = nil

	local vp = Camera.ViewportSize
	local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
	local bestPart, bestDist = nil, State.Aimbot.FOV
	local camOrigin = Camera.CFrame.Position

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local sameTeam = State.Aimbot.TeamCheck and plr.Team ~= nil and LocalPlayer.Team ~= nil and plr.Team == LocalPlayer.Team
			local char = plr.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local part = char and (char:FindFirstChild(State.Aimbot.TargetPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
			if not sameTeam and hum and hum.Health > 0 and part then
				local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
				if onScreen and screenPos.Z > 0 then
					local d2d = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
					if d2d <= bestDist and isVisible(camOrigin, part, char) then
						bestDist = d2d
						bestPart = part
					end
				end
			end
		end
	end
	if State.Aimbot.TargetLock and bestPart then
		lockedAimPart = bestPart
	end
	return bestPart
end

-- // Radar update loop ---------------------------------------------------
local radarDots = {}
local function updateRadar()
	if not radarEnabled then
		RadarFrame.Visible = false
		return
	end
	RadarFrame.Visible = true
	local myHRP = getHRP()
	if not myHRP then return end

	local activePlrs = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			activePlrs[plr] = true
			local dot = radarDots[plr]
			if not dot then
				dot = new("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromOffset(6, 6),
					BackgroundColor3 = Theme.Danger,
					BorderSizePixel = 0,
					Parent = RadarDotsFolder,
				})
				new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
				radarDots[plr] = dot
			end

			local tHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			local tHum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
			if tHRP and tHum and tHum.Health > 0 then
				local sameTeam = State.ESP.TeamCheck and plr.Team ~= nil and LocalPlayer.Team ~= nil and plr.Team == LocalPlayer.Team
				dot.BackgroundColor3 = sameTeam and Theme.Success or Theme.Danger

				local offset = tHRP.Position - myHRP.Position
				local _, camYaw = Camera.CFrame:ToOrientation()
				local cosY, sinY = math.cos(camYaw), math.sin(camYaw)
				local rx = offset.X * cosY - offset.Z * sinY
				local rz = offset.X * sinY + offset.Z * cosY

				local range = 140
				local radiusPx = 62
				local nx = math.clamp((rx / range) * radiusPx, -radiusPx, radiusPx)
				local ny = math.clamp((rz / range) * radiusPx, -radiusPx, radiusPx)
				dot.Position = UDim2.new(0.5, nx, 0.5, ny)
				dot.Visible = true
			else
				dot.Visible = false
			end
		end
	end

	for plr, dot in pairs(radarDots) do
		if not activePlrs[plr] then
			dot:Destroy()
			radarDots[plr] = nil
		end
	end
end

bind(RunService.RenderStepped, function()
	local vp = Camera.ViewportSize
	local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
	if fovCircle then
		fovCircle.Position = center
		fovCircle.Radius = State.Aimbot.FOV
		fovCircle.Visible = State.Aimbot.Enabled and State.Aimbot.ShowFOV
	end

	local holdingAim = not State.Aimbot.HoldRMB or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	local activeAim = State.Aimbot.Enabled and holdingAim and not State.Freecam and not State.Spectating
	if not holdingAim then lockedAimPart = nil end
	if activeAim then
		local target = getAimTarget()
		if target then
			local currentCF = Camera.CFrame
			local desiredCF = CFrame.lookAt(currentCF.Position, target.Position)
			local alpha = math.clamp(State.Aimbot.Smoothness, 0.03, 1)
			Camera.CFrame = currentCF:Lerp(desiredCF, alpha)
			if islandEnabled and not islandExpanded and islandPulseToken == 0 then
				IslandSub.Text = "Aim: " .. tostring(target.Parent and target.Parent.Name or "Target")
			end
		end
	end

	updateRadar()
end)

-- // Freecam & Spectate --------------------------------------------------
local freecamCF = nil
local function setFreecam(on)
	State.Freecam = on
	local hum = getHum()
	if on then
		State.Spectating = false
		freecamCF = Camera.CFrame
		Camera.CameraType = Enum.CameraType.Scriptable
		if hum then hum.WalkSpeed = 0 end
	else
		if not State.Spectating then
			Camera.CameraType = Enum.CameraType.Custom
		end
		freecamCF = nil
		if hum then hum.WalkSpeed = State.WalkSpeed end
	end
end

local function setSpectate(on, targetName)
	local hum = getHum()
	if on then
		local plr = targetName and Players:FindFirstChild(targetName)
		local tHum = plr and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
		if tHum then
			State.Spectating = true
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CameraSubject = tHum
			Notify("Spectate", "Watching " .. plr.DisplayName)
		else
			Notify("Spectate", "Select a valid player first")
		end
	else
		State.Spectating = false
		Camera.CameraType = Enum.CameraType.Custom
		if hum then Camera.CameraSubject = hum end
	end
end

bind(RunService.RenderStepped, function(dt)
	if State.Freecam then
		if not freecamCF then freecamCF = Camera.CFrame end
		local move = Vector3.new(0, 0, 0)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += freecamCF.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= freecamCF.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= freecamCF.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += freecamCF.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.E) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			move += Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Q) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			move -= Vector3.new(0, 1, 0)
		end
		local spd = State.FreecamSpd * (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 2 or 1)
		local pos = freecamCF.Position + (move.Magnitude > 0 and move.Unit * spd * dt or Vector3.zero)
		local _, yaw, roll = Camera.CFrame:ToOrientation()
		local pitch = select(1, freecamCF:ToEulerAnglesYXZ())
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local delta = UserInputService:GetMouseDelta()
			pitch = math.clamp(pitch - math.rad(delta.Y * 0.25), math.rad(-85), math.rad(85))
			yaw = yaw - math.rad(delta.X * 0.25)
		end
		freecamCF = CFrame.new(pos) * CFrame.fromEulerAnglesYXZ(pitch, yaw, roll)
		Camera.CFrame = freecamCF
	end
end)

-- // Ctrl + Click TP -----------------------------------------------------
bind(UserInputService.InputBegan, function(io, gp)
	if gp then return end
	if State.ClickTP and io.UserInputType == Enum.UserInputType.MouseButton1
		and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		local hrp = getHRP()
		if hrp and Mouse.Hit then
			hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
		end
	end
end)

-- // Fullbright & NoFog & X-Ray ----------------------------------------
local savedLighting = nil
local function setFullbright(on)
	if on then
		savedLighting = {
			Brightness = Lighting.Brightness,
			ClockTime = Lighting.ClockTime,
			FogEnd = Lighting.FogEnd,
			FogStart = Lighting.FogStart,
			GlobalShadows = Lighting.GlobalShadows,
			OutdoorAmbient = Lighting.OutdoorAmbient,
			Ambient = Lighting.Ambient,
		}
		Lighting.Brightness = 3
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.FogStart = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
		Lighting.Ambient = Color3.fromRGB(140, 140, 140)
	else
		if savedLighting then
			for k, v in pairs(savedLighting) do Lighting[k] = v end
		end
	end
end

local savedFog = nil
local function setNoFog(on)
	if on then
		savedFog = { FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd }
		Lighting.FogStart = 1000000
		Lighting.FogEnd = 1000000
		for _, obj in ipairs(Lighting:GetChildren()) do
			if obj:IsA("Atmosphere") then
				obj:SetAttribute("_SavedDensity", obj.Density)
				obj.Density = 0
			end
		end
	else
		if savedFog then
			Lighting.FogStart = savedFog.FogStart
			Lighting.FogEnd = savedFog.FogEnd
		end
		for _, obj in ipairs(Lighting:GetChildren()) do
			if obj:IsA("Atmosphere") and obj:GetAttribute("_SavedDensity") then
				obj.Density = obj:GetAttribute("_SavedDensity")
			end
		end
	end
end

local xraySaved = {}
local function setXray(on)
	State.Xray = on
	if on then
		for _, p in ipairs(workspace:GetDescendants()) do
			if p:IsA("BasePart") and not p:IsDescendantOf(getChar() or workspace) and p.Transparency < 0.7 then
				xraySaved[p] = p.Transparency
				p.Transparency = 0.65
			end
		end
	else
		for part, tr in pairs(xraySaved) do
			if part and part.Parent then part.Transparency = tr end
		end
		xraySaved = {}
	end
end

-- // FPS boost -----------------------------------------------------------
local fpsSaved = { materials = {}, trans = {}, effects = {} }
local fpsCon = nil

local function boostObject(o)
	if o:IsA("Texture") or o:IsA("Decal") then
		if o.Transparency ~= 1 then
			table.insert(fpsSaved.trans, { o, o.Transparency })
			o.Transparency = 1
		end
	elseif o:IsA("BasePart") then
		if o.Material ~= Enum.Material.Plastic then
			table.insert(fpsSaved.materials, { o, o.Material })
			o.Material = Enum.Material.Plastic
		end
	elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam")
		or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then
		if o.Enabled then
			table.insert(fpsSaved.effects, { o })
			o.Enabled = false
		end
	end
end

local function setFPSBoost(on)
	if on then
		for _, o in ipairs(workspace:GetDescendants()) do
			pcall(boostObject, o)
		end
		fpsCon = workspace.DescendantAdded:Connect(function(o)
			task.defer(boostObject, o)
		end)
		table.insert(Connections, fpsCon)
		pcall(function()
			local t = workspace.Terrain
			fpsSaved.terrain = { t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance, t.WaterTransparency }
			t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance = 0, 0, 0
			t.WaterTransparency = 1
		end)
		pcall(function() settings().Rendering.QualityLevel = 1 end)
	else
		if fpsCon then fpsCon:Disconnect() fpsCon = nil end
		for _, e in ipairs(fpsSaved.materials) do pcall(function() e[1].Material = e[2] end) end
		for _, e in ipairs(fpsSaved.trans) do pcall(function() e[1].Transparency = e[2] end) end
		for _, e in ipairs(fpsSaved.effects) do pcall(function() e[1].Enabled = true end) end
		if fpsSaved.terrain then
			pcall(function()
				local t = workspace.Terrain
				t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance, t.WaterTransparency =
					fpsSaved.terrain[1], fpsSaved.terrain[2], fpsSaved.terrain[3], fpsSaved.terrain[4]
			end)
		end
		fpsSaved = { materials = {}, trans = {}, effects = {} }
	end
end

-- // Anti-AFK ------------------------------------------------------------
bind(LocalPlayer.Idled, function()
	if State.AntiAFK then
		pcall(function()
			local VirtualUser = game:GetService("VirtualUser")
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end
end)

-- // ESP (Highlights + Boxes + Name/HP/Dist + Tracers) -----------------
local espFolder = new("Folder", { Name = "ESP", Parent = Gui })
local espCache = {}

local function espRemove(plr)
	local d = espCache[plr]
	if d then
		if d.hl then d.hl:Destroy() end
		if d.bb then d.bb:Destroy() end
		if d.line then pcall(function() d.line:Remove() end) end
		if d.box then pcall(function() d.box:Remove() end) end
		espCache[plr] = nil
	end
end

local function espAdd(plr)
	if espCache[plr] or plr == LocalPlayer then return end
	local d = {}

	d.hl = new("Highlight", {
		FillColor = Accent,
		FillTransparency = 0.72,
		OutlineColor = Theme.White,
		OutlineTransparency = 0.1,
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
		Enabled = false,
		Parent = espFolder,
	})
	trackAccent(d.hl, "FillColor")

	d.bb = new("BillboardGui", {
		Size = UDim2.fromOffset(220, 52),
		StudsOffset = Vector3.new(0, 2.6, 0),
		AlwaysOnTop = true,
		Enabled = false,
		Parent = espFolder,
	})
	d.nameL = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.White,
		TextStrokeTransparency = 0.4,
		Text = plr.DisplayName, Parent = d.bb,
	})
	d.metaL = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 16),
		Size = UDim2.new(1, 0, 0, 14),
		Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.TextDim,
		TextStrokeTransparency = 0.5,
		Text = "", Parent = d.bb,
	})

	if HasDrawing then
		pcall(function()
			d.line = Drawing.new("Line")
			d.line.Thickness = 1
			d.line.Transparency = 0.8
			d.line.Color = Accent
			d.line.Visible = false
			trackAccent(d.line, "Color")

			d.box = Drawing.new("Square")
			d.box.Thickness = 1.4
			d.box.Filled = false
			d.box.Transparency = 0.85
			d.box.Color = Accent
			d.box.Visible = false
			trackAccent(d.box, "Color")
		end)
	end

	espCache[plr] = d
end

local function espRefresh()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if State.ESP.Master then espAdd(plr) else espRemove(plr) end
		end
	end
end

local function espClearAll()
	for plr in pairs(espCache) do espRemove(plr) end
end

bind(Players.PlayerAdded, function(plr)
	if State.ESP.Master then espAdd(plr) end
end)
bind(Players.PlayerRemoving, espRemove)

bind(RunService.RenderStepped, function()
	local myHRP = getHRP()
	local vp = Camera.ViewportSize
	for plr, d in pairs(espCache) do
		local char = plr.Character
		local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local valid = (char and head and hum and hum.Health > 0) and true or false
		local sameTeam = (State.ESP.TeamCheck and plr.Team ~= nil and LocalPlayer.Team ~= nil
			and plr.Team == LocalPlayer.Team) and true or false
		local masterOn = (State.ESP.Master and valid and not sameTeam) and true or false

		if d.hl then
			d.hl.Adornee = char
			d.hl.Enabled = masterOn
		end

		local showBB = (masterOn and (State.ESP.Names or State.ESP.Distance or State.ESP.Health)) and true or false
		if d.bb then
			d.bb.Adornee = head
			d.bb.Enabled = showBB
			d.nameL.Visible = State.ESP.Names
			local showMeta = State.ESP.Distance or State.ESP.Health
			d.metaL.Visible = showMeta
			if showBB and showMeta then
				local parts = {}
				if State.ESP.Health and hum then
					table.insert(parts, string.format("%d HP", math.floor(hum.Health + 0.5)))
				end
				if State.ESP.Distance and myHRP and head then
					table.insert(parts, string.format("%d st", (head.Position - myHRP.Position).Magnitude))
				end
				d.metaL.Text = table.concat(parts, " • ")
			else
				d.metaL.Text = ""
			end
		end

		if d.box then
			if masterOn and State.ESP.Boxes and hrp then
				local topPos, topVis = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0))
				local botPos, botVis = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))
				if topVis and botVis and topPos.Z > 0 then
					local h = math.max(math.abs(botPos.Y - topPos.Y), 12)
					local w = h * 0.58
					d.box.Size = Vector2.new(w, h)
					d.box.Position = Vector2.new(topPos.X - w * 0.5, topPos.Y)
					d.box.Visible = true
				else
					d.box.Visible = false
				end
			else
				d.box.Visible = false
			end
		end

		if d.line then
			if masterOn and State.ESP.Tracers and head then
				local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					d.line.From = Vector2.new(vp.X / 2, vp.Y)
					d.line.To = Vector2.new(pos.X, pos.Y)
					d.line.Visible = true
				else
					d.line.Visible = false
				end
			else
				d.line.Visible = false
			end
		end
	end
end)

-- // Teleport & Utility helpers ----------------------------------------
local selectedTarget = nil
local savedPos = nil
local waypoints = {}

local function playerOptions()
	local list = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then table.insert(list, plr.Name) end
	end
	table.sort(list)
	return list
end

local function getClosestPlayer()
	local hrp = getHRP()
	if not hrp then return nil end
	local best, bestDist = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local sameTeam = State.ESP.TeamCheck and plr.Team ~= nil and LocalPlayer.Team ~= nil and plr.Team == LocalPlayer.Team
			local tHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			local tHum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
			if not sameTeam and tHRP and tHum and tHum.Health > 0 then
				local dist = (tHRP.Position - hrp.Position).Magnitude
				if dist < bestDist then
					bestDist = dist
					best = plr
				end
			end
		end
	end
	return best
end

local function teleportToPlayer(plr)
	local hrp = getHRP()
	local tHRP = plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if hrp and tHRP then
		hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3)
		Notify("Teleport", "Teleported to " .. plr.DisplayName)
	else
		Notify("Teleport", "Target has no character")
	end
end

local function teleportToSelected()
	if not selectedTarget then
		Notify("Teleport", "Select a player first")
		return
	end
	teleportToPlayer(Players:FindFirstChild(selectedTarget))
end

local function rejoin()
	Notify("Server", "Rejoining...")
	task.wait(0.3)
	if game.JobId and game.JobId ~= "" then
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	else
		TeleportService:Teleport(game.PlaceId)
	end
end

local function serverHop()
	local body
	local okReq = pcall(function()
		local req = request or (syn and syn.request) or http_request
		if not req then error("no http") end
		local res = req({
			Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=2&excludeFullGames=true&limit=100",
			Method = "GET",
		})
		body = HttpService:JSONDecode(res.Body)
	end)
	if okReq and body and body.data and #body.data > 0 then
		local best = body.data[1]
		for _, s in ipairs(body.data) do
			if s.playing and best.playing and s.playing < best.playing then best = s end
		end
		Notify("Server", "Joining a fresh server...")
		task.wait(0.3)
		TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LocalPlayer)
	else
		Notify("Server", "Server hop is not supported here")
	end
end

Boot.Step("Building tabs", 0.85)

-- // Build tabs ----------------------------------------------------------
-- 1. PLAYER
local secMove = Section(1, "Movement")
local sWalk = secMove:Slider({ text = "Walk Speed", min = 0, max = 250, default = BaseWS, callback = setWalkSpeed })
local sJump = secMove:Slider({ text = "Jump Power", min = 0, max = 300, default = BaseJP, callback = setJumpPower })
local sGrav = secMove:Slider({ text = "Gravity", min = 0, max = 500, default = workspace.Gravity, step = 0.1, callback = function(v)
	workspace.Gravity = v
end })
secMove:Toggle({ text = "Shift Sprint Boost", default = false, callback = function(v) State.SprintBoost = v end })
secMove:Slider({ text = "Sprint Multiplier", min = 1.1, max = 3.0, default = 1.45, step = 0.05, suffix = "x", callback = function(v) State.SprintMult = v end })
secMove:Button({
	text = "Reset Movement & Gravity",
	callback = function()
		sWalk.Set(BaseWS)
		sJump.Set(BaseJP)
		sGrav.Set(OriginalGravity)
		Notify("Movement", "Reset to default values")
	end,
})

local secAbil = Section(1, "Abilities")
secAbil:Toggle({ text = "Infinite Jump", default = false, callback = function(v) State.InfJump = v end })
secAbil:Toggle({ text = "BunnyHop (Auto-Jump)", default = false, callback = function(v) State.BunnyHop = v end })
local tNoclip = secAbil:Toggle({ text = "Noclip", default = false, callback = function(v) State.Noclip = v end })
local tFly = secAbil:Toggle({
	text = "Fly",
	default = false,
	callback = function(v)
		State.Fly = v
		Notify("Fly", v and ("Enabled (" .. State.FlyMode .. ") — WASD, Space, Ctrl") or "Disabled")
	end,
})
secAbil:Dropdown({
	text = "Fly Mode",
	default = "Velocity",
	options = { "Velocity", "CFrame" },
	callback = function(v) State.FlyMode = v end,
})
secAbil:Slider({ text = "Fly Speed", min = 10, max = 220, default = 60, callback = function(v) State.FlySpeed = v end })
secAbil:Toggle({ text = "Float Platform", default = false, callback = function(v) State.FloatMode = v end })
secAbil:Toggle({ text = "Walk on Water", default = false, callback = function(v) State.WalkWater = v end })
secAbil:Toggle({ text = "SpinBot", default = false, callback = function(v) State.SpinBot = v end })
secAbil:Slider({ text = "Spin Speed", min = 1, max = 60, default = 18, callback = function(v) State.SpinSpeed = v end })

local secChar = Section(1, "Character Actions")
secChar:Button({
	text = "Respawn Character",
	callback = function()
		local hum = getHum()
		if hum then
			hum.Health = 0
			Notify("Character", "Respawning...")
		end
	end,
})
secChar:Button({
	text = "Sit / Unsit",
	callback = function()
		local hum = getHum()
		if hum then hum.Sit = not hum.Sit end
	end,
})

-- 2. VISUALS & AIM
local secAim = Section(2, "Aimbot")
local tAim = secAim:Toggle({
	text = "Aimbot Enabled",
	default = false,
	callback = function(v)
		State.Aimbot.Enabled = v
		if not v then lockedAimPart = nil end
		Notify("Aimbot", v and "Aimbot enabled" or "Aimbot disabled")
	end,
})
secAim:Toggle({ text = "Hold Right-Click Only", default = true, callback = function(v) State.Aimbot.HoldRMB = v end })
secAim:Toggle({ text = "Target Lock", default = true, callback = function(v) State.Aimbot.TargetLock = v if not v then lockedAimPart = nil end end })
secAim:Toggle({ text = "Show FOV Circle", default = true, callback = function(v) State.Aimbot.ShowFOV = v end })
secAim:Toggle({ text = "Aim Team Check", default = true, callback = function(v) State.Aimbot.TeamCheck = v end })
secAim:Toggle({ text = "Aim Wall Check", default = true, callback = function(v) State.Aimbot.WallCheck = v end })
secAim:Dropdown({
	text = "Target Part",
	default = "Head",
	options = { "Head", "HumanoidRootPart" },
	callback = function(v) State.Aimbot.TargetPart = v lockedAimPart = nil end,
})
secAim:Slider({ text = "Aim FOV", min = 30, max = 450, default = 130, suffix = "px", callback = function(v) State.Aimbot.FOV = v end })
secAim:Slider({
	text = "Aim Smoothness",
	min = 0.05, max = 1, default = 0.18, step = 0.01,
	callback = function(v) State.Aimbot.Smoothness = v end,
})

local secESP = Section(2, "Player ESP & HUD")
secESP:Toggle({
	text = "Player Highlights",
	default = false,
	callback = function(v)
		State.ESP.Master = v
		if v then espRefresh() else espClearAll() end
		Notify("Visuals", v and "Player ESP enabled" or "Player ESP disabled")
	end,
})
secESP:Toggle({
	text = "2D ESP Boxes",
	default = false,
	callback = function(v)
		if v and not HasDrawing then
			Notify("Visuals", "Drawing API is not supported by this executor")
			return
		end
		State.ESP.Boxes = v
	end,
})
secESP:Toggle({
	text = "Center Crosshair",
	default = false,
	callback = function(v)
		crosshairEnabled = v
		CrosshairHolder.Visible = v
	end,
})
secESP:Toggle({
	text = "Radar HUD",
	default = false,
	callback = function(v)
		radarEnabled = v
		RadarFrame.Visible = v
		Notify("Radar", v and "Radar HUD enabled" or "Radar HUD hidden")
	end,
})
secESP:Toggle({ text = "Names", default = true, callback = function(v) State.ESP.Names = v end })
secESP:Toggle({ text = "Health", default = true, callback = function(v) State.ESP.Health = v end })
secESP:Toggle({ text = "Distance", default = false, callback = function(v) State.ESP.Distance = v end })
secESP:Toggle({
	text = "Tracers",
	default = false,
	callback = function(v)
		if v and not HasDrawing then
			Notify("Visuals", "Drawing API is not supported by this executor")
			return
		end
		State.ESP.Tracers = v
	end,
})
secESP:Toggle({ text = "ESP & Radar Team Check", default = true, callback = function(v) State.ESP.TeamCheck = v end })

local secWorld = Section(2, "World & Lighting")
secWorld:Toggle({ text = "Fullbright", default = false, callback = function(v) setFullbright(v) end })
secWorld:Toggle({ text = "Remove Fog", default = false, callback = function(v) setNoFog(v) end })
secWorld:Toggle({
	text = "X-Ray Walls",
	default = false,
	callback = function(v)
		setXray(v)
		Notify("Visuals", v and "X-Ray enabled" or "X-Ray restored")
	end,
})
secWorld:Slider({
	text = "Time of Day",
	min = 0, max = 24, default = Lighting.ClockTime, step = 0.5, suffix = "h",
	callback = function(v) Lighting.ClockTime = v end,
})

-- 3. TELEPORT
local secTP = Section(3, "Players")
secTP:Dropdown({
	text = "Target",
	options = playerOptions,
	callback = function(v) selectedTarget = v end,
})
secTP:Button({ text = "Teleport to Selected", style = "filled", callback = teleportToSelected })
secTP:Button({
	text = "Teleport to Nearest",
	callback = function()
		local near = getClosestPlayer()
		if near then
			teleportToPlayer(near)
		else
			Notify("Teleport", "No valid target nearby")
		end
	end,
})
secTP:Toggle({
	text = "Spectate Selected",
	default = false,
	callback = function(v) setSpectate(v, selectedTarget) end,
})

local secQuick = Section(3, "Quick Travel & Waypoints")
secQuick:Toggle({ text = "Ctrl + Click Teleport", default = false, callback = function(v) State.ClickTP = v end })
secQuick:Button({
	text = "Save Position",
	callback = function()
		local hrp = getHRP()
		if hrp then
			savedPos = hrp.CFrame
			Notify("Waypoint", "Position saved")
		else
			Notify("Waypoint", "No character")
		end
	end,
})
secQuick:Button({
	text = "Load Position",
	callback = function()
		local hrp = getHRP()
		if hrp and savedPos then
			hrp.CFrame = savedPos
			Notify("Waypoint", "Teleported back")
		else
			Notify("Waypoint", "No saved position")
		end
	end,
})
secQuick:Button({
	text = "Add Waypoint Slot",
	callback = function()
		local hrp = getHRP()
		if hrp then
			local idx = #waypoints + 1
			waypoints[idx] = hrp.CFrame
			Notify("Waypoint", "Saved Slot #" .. idx)
		end
	end,
})
secQuick:Button({
	text = "TP to Last Waypoint Slot",
	callback = function()
		local hrp = getHRP()
		if hrp and #waypoints > 0 then
			hrp.CFrame = waypoints[#waypoints]
			Notify("Waypoint", "Teleported to Slot #" .. #waypoints)
		else
			Notify("Waypoint", "No waypoint slots saved")
		end
	end,
})

-- 4. MISC
local secPerf = Section(4, "Performance")
secPerf:Toggle({
	text = "FPS Boost",
	default = false,
	callback = function(v)
		setFPSBoost(v)
		Notify("Performance", v and "FPS boost enabled" or "FPS boost disabled")
	end,
})

local secCam = Section(4, "Camera")
local sFov = secCam:Slider({
	text = "Field of View",
	min = 30, max = 120, default = Camera.FieldOfView, suffix = "°",
	callback = function(v) Camera.FieldOfView = v end,
})
secCam:Button({
	text = "Reset FOV",
	callback = function()
		sFov.Set(OriginalFOV)
		Notify("Camera", "FOV reset to " .. math.floor(OriginalFOV) .. "°")
	end,
})
secCam:Toggle({
	text = "Freecam (WASD + RMB)",
	default = false,
	callback = function(v)
		setFreecam(v)
		Notify("Freecam", v and "Enabled — WASD to move, Q/E up/down" or "Disabled")
	end,
})
secCam:Slider({ text = "Freecam Speed", min = 10, max = 150, default = 45, callback = function(v) State.FreecamSpd = v end })

local secUtil = Section(4, "Utility & Server")
secUtil:Toggle({ text = "Anti-AFK", default = true, callback = function(v) State.AntiAFK = v end })
secUtil:Button({
	text = "Reset All Modifiers",
	callback = function()
		State.Noclip = false
		State.Fly = false
		State.InfJump = false
		State.BunnyHop = false
		State.SprintBoost = false
		State.SpinBot = false
		State.FloatMode = false
		State.WalkWater = false
		State.Aimbot.Enabled = false
		lockedAimPart = nil
		if State.Spectating then setSpectate(false) end
		if State.Freecam then setFreecam(false) end
		sWalk.Set(BaseWS)
		sJump.Set(BaseJP)
		sGrav.Set(OriginalGravity)
		sFov.Set(OriginalFOV)
		Notify("Utility", "All character & camera modifiers reset")
	end,
})
secUtil:Button({
	text = "Copy Position (XYZ)",
	callback = function()
		local hrp = getHRP()
		if hrp and setclipboard then
			local p = hrp.Position
			setclipboard(string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z))
			Notify("Clipboard", "Coordinates copied")
		else
			Notify("Clipboard", "Clipboard API unavailable")
		end
	end,
})
secUtil:Button({
	text = "Copy Server JobId",
	callback = function()
		if setclipboard and game.JobId and game.JobId ~= "" then
			setclipboard(tostring(game.JobId))
			Notify("Clipboard", "Server JobId copied")
		else
			Notify("Clipboard", "JobId unavailable")
		end
	end,
})
secUtil:Button({ text = "Rejoin Server", style = "filled", callback = rejoin })
secUtil:Button({ text = "Server Hop", style = "filled", callback = serverHop })

local secStatus = Section(4, "Live Telemetry")
secStatus:Info({ text = "Executor", value = ExecutorName })
local infoPlayers = secStatus:Info({ text = "Players", value = tostring(#Players:GetPlayers()) })
local infoPos = secStatus:Info({ text = "Position", value = "0, 0, 0" })

-- 5. SETTINGS
local secTheme = Section(5, "Appearance & Island")
secTheme:AccentPicker({ text = "Accent Color" })
secTheme:Toggle({
	text = "Dynamic Island",
	default = true,
	callback = function(v)
		islandEnabled = v
		IslandHolder.Visible = v
		if not v then setIslandExpanded(false) end
	end,
})
secTheme:Toggle({
	text = "Notifications",
	default = true,
	callback = function(v) notifyEnabled = v end,
})
secTheme:Button({
	text = "Test Notification",
	callback = function() Notify("Gigachad Garage", "v1.6.0 tall UI & new modules active.") end,
})

local secKeys = Section(5, "Keybinds")
local ToggleKey = Enum.KeyCode.RightShift
secKeys:Keybind({
	text = "Toggle Interface",
	default = "RightShift",
	callback = function(key)
		ToggleKey = key
		Notify("Keybind", "Toggle key set to " .. key.Name)
	end,
})

local secAbout = Section(5, "Gigachad Garage")
secAbout:Info({ text = "Version", value = "1.6.0" })
secAbout:Info({ text = "Executor", value = ExecutorName })
secAbout:Info({ text = "Game", value = "Universal" })
secAbout:Footer("STAY SIGMA.")

-- // UI toggle -----------------------------------------------------------
local uiVisible = true
local animBusy = false
local function setUIVisible(v)
	if animBusy or v == uiVisible then return end
	animBusy = true
	uiVisible = v
	if v then
		Holder.Visible = true
		Window.GroupTransparency = 1
		WindowScale.Scale = 0.94
		tween(Window, 0.42, { GroupTransparency = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		tween(WindowScale, 0.46, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		tween(Shadow, 0.42, { ImageTransparency = 0.5 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		task.delay(0.48, function() animBusy = false end)
	else
		tween(Window, 0.28, { GroupTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		tween(WindowScale, 0.28, { Scale = 0.94 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		tween(Shadow, 0.28, { ImageTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.32, function()
			Holder.Visible = false
			animBusy = false
		end)
	end
end

makeIslandChip("UI", function() setUIVisible(not uiVisible) end)
makeIslandChip("Noclip", function() tNoclip.Set(not tNoclip.Get()) end)
makeIslandChip("Fly", function() tFly.Set(not tFly.Get()) end)
makeIslandChip("Aim", function() tAim.Set(not tAim.Get()) end)

bind(UserInputService.InputBegan, function(io, gp)
	if gp then return end
	if KeybindListening > 0 then return end
	if os.clock() - LastCaptureTick < 0.25 then return end
	if io.KeyCode == ToggleKey then
		setUIVisible(not uiVisible)
	end
end)

-- // Clock + FPS + Telemetry loops --------------------------------------
task.spawn(function()
	while Gui.Parent do
		TimeLabel.Text = os.date("%H:%M")
		task.wait(5)
	end
end)

local frames = 0
bind(RunService.RenderStepped, function() frames += 1 end)
task.spawn(function()
	while Gui.Parent do
		local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5)
		FpsLabel.Text = string.format("%d FPS  •  %d ms", frames, ping)
		if islandEnabled and not islandExpanded and islandPulseToken == 0 then
			IslandSub.Text = string.format("%d FPS • %d ms", frames, ping)
		end
		frames = 0
		infoPlayers.Set(tostring(#Players:GetPlayers()))
		local hrp = getHRP()
		if hrp then
			local p = hrp.Position
			infoPos.Set(string.format("%d, %d, %d", math.floor(p.X), math.floor(p.Y), math.floor(p.Z)))
		end
		task.wait(1)
	end
end)

-- // Unload --------------------------------------------------------------
local unloaded = false
local function Unload()
	if unloaded then return end
	unloaded = true

	State.Noclip = false
	State.Fly = false
	State.InfJump = false
	State.BunnyHop = false
	State.SprintBoost = false
	State.ClickTP = false
	State.AntiAFK = false
	State.SpinBot = false
	State.FloatMode = false
	State.WalkWater = false
	State.Aimbot.Enabled = false
	lockedAimPart = nil
	radarEnabled = false
	crosshairEnabled = false
	if State.Spectating then setSpectate(false) end
	if State.Freecam then setFreecam(false) end

	pcall(function() setFullbright(false) end)
	pcall(function() setNoFog(false) end)
	pcall(function() setXray(false) end)
	pcall(function() setFPSBoost(false) end)
	pcall(function() espClearAll() end)
	if flyBV then flyBV:Destroy() flyBV = nil end
	if floatPart then floatPart:Destroy() floatPart = nil end
	if waterPart then waterPart:Destroy() waterPart = nil end
	if fovCircle then pcall(function() fovCircle:Remove() end) end

	pcall(function() workspace.Gravity = OriginalGravity end)
	pcall(function() Camera.FieldOfView = OriginalFOV end)
	State.WalkSpeed, State.JumpPower = BaseWS, BaseJP
	pcall(function() setWalkSpeed(BaseWS) end)
	pcall(function() setJumpPower(BaseJP) end)

	for _, c in ipairs(Connections) do
		pcall(function() c:Disconnect() end)
	end

	Gui:Destroy()
	if getgenv then getgenv().GIGACHAD_GARAGE = nil end
end

secAbout:Button({
	text = "Unload",
	style = "danger",
	callback = function()
		Notify("Gigachad Garage", "Goodbye, chad. Stay sigma.")
		task.delay(0.5, Unload)
	end,
})

if getgenv then
	getgenv().GIGACHAD_GARAGE = {
		Version = "1.6.0",
		Unload = Unload,
		Notify = Notify,
	}
end

Boot.Step("Finishing up", 0.95)

-- // Splash --------------------------------------------------------------
local Splash = new("CanvasGroup", {
	BackgroundColor3 = Color3.fromRGB(8, 8, 10),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 100,
	Parent = Gui,
})
local SplashScale = new("UIScale", { Parent = Splash })

local SBrand = new("TextLabel", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0.4, 10),
	Size = UDim2.fromOffset(420, 36),
	Font = Enum.Font.GothamBlack, TextSize = 30, TextColor3 = Theme.White,
	Text = "G I G A C H A D",
	TextTransparency = 1,
	Parent = Splash,
})
local SSub = new("TextLabel", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0.4, 40),
	Size = UDim2.fromOffset(420, 16),
	Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Accent,
	Text = "G A R A G E",
	TextTransparency = 1,
	Parent = Splash,
})
trackAccent(SSub, "TextColor3")

local SDiv = new("Frame", {
	BackgroundColor3 = Theme.Stroke,
	BackgroundTransparency = 0.85,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0.4, 64),
	Size = UDim2.fromOffset(0, 1),
	Parent = Splash,
})
local SBarBg = new("Frame", {
	BackgroundColor3 = Theme.White,
	BackgroundTransparency = 0.92,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0.4, 78),
	Size = UDim2.fromOffset(160, 4),
	Parent = Splash,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SBarBg })
local SFill = new("Frame", {
	BackgroundColor3 = Accent,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(0, 1),
	Parent = SBarBg,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SFill })
trackAccent(SFill, "BackgroundColor3")

local SCap = new("TextLabel", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0.4, 100),
	Size = UDim2.fromOffset(420, 12),
	Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Theme.TextFaint,
	Text = string.upper(ExecutorName) .. "  •  UNIVERSAL  •  ALL GAMES",
	TextTransparency = 1,
	Parent = Splash,
})
local SHint = new("TextLabel", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -40),
	Size = UDim2.fromOffset(420, 12),
	Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Theme.TextFaint,
	Text = "RIGHT SHIFT — TOGGLE INTERFACE",
	TextTransparency = 1,
	Parent = Splash,
})

selectTab(1)

task.spawn(function()
	task.wait(0.22)
	tween(SBrand, 0.52, { TextTransparency = 0 })
	tween(SBrand, 0.52, { Position = UDim2.new(0.5, 0, 0.4, 0) })
	tween(SSub, 0.46, { TextTransparency = 0 }, nil, nil, 0.12)
	tween(SSub, 0.46, { Position = UDim2.new(0.5, 0, 0.4, 32) }, nil, nil, 0.12)
	tween(SDiv, 0.46, { Size = UDim2.fromOffset(140, 1) }, nil, nil, 0.2)
	tween(SFill, 0.75, { Size = UDim2.fromScale(1, 1) }, nil, nil, 0.28)
	tween(SCap, 0.4, { TextTransparency = 0.85 }, nil, nil, 0.42)
	tween(SHint, 0.4, { TextTransparency = 0.85 }, nil, nil, 0.52)
	task.wait(1.3)

	tween(Splash, 0.4, { GroupTransparency = 1 })
	tween(SplashScale, 0.4, { Scale = 1.03 })

	tween(Window, 0.5, { GroupTransparency = 0 })
	tween(WindowScale, 0.55, { Scale = 1 }, Enum.EasingStyle.Back)
	tween(Shadow, 0.5, { ImageTransparency = 0.5 })

	task.delay(0.44, function() Splash:Destroy() end)
	task.delay(0.65, function()
		Notify("Gigachad Garage", "v1.6.0 loaded on " .. ExecutorName .. ". Press Right Shift to toggle.")
	end)
end)

end, function(e)
	if debug and debug.traceback then
		return debug.traceback(tostring(e))
	end
	return tostring(e)
end)

if ok then
	print("[Gigachad Garage] v1.6.0 loaded successfully on " .. tostring(ExecutorName))
	task.defer(Boot.Finish)
else
	Boot.Error(err)
end
