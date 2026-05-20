--// Header.lua //--
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui") or game:GetService("CoreGui")

--// Globals
local screenGui = Instance.new("ScreenGui", CoreGui)
if _G.HUBSCREENGUI then
    _G.HUBSCREENGUI:Destroy()
end
_G.HUBSCREENGUI = screenGui

--// Values
local initializated = false

--// Configs
local width = 500
local height = 300
local header_height = 32
local tabs_width = 48
local tab_size = 16
local spacing = 16

local primary_color = Color3.fromHex("060d12")
local primary_color2 = Color3.fromHex("081219")
local secondary_color = Color3.fromHex("428BA1")
local tertiary_color = Color3.fromHex("7796a5")
local quaternary_color = Color3.fromHex("5A717D")
local icon_color = Color3.fromHex("#50ACC3")
local icon_color2 = Color3.fromHex("#64A1B4")

local primary_roundness = 18
local secondary_roundness = 12

local primary_font = Enum.Font.GothamBold
local secondary_font = Enum.Font.GothamMedium

--// Utils.lua //--
local lastTouch, touchPos = nil, nil

--// Methods
local function animate(instance, time, properties, style, ...)
	local track = game:GetService("TweenService"):Create(instance, TweenInfo.new(time, style or Enum.EasingStyle.Quad, ...), properties)
	track:Play()
	return track
end

local function isTouchDown()
	return lastTouch ~= nil
end

local function getTouchPos()
	return isTouchDown() and touchPos or nil
end

--// Connections
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		lastTouch = input
		touchPos = input.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == lastTouch then
		touchPos = input.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		if lastTouch ~= input then return end

		lastTouch = nil
	end
end)

--// Components.lua //--
--// Window Components
local function buildHeaderDiv(parent)
	local div = Instance.new("Frame", parent)
	div.Size = UDim2.new(1,0,0,header_height)
	div.BackgroundTransparency = 1

	local dlayout = Instance.new("UIListLayout", div)
	dlayout.FillDirection = Enum.FillDirection.Horizontal
	dlayout.VerticalAlignment = Enum.VerticalAlignment.Center
	dlayout.HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween
	dlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	dlayout.SortOrder  = Enum.SortOrder.LayoutOrder

	local dpadding = Instance.new("UIPadding", div)
	dpadding.PaddingLeft = UDim.new(0,6)
	dpadding.PaddingRight = UDim.new(0,6)

    --// Icon
	local iconDiv = Instance.new("Frame", div)
	iconDiv.Size = UDim2.new(0,32,0,32)
	iconDiv.BackgroundTransparency = 1
	iconDiv.LayoutOrder = 1

	local icon = Instance.new("ImageLabel", iconDiv)
	icon.Size = UDim2.new(0,32,0,32)
	icon.Position = UDim2.new(.5,0,.5,0)
	icon.AnchorPoint = Vector2.new(.5,.5)
	icon.BackgroundTransparency = 1
	icon.Image = "rbxassetid://110631897823699"
	icon.ImageColor3 = icon_color

    --// Title
    local titleDiv = Instance.new("Frame", div)
    titleDiv.Size = UDim2.new(0,0,1,0)
    titleDiv.AutomaticSize = Enum.AutomaticSize.X
    titleDiv.BackgroundTransparency = 1
    titleDiv.LayoutOrder = 2

    local titleLabel = Instance.new("TextLabel", titleDiv)
    titleLabel.Size = UDim2.new(0,0,0,0)
    titleLabel.Position = UDim2.new(.5,0,0,0)
    titleLabel.AnchorPoint = Vector2.new(.5,0)
    titleLabel.Text = "SHARK v2"
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = tertiary_color
    titleLabel.Font = primary_font

    local subtitleLabel = Instance.new("TextLabel", titleDiv)
    subtitleLabel.Size = UDim2.new(0,0,0,0)
    subtitleLabel.Position = UDim2.new(.5,0,1,0)
    subtitleLabel.AnchorPoint = Vector2.new(.5,1)
    subtitleLabel.Text = "Death Ball [ 5kg ]"
    subtitleLabel.TextSize = 12
    subtitleLabel.TextColor3 = quaternary_color
    subtitleLabel.Font = secondary_font
	subtitleLabel.TextTransparency = .3

    local tdpadding = Instance.new("UIPadding", titleDiv)
    tdpadding.PaddingTop = UDim.new(0,10)
    tdpadding.PaddingBottom = UDim.new(0,6)

    --// Hide
	local hide = Instance.new("ImageButton", div)
	hide.Size = UDim2.new(0,24,0,24)
	hide.BackgroundTransparency = 1
	hide.Image = "rbxassetid://10734896206"
	hide.ImageColor3 = secondary_color
	hide.LayoutOrder = 3
	hide.ResampleMode = Enum.ResamplerMode.Pixelated

	task.spawn(function()
		while true do
			animate(icon, 2, {Rotation = 15})
			animate(icon, 1, {ImageTransparency=.01}, Enum.EasingStyle.Quad)
			task.wait(1)
			animate(icon, 1, {ImageTransparency=.31}, Enum.EasingStyle.Quad)
			task.wait(1)
			animate(icon, 2, {Rotation = -15})
			animate(icon, 1, {ImageTransparency=.01}, Enum.EasingStyle.Quad)
			task.wait(1)
			animate(icon, 1, {ImageTransparency=.31}, Enum.EasingStyle.Quad)
			task.wait(1)
		end
	end)

	return div, hide
end

local function buildContentDiv(parent)
	local div = Instance.new("Frame", parent)
	div.Size = UDim2.new(1,0,1,-header_height-spacing)
	div.Position = UDim2.new(0,0,0,header_height+spacing)
	div.BackgroundTransparency = 1

	return div
end

local function buildTabsDiv(parent)
	local tabs = Instance.new("Frame", parent)
	tabs.Size = UDim2.new(0,tabs_width,1,0)
	tabs.BackgroundTransparency = 1

	local tlayout = Instance.new("UIListLayout", tabs)
	tlayout.FillDirection = Enum.FillDirection.Vertical
	tlayout.VerticalFlex = Enum.UIFlexAlignment.SpaceAround
	tlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local tstroke = Instance.new("UIStroke", tabs)
	tstroke.Color = secondary_color
	tstroke.Transparency = .9

	local tcorner = Instance.new("UICorner", tabs)
	tcorner.CornerRadius = UDim.new(0,primary_roundness)

	return tabs
