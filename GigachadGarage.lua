--=====================================================================--
--  GIGACHAD GARAGE  |  UNIVERSAL HUB  |  v1.1.0
--  iPhone-grade UI. Sigma-grade power. Works in every game.
--
--  Toggle UI : Right Shift
--  Executor  : Solara (works on most executors too)
--
--  ONE-LINE LOADER — upload this file to a GitHub repo and run:
--  loadstring(game:HttpGet("https://raw.githubusercontent.com/USER/REPO/main/GigachadGarage.lua"))()
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
	barBg.Size = UDim2.fromOffset(180, 3)
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
				TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Size = UDim2.fromScale(alpha, 1) }):Play()
		end)
		task.wait(0.15)
	end

	function Boot.Finish()
		pcall(function()
			TweenService0:Create(root,
				TweenInfo.new(0.35, Enum.EasingStyle.Quint),
				{ GroupTransparency = 1 }):Play()
		end)
		task.delay(0.4, function() sg:Destroy() end)
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

local function toHex(c)
	return string.format("#%02X%02X%02X",
		math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

-- // Theme ---------------------------------------------------------------
local Theme = {
	Window     = Color3.fromRGB(18, 18, 21),
	Surface    = Color3.fromRGB(28, 28, 31),
	SurfaceAlt = Color3.fromRGB(44, 44, 48),
	TabBar     = Color3.fromRGB(13, 13, 15),
	Stroke     = Color3.fromRGB(255, 255, 255),
	TextMain   = Color3.fromRGB(238, 238, 242),
	TextDim    = Color3.fromRGB(152, 152, 160),
	TextFaint  = Color3.fromRGB(104, 104, 112),
	Danger     = Color3.fromRGB(255, 69, 58),
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
local accentTargets = {}   -- { instance, property }
local liveAccents   = {}   -- functions(c) called when accent changes

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
	local ok = pcall(function()
		Gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
	end)
	if not ok or not Gui.Parent then
		Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
end

bind(Camera:GetPropertyChangedSignal("ViewportSize"), function()
	Viewport = Camera.ViewportSize
end)

-- // Window shell --------------------------------------------------------
local WINDOW_W, WINDOW_H = 560, 372
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local UIScaleValue = 1
if IsMobile then
	UIScaleValue = math.min((Viewport.X - 16) / WINDOW_W, (Viewport.Y - 16) / WINDOW_H, 1)
	if UIScaleValue < 0.55 then UIScaleValue = 0.55 end
end
local WinW, WinH = WINDOW_W * UIScaleValue, WINDOW_H * UIScaleValue

local Holder = new("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.fromOffset(WINDOW_W, WINDOW_H),
	Position = UDim2.fromOffset((Viewport.X - WinW) / 2, (Viewport.Y - WinH) / 2),
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
	SliceScale = 1.2,
	Size = UDim2.new(1, 80, 1, 80),
	Position = UDim2.fromOffset(-40, -40),
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
new("UICorner", { CornerRadius = UDim.new(0, 26), Parent = Window })
new("UIStroke", { Color = Theme.Stroke, Transparency = 0.93, Thickness = 1, Parent = Window })
local WindowScale = new("UIScale", { Scale = 0.9, Parent = Window })

-- // Header (status bar) -------------------------------------------------
local Header = new("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 46),
	Parent = Window,
})

local TimeLabel = new("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(18, 0),
	Size = UDim2.new(0, 90, 1, 0),
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	TextColor3 = Theme.TextMain,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "9:41",
	Parent = Header,
})

local BrandPill = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(164, 28),
	BackgroundColor3 = Theme.Surface,
	BorderSizePixel = 0,
	Parent = Header,
})
new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = BrandPill })
new("UIStroke", { Color = Theme.Stroke, Transparency = 0.92, Parent = BrandPill })
local BrandText = new("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	TextColor3 = Theme.TextMain,
	RichText = true,
	Text = "GIGACHAD GARAGE",
	Parent = BrandPill,
})
liveAccents[#liveAccents + 1] = function(c)
	BrandText.Text = string.format('GIGACHAD <font color="%s">GARAGE</font>', toHex(c))
end

local FpsLabel = new("TextLabel", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -18, 0, 0),
	Size = UDim2.new(0, 120, 1, 0),
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = Theme.TextDim,
	TextXAlignment = Enum.TextXAlignment.Right,
	Text = "60 FPS",
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

-- // Content + Tab bar ---------------------------------------------------
local Content = new("Frame", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 46),
	Size = UDim2.new(1, 0, 1, -100),
	ClipsDescendants = true,
	Parent = Window,
})

local TabBar = new("Frame", {
	BackgroundColor3 = Theme.TabBar,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 1, -54),
	Size = UDim2.new(1, 0, 0, 54),
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
	Size = UDim2.fromOffset(48, 34),
	Position = UDim2.fromOffset(32, 10),
	ZIndex = 1,
	Parent = TabBar,
})
new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Pill })

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

local tabButtons = {}
local pages      = {}
local pageScrolls = {}

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
		Position = UDim2.new(0.5, 0, 0, 8),
		Size = UDim2.fromOffset(17, 17),
		Parent = btn,
	})
	local parts, strokes = buildIcon(TAB_ICONS[i], iconHolder, Theme.TextDim)
	local label = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 28),
		Size = UDim2.new(1, 0, 0, 10),
		Font = Enum.Font.GothamMedium,
		TextSize = 9,
		TextColor3 = Theme.TextDim,
		Text = TAB_NAMES[i]:upper(),
		Parent = btn,
	})
	tabButtons[i] = { btn = btn, parts = parts, strokes = strokes, label = label }

	local page = new("CanvasGroup", {
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
		ScrollBarThickness = 2,
		ScrollBarImageTransparency = 0.25,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		Parent = page,
	})
	trackAccent(scroll, "ScrollBarImageColor3")
	new("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })
	new("UIPadding", {
		PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
		PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
		Parent = scroll,
	})
	pages[i] = page
	pageScrolls[i] = scroll
end

local function computePillX(i)
	local cellW = WINDOW_W / 5
	return math.floor((i - 1) * cellW + (cellW - 48) / 2)
end

local activeTab = 0
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

	tween(Pill, 0.4, { Position = UDim2.fromOffset(computePillX(i), 10) }, Enum.EasingStyle.Back)

	for idx = 1, 5 do setTabColors(idx, idx == i) end

	local dir = i > prev and 1 or -1
	local oldPage = pages[prev]
	local newPage = pages[i]

	if oldPage then
		tween(oldPage, 0.15, { GroupTransparency = 1, Position = UDim2.fromOffset(-12 * dir, 0) })
		task.delay(0.16, function()
			if activeTab ~= prev then oldPage.Visible = false end
		end)
	end

	newPage.Visible = true
	newPage.Position = UDim2.fromOffset(14 * dir, 0)
	newPage.GroupTransparency = 1
	tween(newPage, 0.3, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) })
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
	bind(RunService.RenderStepped, function()
		if dragging and startMouse and lastMouse then
			local t = startPos + (lastMouse - startMouse)
			dragTarget = Vector2.new(
				math.clamp(t.X, -WinW * 0.5 + 10, Viewport.X - WinW * 0.5 - 10),
				math.clamp(t.Y, 4, Viewport.Y - 30)
			)
		end
		if dragTarget then
			local p = Holder.Position
			local nx = p.X.Offset + (dragTarget.X - p.X.Offset) * 0.4
			local ny = p.Y.Offset + (dragTarget.Y - p.Y.Offset) * 0.4
			if not dragging and math.abs(dragTarget.X - nx) < 0.5 and math.abs(dragTarget.Y - ny) < 0.5 then
				dragTarget = nil
			end
			Holder.Position = UDim2.fromOffset(nx, ny)
		end
	end)
end

-- // Notifications (iOS banners) -----------------------------------------
local NotifHolder = new("Frame", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 14),
	Size = UDim2.fromOffset(380, 600),
	ZIndex = 50,
	Parent = Gui,
})

local notifs = {}
local function layoutNotifs(animate)
	local y = 0
	for _, n in ipairs(notifs) do
		local target = UDim2.fromOffset(0, y)
		if animate then
			tween(n.frame, 0.4, { Position = target }, Enum.EasingStyle.Back)
		else
			n.frame.Position = target
		end
		y += n.frame.AbsoluteSize.Y + 8
	end
end