end

local function buildHandlerDiv(parent)
	local handler = Instance.new("Frame", parent)
	handler.Size = UDim2.new(1,-tabs_width-spacing,1,0)
	handler.Position = UDim2.new(0,tabs_width+spacing,0,0)
	handler.BackgroundTransparency = 1
    handler.ClipsDescendants = true

	local hlayout = Instance.new("UIPageLayout", handler)
	hlayout.SortOrder = Enum.SortOrder.LayoutOrder
	hlayout.TweenTime = .4
    hlayout.EasingStyle = Enum.EasingStyle.Quad
    hlayout.EasingDirection = Enum.EasingDirection.Out
	hlayout.FillDirection = Enum.FillDirection.Vertical

	local hstroke = Instance.new("UIStroke", handler)
	hstroke.Color = secondary_color
	hstroke.Transparency = .9

	local hcorner = Instance.new("UICorner", handler)
	hcorner.CornerRadius = UDim.new(0,primary_roundness)

    local emptyFrame = Instance.new("Frame", handler)
    emptyFrame.Size = UDim2.new(1,0,1,0)
    emptyFrame.BackgroundTransparency = 1

	return handler
end

local function buildTabFrame(parent)
	local frame = Instance.new("ScrollingFrame", parent)
	frame.Size = UDim2.new(1,0,1,0)
	frame.BackgroundTransparency = 1
	frame.CanvasSize = UDim2.new(0,0,0,0)
	frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	frame.ScrollBarThickness = 0

	local flayout = Instance.new("UIListLayout", frame)
	flayout.FillDirection = Enum.FillDirection.Vertical

	local fpadding = Instance.new("UIPadding", frame)
	fpadding.PaddingTop = UDim.new(0,spacing/3)
	fpadding.PaddingBottom = UDim.new(0,spacing/3)
	fpadding.PaddingLeft = UDim.new(0,spacing/3)
	fpadding.PaddingRight = UDim.new(0,spacing/3)

	return frame
end

local function buildTabButton(parent, imageId)
	local button = Instance.new("TextButton", parent)
	button.Size = UDim2.new(0,32,0,32)
	button.BackgroundTransparency = 1
	button.BackgroundColor3 = secondary_color
	button.Text = ""
	button.AutoButtonColor = false

	local bcorner = Instance.new("UICorner", button)
	bcorner.CornerRadius = UDim.new(0,secondary_roundness)

	local image = Instance.new("ImageLabel", button)
	image.Size = UDim2.new(0,16,0,16)
	image.Position = UDim2.new(0.5,0,0.5,0)
	image.AnchorPoint = Vector2.new(0.5,0.5)
	image.BackgroundTransparency = 1
	image.ImageColor3 = tertiary_color
	image.Image = imageId

	button.MouseEnter:Connect(function()
		animate(image, .15, {ImageColor3 = secondary_color, Rotation = math.random(1,2) == 1 and 10 or -10})
	end)

	button.MouseLeave:Connect(function()
		animate(image, .15, {ImageColor3 = tertiary_color, Rotation = 0})
	end)

	return button
end

--// Elements Components
local function buildElementDiv(parent)

	-- Div
	local div = Instance.new("TextButton", parent)
	div.Size = UDim2.new(1,0,0,0)
	div.BackgroundTransparency = 1
	div.AutomaticSize = Enum.AutomaticSize.Y
	div.Text = ""

	local dpadding = Instance.new("UIPadding", div)
	dpadding.PaddingTop = UDim.new(0,10)
	dpadding.PaddingBottom = UDim.new(0,10)
	dpadding.PaddingLeft = UDim.new(0,6)
	dpadding.PaddingRight = UDim.new(0,6)

	return div, dpadding
end

local function buildParagraph(parent, reducedSize)

	-- Div
	local div = Instance.new("Frame", parent)
	div.AutomaticSize = Enum.AutomaticSize.Y
	div.BackgroundTransparency = 1
	div.Size = UDim2.new(1,-(reducedSize or 0),0,0)

	local dlayout = Instance.new("UIListLayout", div)
	dlayout.Padding = UDim.new(0,3)
	dlayout.VerticalAlignment = Enum.VerticalAlignment.Center

	-- Title
	local title = Instance.new("TextLabel", div)
	title.Text = ""
	title.TextSize = 14
	title.TextWrapped = true
	title.Font = Enum.Font.GothamMedium
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, 0)
	title.TextColor3 = quaternary_color
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.AutomaticSize = Enum.AutomaticSize.Y

	-- Description
	local desc = Instance.new("TextLabel", div)
	desc.Text = ""
	desc.TextSize = 12
	desc.TextWrapped = true
	desc.Font = Enum.Font.GothamMedium
	desc.BackgroundTransparency = 1
	desc.Size = UDim2.new(1, 0, 0, 0)
	desc.TextColor3 = quaternary_color
	desc.TextTransparency = .5
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.AutomaticSize = Enum.AutomaticSize.Y

	return div, title, desc
end

local function buildSection(parent)

	-- Div
	local div = Instance.new("Frame", parent)
	div.Size = UDim2.new(1,0,0,0)
	div.BackgroundTransparency = 1
	div.AutomaticSize = Enum.AutomaticSize.Y

	local dpadding = Instance.new("UIPadding", div)
	dpadding.PaddingTop = UDim.new(0,0)
	dpadding.PaddingBottom = UDim.new(0,0)

	-- Label
	local label = Instance.new("TextLabel", div)
	label.Size = UDim2.new(1,0,0,0)
	label.BackgroundTransparency = 1
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.TextSize = 10

	return div
end