local function Notify(title, message, duration)
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
	new("UIStroke", { Color = Theme.Stroke, Transparency = 0.92, Parent = notif })
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
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder })

	local labelWrap = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		Parent = holder,
	})
	new("UIPadding", { PaddingLeft = UDim.new(0, 16), Parent = labelWrap })
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
	new("UICorner", { CornerRadius = UDim.new(0, 16), Parent = card })
	new("UIStroke", { Color = Theme.Stroke, Transparency = 0.94, Parent = card })
	new("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })
	new("UIPadding", {
		PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
		Parent = card,
	})

	local section = { count = 0 }
	local function separator()
		if section.count > 0 then
			new("Frame", {
				BackgroundColor3 = Theme.Stroke,
				BackgroundTransparency = 0.94,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 1),
				Parent = card,
			})
		end
	end

	function section:Toggle(cfg)
		separator()
		self.count += 1
		local row = new("TextButton", {
			Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 46), Parent = self.card,
		})
		new("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, -64, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.TextMain,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.text, Parent = row,
		})

		local track = new("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(50, 30),
			BackgroundColor3 = Color3.fromRGB(120, 120, 128),
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			Parent = row,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

		local knob = new("Frame", {
			Position = UDim2.fromOffset(2, 2),
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
			local targetX = state and 22 or 2
			if instant then
				knob.Position = UDim2.fromOffset(targetX, 2)
			else
				knobScale.Scale = 0.82
				tween(knobScale, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
				tween(knob, 0.35, { Position = UDim2.fromOffset(targetX, 2) }, Enum.EasingStyle.Back)
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
			Set = function(v)
				if v ~= state then
					state = v and true or false
					render(true)
				end
			end,
			Get = function() return state end,
		}
	end

	function section:Slider(cfg)
		separator()
		self.count += 1
		local row = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 66),
			Parent = self.card,
		})
		new("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 8),
			Size = UDim2.new(1, -60, 0, 14),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.TextMain,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.text, Parent = row,
		})
		local valueLabel = new("TextLabel", {
			BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 8), Size = UDim2.new(0, 60, 0, 14),
			Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.TextDim,
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = "", Parent = row,
		})

		local hit = new("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 32),
			Size = UDim2.new(1, 0, 0, 32),
			Parent = row,
		})
		local trackBg = new("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 5),
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
		local dragging = false

		local function setValue(v, fire)
			v = math.clamp(v, min, max)
			v = min + math.floor((v - min) / step + 0.5) * step
			v = tonumber(string.format("%.2f", v))
			val = v
			local alpha = (max ~= min) and ((v - min) / (max - min)) or 0
			fill.Size = UDim2.fromScale(alpha, 1)
			knob.Position = UDim2.new(alpha, 0, 0.5, 0)
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

		-- Initial render only: must NOT fire the callback, so loading the hub never touches the game
		task.defer(function() setValue(cfg.default or min, false) end)

		return { Set = function(v) setValue(v, true) end }
	end

	function section:Button(cfg)
		if cfg.style == "filled" or cfg.style == "danger" then
			separator()
			self.count += 1
			local wrap = new("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 58),
				Parent = self.card,
			})
			new("UIPadding", { PaddingTop = UDim.new(0, 9), PaddingBottom = UDim.new(0, 9), Parent = wrap })
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
				task.delay(0.08, function() tween(scale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back) end)
				if cfg.callback then cfg.callback() end
			end)
		else
			separator()
			self.count += 1
			local row = new("TextButton", {
				Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 46), Parent = self.card,
			})
			new("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -26, 1, 0),
				Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.TextMain,
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
		separator()
		self.count += 1
		local row = new("TextButton", {
			Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 46), Parent = self.card,
		})
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, 0, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.TextMain,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.text, Parent = row,
		})
		local valueLabel = new("TextLabel", {
			BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -18, 0.5, 0), Size = UDim2.new(0.5, -18, 0, 16),
			Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.TextDim,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = "—", Parent = row,
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
			Parent = self.card,
		})
		new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

		local open = false
		local selected = nil

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
					Font = Enum.Font.Gotham, TextSize = 13,
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
			local h = #opts * 36 + 6
			tween(list, 0.35, { Size = UDim2.new(1, 0, 0, h) }, Enum.EasingStyle.Quart)
		end

		row.Activated:Connect(function()
			if open then closeList() else openList() end
		end)
	end

	function section:Keybind(cfg)
		separator()
		self.count += 1
		local row = new("TextButton", {
			Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 46), Parent = self.card,
		})
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -110, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.TextMain,
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
			Size = UDim2.new(0, 0, 0, 26),
			Parent = row,
		})
		new("UICorner", { CornerRadius = UDim.new(0, 9), Parent = badge })
		local stroke = new("UIStroke", { Color = Accent, Transparency = 1, Parent = badge })
		trackAccent(stroke, "Color")
		new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = badge })
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
		separator()
		self.count += 1
		local row = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 50),
			Parent = self.card,
		})
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -180, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.TextMain,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = cfg.text, Parent = row,
		})
		local holder = new("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(0, 6 * 22 + 5 * 8, 0, 24),
			Parent = row,
		})
		new("UIListLayout", {
			Padding = UDim.new(0, 8),
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
				Size = UDim2.fromOffset(22, 22),
				AutoButtonColor = false,
				Parent = holder,
			})
			new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sw })
			local ring = new("UIStroke", { Color = Theme.White, Thickness = 1.6, Transparency = 1, Parent = sw })
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
		separator()
		self.count += 1
		local row = new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 44),
			Parent = self.card,
		})
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0.6, 0, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.TextMain,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = cfg.text, Parent = row,
		})
		new("TextLabel", {
			BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.4, 0, 0, 16),
			Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.TextDim,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.value, Parent = row,
		})
	end

	function section:Footer(text)
		separator()
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
	WalkSpeed = BaseWS,
	JumpPower = BaseJP,
	InfJump  = false,
	Noclip   = false,
	Fly      = false,
	FlySpeed = 60,
	ClickTP  = false,
	AntiAFK  = true,
	ESP = { Master = false, Names = true, Distance = false, Tracers = false, TeamCheck = true },
}