local function buildToggle(parent)

	-- Div
	local div = Instance.new("Frame", parent)
	div.Size = UDim2.new(0,24,0,24)
	div.BackgroundColor3 = primary_color
	div.BorderSizePixel = 0

	local dcorner = Instance.new("UICorner", div)
	dcorner.CornerRadius = UDim.new(0,6)

	-- Extern
	local extern = Instance.new("Frame", div)
	extern.Size = UDim2.new(0,16,0,16)
	extern.BackgroundColor3 = primary_color
	extern.Position = UDim2.new(.5,0,.5,0)
	extern.AnchorPoint = Vector2.new(.5,.5)

	local ecorner = Instance.new("UICorner", extern)
	ecorner.CornerRadius = UDim.new(0,6)

	local estroke = Instance.new("UIStroke", extern)
	estroke.Color = secondary_color

	-- Intern
	local intern = Instance.new("ImageLabel", extern)
	intern.Size = UDim2.new(0,12,0,12)
	intern.Position = UDim2.new(.5,0,.5,0)
	intern.AnchorPoint = Vector2.new(.5,.5)
	intern.BackgroundColor3 = secondary_color
	intern.Image = ""
	--intern.Image = "rbxassetid://10709790644"

	local icorner = Instance.new("UICorner", intern)
	icorner.CornerRadius = UDim.new(0,4)

	local iscale = Instance.new("UIScale", intern)

	-- Controller
	local controller = {
		Div = div,
	}

	function controller:Toggle()
		estroke.Color = Color3.fromHex("FFFFFF")

		animate(iscale, .3, {Scale = 1})
		animate(intern, .3, {Rotation = 0})
		animate(icorner, .3, {CornerRadius = UDim.new(0,4)})
		animate(estroke, .3, {Color = secondary_color})
	end

	function controller:Untoggle()
		estroke.Color = Color3.fromHex("FFFFFF")

		animate(iscale, .3, {Scale = 0})
		animate(intern, .3, {Rotation = -90})
		animate(icorner, .3, {CornerRadius = UDim.new(.7,0)})
		animate(estroke, .3, {Color = secondary_color})
	end

	return controller
end

local function buildInput(parent)

	-- Div
	local div = Instance.new("TextBox", parent)
	div.Size = UDim2.new(0,96,0,24)
	div.BackgroundColor3 = primary_color2
	div.BorderSizePixel = 0
	div.TextColor3 = quaternary_color
	div.ClearTextOnFocus = false
	div.TextScaled = true
	div.Font = secondary_font
	div.TextSize = 12

	local dpadding = Instance.new("UIPadding", div)
	dpadding.PaddingTop = UDim.new(0,5)
	dpadding.PaddingBottom = UDim.new(0,5)
	dpadding.PaddingLeft = UDim.new(0,5)
	dpadding.PaddingRight = UDim.new(0,5)

	local dcorner = Instance.new("UICorner", div)
	dcorner.CornerRadius = UDim.new(0,6)

	-- Footer
	local footer = Instance.new("Frame", div)
	footer.Size = UDim2.new(1,2,0,1)
	footer.Position = UDim2.new(.5,0,1,5)
	footer.AnchorPoint = Vector2.new(.5,1)
	footer.BackgroundColor3 = secondary_color
	footer.BorderSizePixel = 0

	-- Connections
	div:GetPropertyChangedSignal("ContentText"):Connect(function()
		div.TextColor3 = secondary_color

		animate(div, .3, {TextColor3 = quaternary_color})
	end)

	div.FocusLost:Connect(function()
		footer.Position = UDim2.new(.5,0,1,5)
		footer.BackgroundColor3 = Color3.fromHex("FFFFFF")

		animate(footer, .3, {BackgroundColor3 = secondary_color})
	end)

	-- Controller
	local controller = {
		Div = div,
	}

	function controller:Change(text)
		div.Text = text
	end

	return controller
end

local function buildButton(parent)

	-- Div
	local div = Instance.new("Frame", parent)
	div.Size = UDim2.new(0,27,0,24)
	div.BackgroundColor3 = primary_color
	div.BorderSizePixel = 0

	local dcorner = Instance.new("UICorner", div)
	dcorner.CornerRadius = UDim.new(0,6)

	-- Image
	local image = Instance.new("ImageLabel", div)
	image.Size = UDim2.new(0,16,0,16)
	image.BackgroundTransparency = 1
	image.Image = "rbxassetid://10734898355"
	image.Position = UDim2.new(.5,0,.5,0)
	image.AnchorPoint = Vector2.new(.5,.5)
	image.ImageColor3 = secondary_color

	-- Controller
	local controller = {
		Div = div,
	}

	function controller:Press()
		image.ImageColor3 = Color3.fromHex("FFFFFF")

		animate(image, .4, {ImageColor3 = secondary_color})
	end

	return controller
end

local function buildSlider(parent)

	-- Div
	local div = Instance.new("Frame", parent)
	div.Size = UDim2.new(0,112,0,24)
	div.BackgroundColor3 = primary_color
	div.BorderSizePixel = 0

	local dcorner = Instance.new("UICorner", div)
	dcorner.CornerRadius = UDim.new(0,6)

	local dpadding = Instance.new("UIPadding", div)
	dpadding.PaddingLeft = UDim.new(0,6)
	dpadding.PaddingRight = UDim.new(0,6)

	-- Extern
	local extern = Instance.new("Frame", div)
	extern.Size = UDim2.new(1,0,0,6)
	extern.Position = UDim2.new(0,0,.5,0)
	extern.AnchorPoint = Vector2.new(0,.5)
	extern.BackgroundTransparency = 1
	extern.BackgroundColor3 = secondary_color

	local estroke = Instance.new("UIStroke", extern)
	estroke.Color = secondary_color
	estroke.Transparency = .5

	local ecorner = Instance.new("UICorner", extern)
	ecorner.CornerRadius = UDim.new(0,4)

	-- Intern
	local intern = Instance.new("Frame", div)
	intern.Size = UDim2.new(.5,0,0,6)
	intern.Position = UDim2.new(0,0,.5,0)
	intern.AnchorPoint = Vector2.new(0,.5)
	intern.BorderSizePixel = 0
	intern.BackgroundColor3 = secondary_color

	local icorner = Instance.new("UICorner", intern)
	icorner.CornerRadius = UDim.new(0,4)

	-- Point
	local point = Instance.new("Frame", div)
	point.Size = UDim2.new(0,6,0,16)
	point.Position = UDim2.new(.5,0,.5,0)
	point.AnchorPoint = Vector2.new(.5,.5)
	point.BackgroundColor3 = secondary_color
	point.BorderSizePixel = 0

	local pcorner = Instance.new("UICorner", point)
	pcorner.CornerRadius = UDim.new(0,2)

	-- Label
	local label = Instance.new("TextLabel", div)
	label.Size = UDim2.new(0,0,0,24)
	label.Position = UDim2.new(0,-12,.5,0)
	label.AnchorPoint = Vector2.new(1,.5)
	label.BackgroundTransparency = 1
	label.Text = ".5"
	label.TextColor3 = quaternary_color
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Font = secondary_font
	label.TextSize = 12

	-- Area
	local area = Instance.new("TextButton", extern)
	area.Size = UDim2.new(1,8,1,24)
	area.Position = UDim2.new(.5,0,0.5,0)
	area.AnchorPoint = Vector2.new(.5,.5)
	area.BackgroundTransparency = 1
	area.Text = ""

	-- Controller
	local controller = {
		Div = div,
		Extern = extern,
		Area = area,
	}

	function controller:Slide(scale, shownValue)
		point.BackgroundColor3 = Color3.fromHex("FFFFFF")
		label.TextColor3 = secondary_color
		label.Text = shownValue

		animate(point, .3, {BackgroundColor3 = secondary_color})
		animate(point, .15, {Position = UDim2.new(scale,0,.5,0)})
		animate(intern, .15, {Size = UDim2.new(scale,0,0,6)})
		animate(label, .3, {TextColor3 = quaternary_color})
	end

	return controller
end

local function buildKeybind(parent)

	-- Div
	local div = Instance.new("TextLabel", parent)
	div.Size = UDim2.new(24,0,0,24)
	div.TextXAlignment = Enum.TextXAlignment.Right
	div.BackgroundTransparency = 1
	div.TextColor3 = secondary_color
	div.Font = secondary_font
	div.Text = "Space"
	div.TextSize = 13

	local dpadding = Instance.new("UIPadding", div)
	dpadding.PaddingRight = UDim.new(0,8)

	-- Controller
	local controller = {
		Div = div,
	}

	function controller:Change(text)
		div.Text = text
		div.TextColor3 = Color3.fromHex("FFFFFF")

		animate(div, .3, {TextColor3 = secondary_color})
	end

	return controller
end

local function buildDropdown(parent)

	-- Div
	local div = Instance.new("TextLabel", parent)
	div.Size = UDim2.new(0,112,0,24)
	div.BackgroundColor3 = primary_color2
	div.BorderSizePixel = 0
	div.TextColor3 = secondary_color
	div.TextScaled = true
	div.Font = secondary_font
	div.TextSize = 12

	local dpadding = Instance.new("UIPadding", div)
	dpadding.PaddingTop = UDim.new(0,5)
	dpadding.PaddingBottom = UDim.new(0,5)
	dpadding.PaddingLeft = UDim.new(0,5)
	dpadding.PaddingRight = UDim.new(0,14)

	local dcorner = Instance.new("UICorner", div)
	dcorner.CornerRadius = UDim.new(0,6)

	local dsize = Instance.new("UISizeConstraint", div)
	dsize.MinSize = Vector2.new(112,24)

	-- Image
	local image = Instance.new("ImageLabel", div)
	image.Size = UDim2.new(0,12,0,12)
	image.BackgroundTransparency = 1
	image.Position = UDim2.new(1,7,.5,0)
	image.AnchorPoint = Vector2.new(1,.5)
	image.Image = "rbxassetid://10709790948"
	image.ImageColor3 = secondary_color

	-- Controller
	local controller = {
		Div = div,
	}

	function controller:Change(text)
		div.Text = text
		div.TextColor3 = Color3.fromHex("FFFFFF")

		animate(div, .3, {TextColor3 = secondary_color})
	end

	return controller
end

local function buildOptions(parent, options, remSize, callback)

	local size = 24*3.5
	if remSize < size then
		size = remSize
	end

	-- Div
	local div = Instance.new("Frame", parent)
	div.Size = UDim2.new(0,112,0,0)
	div.BackgroundTransparency = 1

	local dsize = Instance.new("UISizeConstraint", div)
	dsize.MaxSize = Vector2.new(112,0)

	-- List
	local list = Instance.new("ScrollingFrame", div)
	list.Size = UDim2.new(1,0,0,size)
	list.BackgroundTransparency = 1
	list.CanvasSize = UDim2.new(1,0,0,0)
	list.ScrollBarThickness = 0
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y

	local llist = Instance.new("UIListLayout", list)

	-- Options
	for _, text in options do
		local option = Instance.new("TextButton", list)
		option.Size = UDim2.new(0,112,0,24)
		option.BackgroundColor3 = primary_color2
		option.BorderSizePixel = 0
		option.TextColor3 = quaternary_color
		option.TextScaled = true
		option.Text = text
		option.AutoButtonColor = false
        option.ZIndex = 2
		option.Font = secondary_font
		option.TextSize = 12

		local opadding = Instance.new("UIPadding", option)
		opadding.PaddingTop = UDim.new(0,5)
		opadding.PaddingBottom = UDim.new(0,5)
		opadding.PaddingLeft = UDim.new(0,5)
		opadding.PaddingRight = UDim.new(0,5)

		local ocorner = Instance.new("UICorner", option)
		ocorner.CornerRadius = UDim.new(0,6)

		option.Activated:Connect(function()
			callback(text)
		end)

		option.MouseEnter:Connect(function()
			animate(option, .15, {
				TextColor3 = secondary_color,
			})
		end)

		option.MouseLeave:Connect(function()
			animate(option, .15, {
				TextColor3 = quaternary_color,
			})
		end)
	end

	return div
end

local function buildDebug(parent)

	-- Div
	local div = Instance.new("TextLabel", parent)
	div.Size = UDim2.new(24,0,0,24)
	div.TextXAlignment = Enum.TextXAlignment.Right
	div.BackgroundTransparency = 1
	div.TextColor3 = tertiary_color
	div.Font = secondary_font
	div.Text = "Space"
	div.TextSize = 13

	local dpadding = Instance.new("UIPadding", div)
	dpadding.PaddingRight = UDim.new(0,8)

	-- Controller
	local controller = {
		Div = div,
	}

	function controller:Change(text)
		div.Text = text
		div.TextColor3 = Color3.fromHex("FFFFFF")

		animate(div, .3, {TextColor3 = tertiary_color})
	end

	return controller
end

local function newSection(parent, info)

	-- Element
	local element = {}
	local elementDiv, dpadding = buildElementDiv(parent)
	local component = buildSection(elementDiv)

	component.TextLabel.Text = info.Title or "Section"

	dpadding.PaddingTop = UDim.new(0,0)
	dpadding.PaddingBottom = UDim.new(0,0)

	return element
end

local function newParagraph(parent, info)

	-- Element
	local element = {}
	local elementDiv = buildElementDiv(parent)
	local paragDiv, title, desc = buildParagraph(elementDiv, 0)

	if not info.Title then
		title:Destroy()
	else
		title.Text = info.Title
	end
	desc.Text = info.Description or "A paragraph"

	return element