local function getChar() return LocalPlayer.Character end
local OriginalGravity = workspace.Gravity
local OriginalFOV = Camera.FieldOfView
local function getHRP()
	local c = getChar()
	return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
	local c = getChar()
	return c and c:FindFirstChildOfClass("Humanoid")
end

-- // Movement ------------------------------------------------------------
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

task.spawn(function()
	while Gui.Parent do
		task.wait(0.8)
		local hum = getHum()
		if hum then
			if State.WalkSpeed ~= BaseWS and hum.WalkSpeed ~= State.WalkSpeed then
				hum.WalkSpeed = State.WalkSpeed
			end
			if State.JumpPower ~= BaseJP and math.floor(hum.JumpPower + 0.5) ~= State.JumpPower then
				pcall(function() hum.JumpPower = State.JumpPower end)
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

-- // Noclip --------------------------------------------------------------
bind(RunService.Stepped, function()
	if State.Noclip then
		local char = getChar()
		if char then
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
			end
		end
	end
end)

-- // Fly -----------------------------------------------------------------
local flyBV = nil
bind(RunService.Heartbeat, function()
	local hrp = getHRP()
	if State.Fly and hrp then
		if not flyBV or flyBV.Parent ~= hrp then
			if flyBV then flyBV:Destroy() end
			flyBV = new("BodyVelocity", {
				MaxForce = Vector3.new(1e9, 1e9, 1e9),
				Velocity = Vector3.new(0, 0, 0),
				Parent = hrp,
			})
		end
		local camCF = Camera.CFrame
		local dir = Vector3.new(0, 0, 0)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camCF.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camCF.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camCF.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camCF.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
		if dir.Magnitude > 0 then dir = dir.Unit * State.FlySpeed end
		flyBV.Velocity = dir
	elseif flyBV then
		flyBV:Destroy()
		flyBV = nil
	end
end)

-- // Ctrl + Click TP -----------------------------------------------------
bind(UserInputService.InputBegan, function(io, gp)
	if gp then return end
	if State.ClickTP and io.UserInputType == Enum.UserInputType.MouseButton1
		and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		local hrp = getHRP()
		if hrp then
			hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
		end
	end
end)

-- // Fullbright ----------------------------------------------------------
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

-- // ESP -----------------------------------------------------------------
local HasDrawing = pcall(function()
	local l = Drawing.new("Line")
	l:Remove()
end)

local espFolder = new("Folder", { Name = "ESP", Parent = Gui })
local espCache = {}

local function espRemove(plr)
	local d = espCache[plr]
	if d then
		if d.hl then d.hl:Destroy() end
		if d.bb then d.bb:Destroy() end
		if d.line then pcall(function() d.line:Remove() end) end
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
		Size = UDim2.fromOffset(220, 40),
		StudsOffset = Vector3.new(0, 2.4, 0),
		AlwaysOnTop = true,
		Enabled = false,
		Parent = espFolder,
	})
	d.nameL = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.White,
		TextStrokeTransparency = 0.4,
		Text = plr.DisplayName, Parent = d.bb,
	})
	d.distL = new("TextLabel", {
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
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local valid = (char and head and hum and hum.Health > 0) and true or false
		local sameTeam = (State.ESP.TeamCheck and plr.Team ~= nil and LocalPlayer.Team ~= nil
			and plr.Team == LocalPlayer.Team) and true or false
		local masterOn = (State.ESP.Master and valid and not sameTeam) and true or false

		if d.hl then
			d.hl.Adornee = char
			d.hl.Enabled = masterOn
		end

		local showBB = (masterOn and (State.ESP.Names or State.ESP.Distance)) and true or false
		if d.bb then
			d.bb.Adornee = head
			d.bb.Enabled = showBB
			d.nameL.Visible = State.ESP.Names
			d.distL.Visible = State.ESP.Distance
			if showBB and State.ESP.Distance and myHRP and head then
				d.distL.Text = string.format("%d studs", (head.Position - myHRP.Position).Magnitude)
			else
				d.distL.Text = ""
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

-- // Teleport helpers ----------------------------------------------------
local selectedTarget = nil
local savedPos = nil

local function playerOptions()
	local list = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then table.insert(list, plr.Name) end
	end
	table.sort(list)
	return list
end

local function teleportToSelected()
	if not selectedTarget then
		Notify("Teleport", "Select a player first")
		return
	end
	local target = Players:FindFirstChild(selectedTarget)
	local hrp = getHRP()
	local tChar = target and target.Character
	local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
	if hrp and tHRP then
		hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3)
		Notify("Teleport", "Teleported to " .. target.DisplayName)
	else
		Notify("Teleport", "Target has no character")
	end
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
	local ok = pcall(function()
		local req = request or (syn and syn.request) or http_request
		if not req then error("no http") end
		local res = req({
			Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=2&excludeFullGames=true&limit=100",
			Method = "GET",
		})
		body = HttpService:JSONDecode(res.Body)
	end)
	if ok and body and body.data and #body.data > 0 then
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
-- PLAYER
local secMove = Section(1, "Movement")
secMove:Slider({ text = "Walk Speed", min = 0, max = 250, default = BaseWS, callback = setWalkSpeed })
secMove:Slider({ text = "Jump Power", min = 0, max = 300, default = BaseJP, callback = setJumpPower })
secMove:Slider({ text = "Gravity", min = 0, max = 500, default = workspace.Gravity, step = 0.1, callback = function(v)
	workspace.Gravity = v
end })

local secAbil = Section(1, "Abilities")
secAbil:Toggle({ text = "Infinite Jump", default = false, callback = function(v) State.InfJump = v end })
secAbil:Toggle({ text = "Noclip", default = false, callback = function(v) State.Noclip = v end })
secAbil:Toggle({
	text = "Fly",
	default = false,
	callback = function(v)
		State.Fly = v
		Notify("Fly", v and "Enabled — WASD to move, Space up, Ctrl down" or "Disabled")
	end,
})
secAbil:Slider({ text = "Fly Speed", min = 10, max = 200, default = 60, callback = function(v) State.FlySpeed = v end })

-- VISUALS
local secESP = Section(2, "Players")
secESP:Toggle({
	text = "Player Highlights",
	default = false,
	callback = function(v)
		State.ESP.Master = v
		if v then espRefresh() else espClearAll() end
		Notify("Visuals", v and "Player highlights enabled" or "Player highlights disabled")
	end,
})
secESP:Toggle({ text = "Names", default = true, callback = function(v) State.ESP.Names = v end })
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
secESP:Toggle({ text = "Team Check", default = true, callback = function(v) State.ESP.TeamCheck = v end })

local secWorld = Section(2, "World")
secWorld:Toggle({
	text = "Fullbright",
	default = false,
	callback = function(v) setFullbright(v) end,
})

-- TELEPORT
local secTP = Section(3, "Players")
secTP:Dropdown({
	text = "Target",
	options = playerOptions,
	callback = function(v) selectedTarget = v end,
})
secTP:Button({
	text = "Refresh Player List",
	callback = function() Notify("Teleport", "Open the target list to refresh") end,
})
secTP:Button({ text = "Teleport", style = "filled", callback = teleportToSelected })

local secQuick = Section(3, "Quick Travel")
secQuick:Toggle({
	text = "Ctrl + Click Teleport",
	default = false,
	callback = function(v) State.ClickTP = v end,
})
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

-- MISC
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
secCam:Slider({
	text = "Field of View",
	min = 30, max = 120, default = Camera.FieldOfView,
	callback = function(v) Camera.FieldOfView = v end,
})

local secUtil = Section(4, "Utility")
secUtil:Toggle({ text = "Anti-AFK", default = true, callback = function(v) State.AntiAFK = v end })
secUtil:Button({ text = "Rejoin Server", style = "filled", callback = rejoin })
secUtil:Button({ text = "Server Hop", style = "filled", callback = serverHop })

local secStatus = Section(4, "Status")
secStatus:Info({ text = "Executor", value = ExecutorName })
secStatus:Info({ text = "Ping", value = "shown in the header" })
secStatus:Info({ text = "Script", value = "Universal — all games" })

-- SETTINGS
local secTheme = Section(5, "Appearance")
secTheme:AccentPicker({ text = "Accent Color" })
secTheme:Toggle({
	text = "Notifications",
	default = true,
	callback = function(v) notifyEnabled = v end,
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
secAbout:Info({ text = "Version", value = "1.1.0" })
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
		WindowScale.Scale = 0.92
		tween(Window, 0.35, { GroupTransparency = 0 })
		tween(WindowScale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
		tween(Shadow, 0.35, { ImageTransparency = 0.5 })
		task.delay(0.42, function() animBusy = false end)
	else
		tween(Window, 0.25, { GroupTransparency = 1 })
		tween(WindowScale, 0.25, { Scale = 0.92 })
		tween(Shadow, 0.25, { ImageTransparency = 1 })
		task.delay(0.3, function()
			Holder.Visible = false
			animBusy = false
		end)
	end
end

bind(UserInputService.InputBegan, function(io, gp)
	if gp then return end
	if KeybindListening > 0 then return end
	if os.clock() - LastCaptureTick < 0.25 then return end
	if io.KeyCode == ToggleKey then
		setUIVisible(not uiVisible)
	end
end)

-- // Clock + FPS loops ---------------------------------------------------
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
		frames = 0
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
	State.ClickTP = false
	State.AntiAFK = false

	pcall(function() setFullbright(false) end)
	pcall(function() setFPSBoost(false) end)
	pcall(function() espClearAll() end)
	if flyBV then flyBV:Destroy() flyBV = nil end

	-- Put the game back exactly as it was
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

getgenv().GIGACHAD_GARAGE = {
	Version = "1.1.0",
	Unload = Unload,
	Notify = Notify,
}

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
	task.wait(0.3)
	tween(SBrand, 0.55, { TextTransparency = 0 })
	tween(SBrand, 0.55, { Position = UDim2.new(0.5, 0, 0.4, 0) })
	tween(SSub, 0.5, { TextTransparency = 0 }, nil, nil, 0.15)
	tween(SSub, 0.5, { Position = UDim2.new(0.5, 0, 0.4, 32) }, nil, nil, 0.15)
	tween(SDiv, 0.5, { Size = UDim2.fromOffset(140, 1) }, nil, nil, 0.25)
	tween(SFill, 0.85, { Size = UDim2.fromScale(1, 1) }, nil, nil, 0.35)
	tween(SCap, 0.4, { TextTransparency = 0.85 }, nil, nil, 0.5)
	tween(SHint, 0.4, { TextTransparency = 0.85 }, nil, nil, 0.6)
	task.wait(1.55)

	tween(Splash, 0.4, { GroupTransparency = 1 })
	tween(SplashScale, 0.4, { Scale = 1.03 })

	tween(Window, 0.5, { GroupTransparency = 0 })
	tween(WindowScale, 0.55, { Scale = 1 }, Enum.EasingStyle.Back)
	tween(Shadow, 0.5, { ImageTransparency = 0.5 })

	task.delay(0.45, function() Splash:Destroy() end)
	task.delay(0.7, function()
		Notify("Gigachad Garage", "Loaded on " .. ExecutorName .. ". Press Right Shift to toggle the UI.")
	end)
end)

end, function(e)
	if debug and debug.traceback then
		return debug.traceback(tostring(e))
	end
	return tostring(e)
end)

if ok then
	print("[Gigachad Garage] v1.1.0 loaded successfully on " .. tostring(ExecutorName))
	task.defer(Boot.Finish)
else
	Boot.Error(err)
end