end

local function newToggle(parent, info)

	-- Element
	local element = {}
	local elementDiv = buildElementDiv(parent)
	local paragDiv, title, desc = buildParagraph(elementDiv, 24+8)
	local component = buildToggle(elementDiv)

	title.Text = info.Title or "Toggle"

	if not info.Description then
		desc:Destroy()
	else
		desc.Text = info.Description
	end

	component.Div.Position = UDim2.new(1,0,.5,0)
	component.Div.AnchorPoint = Vector2.new(1,.5)

	-- Locals
	local active = info.Default or false
	local callback = info.Callback

	-- Load
	if active then
		component:Toggle()
	else
		component:Untoggle()
	end

	if callback then task.spawn(callback, active) end

	-- Methods
	function element:SetValue(value: boolean)
		active = typeof(value) == "boolean" and value or not active

		if active then
			component:Toggle()
		else
			component:Untoggle()
		end

		if callback then task.spawn(callback, active) end
	end

	function element:GetValue()
		return active
	end

	-- Connections
	elementDiv.Activated:Connect(function()
		element:SetValue()
	end)

	-- Export
	return element
end

local function newInput(parent, info)

	-- Element
	local element = {}
	local elementDiv = buildElementDiv(parent)
	local paragDiv, title, desc = buildParagraph(elementDiv, 96+8)
	local component = buildInput(elementDiv)

	title.Text = info.Title or "Input"

	if not info.Description then
		desc:Destroy()
	else
		desc.Text = info.Description
	end

	component.Div.Position = UDim2.new(1,0,.5,0)
	component.Div.AnchorPoint = Vector2.new(1,.5)

	-- Locals
	local text = info.Default or ""
	local callback = info.Callback

	-- Load
	component:Change(text)

	if callback then task.spawn(callback, text) end

	-- Methods
	function element:SetValue(value)
		text = value or ""

		component:Change(text)

		if callback then task.spawn(callback, text) end
	end

	function element:GetValue()
		return text
	end

	-- Connections
	elementDiv.Activated:Connect(function()
		component.Div:CaptureFocus()
	end)

	component.Div.FocusLost:Connect(function()
		local newText = component.Div.Text
		if newText == text then return end

		element:SetValue(newText)
	end)

	-- Export
	return element
end

local function newButton(parent, info)

	-- Element
	local element = {}
	local elementDiv = buildElementDiv(parent)
	local paragDiv, title, desc = buildParagraph(elementDiv, 27+8)
	local component = buildButton(elementDiv)

	title.Text = info.Title or "Button"

	if not info.Description then
		desc:Destroy()
	else
		desc.Text = info.Description
	end

	component.Div.Position = UDim2.new(1,0,.5,0)
	component.Div.AnchorPoint = Vector2.new(1,.5)

	-- Locals
	local callback = info.Callback

	-- Methods
	function element:Active()
		component:Press()

		if callback then task.spawn(callback) end
	end

	-- Connections
	elementDiv.Activated:Connect(function()
		element:Active()
	end)

	-- Export
	return element
end

local function newSlider(parent, info)

	-- Element
	local element = {}
	local elementDiv = buildElementDiv(parent)
	local paragDiv, title, desc = buildParagraph(elementDiv, 112+24+8)
	local component = buildSlider(elementDiv)

	title.Text = info.Title or "Slider"

	if not info.Description then
		desc:Destroy()
	else
		desc.Text = info.Description
	end

	component.Div.Position = UDim2.new(1,0,.5,0)
	component.Div.AnchorPoint = Vector2.new(1,.5)

	-- Locals
	local callback = info.Callback
	local value, minValue, maxValue = info.Default or .5, info.Min or 0, info.Max or 1
	local places = info.Places or 0

	-- Load
	component:Slide((value - minValue) / (maxValue - minValue), value)

	if callback then task.spawn(callback, value) end

	-- Methods
	function element:SetValue(newVal)
		value = math.clamp(newVal, minValue, maxValue)

		component:Slide((value - minValue) / (maxValue - minValue), value)

		if callback then task.spawn(callback, value) end
	end

	function element:GetValue()
		return value
	end

	component.Area.MouseButton1Down:Connect(function()

		while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or isTouchDown() do
			local mouse = game:GetService("Players").LocalPlayer:GetMouse()
			local pos = getTouchPos() or Vector3.new(mouse.X, mouse.Y, 0)
			local min, max = component.Extern.AbsolutePosition, component.Extern.AbsolutePosition + component.Extern.AbsoluteSize
			local scale = (pos.X - min.X) / (max.X - min.X)

			local newValue = minValue + (maxValue - minValue) * scale
			newValue = math.clamp(newValue, minValue, maxValue)
			newValue = math.round(newValue*10^places)/10^places
			local newScale = (newValue - minValue) / (maxValue - minValue)

			if newValue ~= value then
				element:SetValue(newValue)
			end

			RunService.RenderStepped:Wait()
		end

	end)

	-- Export
	return element
end

local function newKeybind(parent, info)

	-- Element
	local element = {}
	local elementDiv = buildElementDiv(parent)
	local paragDiv, title, desc = buildParagraph(elementDiv, 38+8)
	local component = buildKeybind(elementDiv)

	title.Text = info.Title or "Keybind"

	if not info.Description then
		desc:Destroy()
	else
		desc.Text = info.Description
	end

	component.Div.Position = UDim2.new(1,0,.5,0)
	component.Div.AnchorPoint = Vector2.new(1,.5)

	-- Locals
	local callback = info.Callback
	local inputCallback = info.InputCallback
	local key = info.Default or Enum.KeyCode.E
	local isWaiting = false

	-- Load
	component:Change(key.Name)

	if callback then task.spawn(callback, key) end

	-- Methods
	function element:SetKey(newKey)
		key = newKey

		component:Change(key.Name)

		if callback then task.spawn(callback, key) end
	end

	function element:GetKey()
		return key
	end

	-- Connections
	elementDiv.Activated:Connect(function()
		if isWaiting then return end

		component:Change("...")
		isWaiting = true

		local keybind
		repeat
			keybind = UserInputService.InputBegan:Wait()
		until keybind.UserInputType == Enum.UserInputType.Keyboard

		element:SetKey(keybind.KeyCode)
		isWaiting = false
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if isWaiting then return end		
		if gameProcessed then return end

		if input.KeyCode == key then
			if inputCallback then task.spawn(inputCallback, true) end
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if isWaiting then return end		
		if gameProcessed then return end

		if input.KeyCode == key then
			if inputCallback then task.spawn(inputCallback, false) end
		end
	end)

	-- Export
	return element
end

local function newDropdown(parent, info)

	-- Element
	local element = {}
	local elementDiv = buildElementDiv(parent)
	local paragDiv, title, desc = buildParagraph(elementDiv, 38+8)
	local component = buildDropdown(elementDiv)

	title.Text = info.Title or "Dropdown"

	if not info.Description then
		desc:Destroy()
	else
		desc.Text = info.Description
	end

	component.Div.Position = UDim2.new(1,0,.5,0)
	component.Div.AnchorPoint = Vector2.new(1,.5)

	-- Locals
	local callback = info.Callback
	local options = info.Options or {"Dropdown"}
	local currentOption = info.Default or options[1]
	local isWorking = false
	local optionsDiv = nil

	-- Load
	component:Change(currentOption)

	if callback then task.spawn(callback, currentOption) end

	-- Methods
	function element:SetValue(newOption)
		currentOption = newOption

		component:Change(currentOption)

		if callback then task.spawn(callback, currentOption) end
	end

	function element:GetValue()
		return currentOption
	end

	function element:SetOptions(newOptions)
		options = newOptions or {"Dropdown"}
	end

	function element:GetOptions()
		return options
	end

	-- Connections
	elementDiv.Activated:Connect(function()
		if isWorking then
			optionsDiv:Destroy()
			optionsDiv = nil
			isWorking = false
			return
		end

		local start = component.Div.AbsolutePosition.Y + component.Div.AbsoluteSize.Y
		local final = parent.AbsolutePosition.Y + parent.AbsoluteSize.Y
		local size = final - start

		isWorking = true

		optionsDiv = buildOptions(component.Div, options, size, function(option)
			element:SetValue(option)
			optionsDiv:Destroy()
			optionsDiv = nil
			isWorking = false
		end)
		optionsDiv.Position = UDim2.new(0,-5,1,5)
	end)

	-- Export
	return element
end

local function newDebug(parent, info)

	-- Element
	local element = {}
	local elementDiv = buildElementDiv(parent)
	local paragDiv, title, desc = buildParagraph(elementDiv, 38+8)
	local component = buildDebug(elementDiv)

	title.Text = info.Title or "Debug"

	if not info.Description then
		desc:Destroy()
	else
		desc.Text = info.Description
	end

	component.Div.Position = UDim2.new(1,0,.5,0)
	component.Div.AnchorPoint = Vector2.new(1,.5)

	-- Load
	component:Change(info.Default or "Value")

	-- Methods
	function element:SetValue(newValue)
		component:Change(newValue)
	end

	-- Export
	return element
end

--// Tab.lua //--
local Tab = {}
Tab.__index = Tab

--// Methods
function Tab:NewSection(info)
    return newSection(self.__tabFrame, info)
end

function Tab:NewParagraph(info)
    return newParagraph(self.__tabFrame, info)
end

function Tab:NewToggle(info)
    return newToggle(self.__tabFrame, info)
end

function Tab:NewInput(info)
    return newInput(self.__tabFrame, info)
end

function Tab:NewButton(info)
    return newButton(self.__tabFrame, info)
end

function Tab:NewSlider(info)
    return newSlider(self.__tabFrame, info)
end

function Tab:NewKeybind(info)
    return newKeybind(self.__tabFrame, info)
end

function Tab:NewDropdown(info)
    return newDropdown(self.__tabFrame, info)
end

function Tab:NewDebug(info)
    return newDebug(self.__tabFrame, info)
end

--// Constructor
function Tab.__new(window, tabs, handler, imageId)
    local tab = setmetatable({
        __tabButton = nil,
        __tabFrame = nil,
    }, Tab)

    tab.__tabButton = buildTabButton(tabs, imageId)
    tab.__tabFrame = buildTabFrame(handler)

    tab.__tabButton.Activated:Connect(function()
        window:SetActiveTab(tab)
    end)

    return tab
end

local UserInputService = game:GetService("UserInputService")
--// Library.lua //--
local Library = {
	__connections = {}
}

--// Utils
local function insertChar(str, posicao, letra)
    if posicao < 1 then posicao = 1 end
    if posicao > #str + 1 then posicao = #str + 1 end
    
    return str:sub(1, posicao-1) .. letra .. str:sub(posicao)
end

local function animXXX(keyinput)
	local placeholder = "____________________"
	for i=1, 20 do
		placeholder = placeholder:sub(1,i-1).."X"..placeholder:sub(i+1)
		local p1 = placeholder
		local p2 = insertChar(p1, 5+1, "-")
		local p3 = insertChar(p2, 10+2, "-")
		local p4 = insertChar(p3, 15+3, "-")
		keyinput.PlaceholderText = p4
		task.wait(.08)
	end
end

local function animPLACEHERE(keyinput)
	local objective = "<-- YOUR KEY HERE"
	local current = ""

	for i=1, #objective do
		current ..= objective:sub(i,i)
		keyinput.PlaceholderText = current
		task.wait(.08)
	end

	task.wait(1)

	for i=1, 4 do
		current = current:sub(2)
		keyinput.PlaceholderText = current
		task.wait(.08)
	end
end

local function spawnAnimLoop(keyinput)
	task.spawn(function()
		local mode = 1

		while true do
			mode = (mode == 1) and 2 or 1

			if mode == 2 then
				animXXX(keyinput)
				task.wait(2)

				keyinput.PlaceholderText = keyinput.PlaceholderText:gsub("-", " ")
				keyinput.PlaceholderText = keyinput.PlaceholderText:gsub("[^%s]", "#")
				task.wait(.25)
			else
				animPLACEHERE(keyinput)
				task.wait(2)

				keyinput.PlaceholderText = keyinput.PlaceholderText:gsub("[^%s]", "#")
				task.wait(.25)
			end
		end
	end)
end

--// Methods
function Library:CreateAccessGui(checkCallback, loadedKey)
	-- Background
	local background = Instance.new("Frame", screenGui)
	background.Size = UDim2.new(1,0,1,100)
	background.BackgroundColor3 = Color3.new(0,0,0) --primary_color
	background.BackgroundTransparency = 1
	background.Position = UDim2.new(0,0,0,-100)

	animate(background, 1, {BackgroundTransparency = .4}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

    -- Frame principal
    local frame = Instance.new("Frame", screenGui)
    frame.BackgroundColor3 = primary_color
    frame.Size = UDim2.new(0, 0, 0, 320)
    frame.AnchorPoint = Vector2.new(.5, .5)
    frame.Position = UDim2.new(.5, 0, .5, 0)
    frame.BorderSizePixel = 0
	frame.Active = true

	animate(frame, 1, {Size = UDim2.new(0, 280, 0, 320)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	task.wait(1)

	local frontFrame = Instance.new("Frame", screenGui)
    frontFrame.BackgroundColor3 = primary_color
    frontFrame.Size = UDim2.new(0, 280, 0, 320)
    frontFrame.AnchorPoint = Vector2.new(.5, .5)
    frontFrame.Position = UDim2.new(.5, 0, .5, 0)
    frontFrame.BorderSizePixel = 0
	frontFrame.BackgroundTransparency = 0
	frontFrame.ZIndex = 10

	animate(frontFrame, 1, {BackgroundTransparency = 1}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

    -- Brilho
	local image = Instance.new("ImageLabel")
	image.Parent = frame
	image.BackgroundTransparency = 1
	image.Image = "rbxassetid://121962713237685"
	image.ImageColor3 = icon_color
	image.ImageTransparency = .92
	image.Size = UDim2.new(0,250,0,250)
	image.Position = UDim2.new(.5,0,.28,0)
	image.AnchorPoint = Vector2.new(.5,.5)

    -- ├ìcone (logo)
    local icon = Instance.new("ImageLabel", frame)
    icon.Image = "rbxassetid://110631897823699"
    icon.ImageColor3 = icon_color
    icon.Size = UDim2.new(0, 56, 0, 56)
    icon.AnchorPoint = Vector2.new(.5, 0)
    icon.Position = UDim2.new(.5, 0, 0, 36)
    icon.BackgroundColor3 = primary_color2
    icon.BackgroundTransparency = 1
    icon.BorderSizePixel = 0

    local icorner = Instance.new("UICorner", icon)
    icorner.CornerRadius = UDim.new(0, 12)

    local istroke = Instance.new("UIStroke", icon)
    istroke.Color = secondary_color
    istroke.Thickness = 1
    istroke.Transparency = 1

    -- Nome do hub
    local title = Instance.new("TextLabel", frame)
    title.Text = "SHARK HUB"
    title.Font = primary_font
    title.TextColor3 = icon_color2
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -40, 0, 28)
    title.AnchorPoint = Vector2.new(.5, 0)
    title.Position = UDim2.new(.5, 0, 0, 106)
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Center

    -- Label do input
    local keylabel = Instance.new("TextLabel", frame)
    keylabel.Text = "LICENSE KEY"
    keylabel.Font = primary_font
    keylabel.TextColor3 = quaternary_color
    keylabel.TextTransparency = 0.5
    keylabel.BackgroundTransparency = 1
    keylabel.Size = UDim2.new(1, -40, 0, 16)
    keylabel.AnchorPoint = Vector2.new(.5, 0)
    keylabel.Position = UDim2.new(.5, 0, 0, 158)
    keylabel.TextSize = 10
    keylabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Input da key
    local keyinput = Instance.new("TextBox", frame)
    keyinput.Text = loadedKey or ""
    keyinput.Font = primary_font
    keyinput.PlaceholderText = "XXXXX-XXXXX-XXXXX-XXXXX"
    keyinput.TextTransparency = .5
    keyinput.ClearTextOnFocus = false
    keyinput.TextColor3 = tertiary_color
    keyinput.BackgroundColor3 = primary_color2
    keyinput.BorderSizePixel = 0
    keyinput.Size = UDim2.new(1, -40, 0, 36)
    keyinput.AnchorPoint = Vector2.new(.5, 0)
    keyinput.Position = UDim2.new(.5, 0, 0, 183)
    keyinput.TextSize = 12
    keyinput.TextXAlignment = Enum.TextXAlignment.Center

    local kcorner = Instance.new("UICorner", keyinput)
    kcorner.CornerRadius = UDim.new(0, secondary_roundness/2)

    -- Bot├úo principal: Verify
    local verifybtn = Instance.new("TextButton", frame)
    verifybtn.Text = "Verify Key"
    verifybtn.Font = primary_font
    verifybtn.TextColor3 = Color3.new(1,1,1)
    verifybtn.BackgroundColor3 = icon_color
    verifybtn.BorderSizePixel = 0
    verifybtn.Size = UDim2.new(1, -40, 0, 38)
    verifybtn.AnchorPoint = Vector2.new(.5, 0)
    verifybtn.Position = UDim2.new(.5, 0, 0, 230)
    verifybtn.TextSize = 14

    local vcorner = Instance.new("UICorner", verifybtn)
    vcorner.CornerRadius = UDim.new(0, secondary_roundness/2)

    -- Bot├úo link: Get key
    local getlink = Instance.new("TextButton", frame)
    getlink.Text = "Don't have a key? Get here"
    getlink.Font = primary_font
    getlink.TextColor3 = quaternary_color
    getlink.TextTransparency = 0.4
    getlink.BackgroundTransparency = 1
    getlink.BorderSizePixel = 0
    getlink.Size = UDim2.new(1, -40, 0, 24)
    getlink.AnchorPoint = Vector2.new(.5, 0)
    getlink.Position = UDim2.new(.5, 0, 0, 275)
    getlink.TextSize = 12

    -- Conex├Áes
    keyinput:GetPropertyChangedSignal("Text"):Connect(function()
        if keyinput.Text ~= "" then
            keyinput.TextTransparency = 0
        else
            keyinput.TextTransparency = .5
        end

		keyinput.Text = keyinput.Text:upper()
    end)

    verifybtn.MouseButton1Click:Connect(function()
		verifybtn.Interactable = false
		verifybtn.Text = "Verifying"
		verifybtn.Transparency = .5

        checkCallback(keyinput.Text, function(success, err)

			if success then
				verifybtn.Text = "Success"
				animate(frontFrame, 1, {BackgroundTransparency = 0}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
				task.wait(1)

				for _, child in frame:GetChildren() do
					child:Destroy()
				end

				frontFrame:Destroy()

				animate(frame, 1, {Size = UDim2.new(0, width, 0, height)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
				animate(background, 1, {BackgroundTransparency = 1}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
				task.wait(1)
				frame:Destroy()
				background:Destroy()
			else
				verifybtn.Interactable = true
				verifybtn.Transparency = 0
				verifybtn.Text = "Verify Key"
				keyinput.Text = "Error: "..err
			end

		end)
    end)

    getlink.MouseButton1Click:Connect(function()
        getlink.Text = "Copied to your clipboard"
    end)

	getlink.MouseEnter:Connect(function()
		getlink.TextColor3 = icon_color2
	end)

	getlink.MouseLeave:Connect(function()
		getlink.TextColor3 = quaternary_color
	end)

	-- Anim
	task.wait(.3)

	spawnAnimLoop(keyinput)
end

function Library:Initialize()
    if initializated then error ("!!!") end
    initializated = true

	-- Initialize interface
	local parent = screenGui
	local window = Instance.new("Frame", parent)
	window.Size = UDim2.new(0,width,0,height)
	window.Position = UDim2.new(0.5,0,0.5,0)
	window.AnchorPoint = Vector2.new(0.5,0.5)
	window.BackgroundColor3 = primary_color

	local backwindow = Instance.new("ImageLabel", window)
	backwindow.Size = UDim2.new(1.607,0,1.69,0)
	backwindow.BackgroundTransparency = 1
	backwindow.ImageTransparency = .3
	backwindow.ImageColor3 = secondary_color
	backwindow.ZIndex = 0
	backwindow.Image = "rbxassetid://80050558126869"
	backwindow.Position = UDim2.new(.5,0,.5,0)
	backwindow.AnchorPoint = Vector2.new(.5,.5)

	local wpadding = Instance.new("UIPadding", window)
	wpadding.PaddingLeft = UDim.new(0,spacing)
	wpadding.PaddingRight = UDim.new(0,spacing)
	wpadding.PaddingTop = UDim.new(0,spacing)
	wpadding.PaddingBottom = UDim.new(0,spacing)

	local header, hideButton = buildHeaderDiv(window)
	local content = buildContentDiv(window)
	local tabs = buildTabsDiv(content)
	local handler = buildHandlerDiv(content)

	-- Drag
	local dragFrame = Instance.new("Frame", window)
	dragFrame.Size = UDim2.new(1,spacing*2,0,header_height+spacing*2)
	dragFrame.Position = UDim2.new(0,-spacing,0,-spacing)
	dragFrame.BackgroundTransparency = 1

	local dragging, dragStart, startPos = false, nil, nil

	dragFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging  = true
			dragStart = input.Position
			startPos  = window.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			window.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	-- Minimize
	hideButton.Activated:Connect(function()
		window.Visible = false
	end)

	-- Library
    local Window = {__tabs={}, __toggleKey=Enum.KeyCode.RightShift}

	function Window:CreateTab(name, imageId)
        if Window.__tabs[name] then error("!!!") end

        Window.__tabs[name] = Tab.__new(Window, tabs, handler, imageId)

        return Window.__tabs[name]
	end

	function Window:GetTab(name)
		return Window.__tabs[name]
	end

	function Window:SetActiveTab(tab)

		for _, button in tabs:GetChildren() do
			if not button:IsA("TextButton") then continue end

			if button.BackgroundTransparency ~= 1 then
				animate(button, .3, {BackgroundTransparency = 1})
			end
		end

		handler["UIPageLayout"]:JumpTo(tab.__tabFrame)
		animate(tab.__tabButton, .3, {BackgroundTransparency = .9})
	end

	function Window:SetToggleKey(keycode)
		Window.__toggleKey = keycode
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end

		if input.KeyCode == Window.__toggleKey then
			window.Visible = not window.Visible
		end
	end)

	return Window
end

function Library:Connect(label, event, callback)
	if Library.__connections[label] then error("!!!") end

	Library.__connections[label] = event:Connect(callback)
end

function Library:Disconnect(label)
	if not Library.__connections[label] then error("!!!") end

	Library.__connections[label]:Disconnect()
	Library.__connections[label] = nil
end

function Library:IsConnected(label)
	return Library.__connections[label] ~= nil
end

function Library:ClearConnections(prefix)
	for index, value in Library.__connections do
		if prefix and string.sub(index, 1, #prefix) ~= prefix then continue end

		value:Disconnect()
		Library.__connections[index] = nil
	end
end

Library:CreateAccessGui(function(key, returnCallback)
	local success = math.random(1, 2) == 1 

	task.wait(2)

	returnCallback(success, "No key")

	if success then

		local window = Library:Initialize()

		local tab = window:CreateTab("Tab Name", "rbxassetid://1")

		tab:NewSection({ Title = "Testing" })

		tab:NewParagraph({
			Description = "Wow old dark valley"
		})

		tab:NewToggle({
			Callback = function(value)
				print(value)
			end,
			Default = true
		})

		tab:NewInput({
			Default = "Input",
			Callback = function(text)
				print(text)
			end,
		})

		tab:NewButton({
			Callback = function()
				print("Pressed")
			end,
		})

		tab:NewSlider({
			Default = 1.5,
			Min = 1,
			Max = 2,
			Places = 1,
			Callback = function(value)
				print(value)
			end,
		})

		tab:NewSection({})

		tab:NewParagraph({
			Description = "Shark Blue section is fingering you"
		})

		tab:NewKeybind({
			Default = Enum.KeyCode.E,
			Callback = function(value)
				print(value)
			end,
			InputCallback = function(value)
				print(value)
			end,
		})

		tab:NewDropdown({
			Default = "Giovanna",
			Options = {"I", "Love", "You", "Giovanna"},
			Callback = function(value)
				print(value)
			end,
		})

		tab:NewParagraph({
			Description = "Autoparry of SHARK HUB is the best of the world"
		})

		local tab2 = window:CreateTab("Tab Names", "rbxassetid://1")

		tab2:NewParagraph({
			Title = "TESTANDO",
			Description = "Bro IM Bro IM TESTINGGGGGGGGGG 2",
		})

		local tab3 = window:CreateTab("Tab Namess", "rbxassetid://1")

		tab3:NewParagraph({
			Title = "TESTANDO",
			Description = "Bro IM TESTINGGGGGGGGGG 3",
		})

		local tab4 = window:CreateTab("Tab Namesss", "rbxassetid://1")

		tab4:NewParagraph({
			Title = "TESTANDO",
			Description = "Bro IM TESTINGGGGGGGGGG 4",
		})

		tab4:NewDebug({
			Default = "None",
		})

		window:SetActiveTab(tab2)

	end
end)
