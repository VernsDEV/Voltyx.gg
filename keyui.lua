-- ======================================================
--   VOLTYX.GG | KEY GATE
--   Fetches key.lua from GitHub, validates input,
--   then loads the main autofarm script.
-- ======================================================

-- ── SERVICES ─────────────────────────────────────────
local Players      = game:GetService("Players")
local TweenSvc     = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local CoreGui      = game:GetService("CoreGui")
local HttpService  = game:GetService("HttpService")
local RunService   = game:GetService("RunService")

local player  = Players.LocalPlayer
local pGui    = player:WaitForChild("PlayerGui")

-- ── CONFIG — change these URLs to your own repo ──────
local KEY_URL  = "https://raw.githubusercontent.com/VernsDEV/Voltyx.gg/refs/heads/main/key.lua"
local MAIN_URL = "https://raw.githubusercontent.com/VernsDEV/Voltyx.gg/refs/heads/main/mainscripts.lua"
local DISCORD  = "https://discord.gg/M6EhJ3Rtu2"

-- ── COLOURS ──────────────────────────────────────────
local C = {
    bg      = Color3.fromRGB(12, 10, 18),
    panel   = Color3.fromRGB(18, 16, 26),
    card    = Color3.fromRGB(22, 20, 32),
    line    = Color3.fromRGB(40, 36, 54),
    purple  = Color3.fromRGB(150, 65, 255),
    purpleD = Color3.fromRGB(105, 38, 210),
    cyan    = Color3.fromRGB(65, 225, 245),
    red     = Color3.fromRGB(225, 65, 65),
    green   = Color3.fromRGB(52, 210, 110),
    orange  = Color3.fromRGB(255, 165, 40),
    txt     = Color3.fromRGB(245, 245, 255),
    txtM    = Color3.fromRGB(160, 165, 190),
    txtD    = Color3.fromRGB(80, 85, 110),
}

-- ── HELPERS ──────────────────────────────────────────
local function corner(p, r)
    Instance.new("UICorner", p).CornerRadius = UDim.new(0, r or 8)
end

local function stroke(p, col, th)
    local s = Instance.new("UIStroke", p)
    s.Color = col or C.line; s.Thickness = th or 1
    return s
end

local function grad(p, c0, c1)
    local g = Instance.new("UIGradient", p)
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   c0),
        ColorSequenceKeypoint.new(1,   c1),
    }
end

local function tween(obj, props, t, style)
    TweenSvc:Create(obj, TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad), props):Play()
end

-- ── PARSE DATE (YYYY-MM-DD) ──────────────────────────
local function parseDate(str)
    if str == "NEVER" then return nil end  -- nil = never expires
    local y, m, d = str:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
    if not y then return false end
    return {year = tonumber(y), month = tonumber(m), day = tonumber(d)}
end

local function isExpired(dateTable)
    if not dateTable then return false end          -- NEVER
    local now = os.date("*t")
    if now.year  ~= dateTable.year  then return now.year  > dateTable.year  end
    if now.month ~= dateTable.month then return now.month > dateTable.month end
    return now.day > dateTable.day
end

-- ── BUILD KEY GATE UI ─────────────────────────────────
local keyGui = Instance.new("ScreenGui")
keyGui.Name           = "VoltyxKeyGate"
keyGui.ResetOnSpawn   = false
keyGui.DisplayOrder   = 9999
keyGui.IgnoreGuiInset = true
pcall(function() keyGui.Parent = CoreGui end)
if keyGui.Parent ~= CoreGui then keyGui.Parent = pGui end

-- Dim backdrop
local backdrop = Instance.new("Frame", keyGui)
backdrop.Size             = UDim2.new(1, 0, 1, 0)
backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backdrop.BackgroundTransparency = 0.45
backdrop.BorderSizePixel  = 0
backdrop.ZIndex           = 1

-- Main card
local card = Instance.new("Frame", keyGui)
card.Size             = UDim2.new(0, 460, 0, 330)
card.Position         = UDim2.new(0.5, -230, 0.5, -165)
card.BackgroundColor3 = C.bg
card.BorderSizePixel  = 0
card.ZIndex           = 2
corner(card, 14)
local cardStroke = stroke(card, C.purple, 2)

-- Gradient accent bar (top)
local accentBar = Instance.new("Frame", card)
accentBar.Size            = UDim2.new(1, 0, 0, 3)
accentBar.BackgroundColor3 = C.purple
accentBar.BorderSizePixel = 0
accentBar.ZIndex          = 3
corner(accentBar, 14)
grad(accentBar, C.purple, C.cyan)

-- Logo / icon area
local iconBg = Instance.new("Frame", card)
iconBg.Size             = UDim2.new(0, 52, 0, 52)
iconBg.Position         = UDim2.new(0.5, -26, 0, 20)
iconBg.BackgroundColor3 = C.panel
iconBg.BorderSizePixel  = 0
iconBg.ZIndex           = 3
corner(iconBg, 14)
stroke(iconBg, C.purple, 1.5)

local iconL = Instance.new("TextLabel", iconBg)
iconL.Size              = UDim2.new(1, 0, 1, 0)
iconL.BackgroundTransparency = 1
iconL.Text              = "⚡"
iconL.TextSize          = 26
iconL.Font              = Enum.Font.GothamBold
iconL.TextXAlignment    = Enum.TextXAlignment.Center
iconL.ZIndex            = 4

-- RGB stroke loop on card
task.spawn(function()
    while keyGui.Parent do
        local hue = tick() % 5 / 5
        cardStroke.Color = Color3.fromHSV(hue, 0.7, 1)
        task.wait(0.03)
    end
end)

-- Title
local titleL = Instance.new("TextLabel", card)
titleL.Size              = UDim2.new(1, 0, 0, 26)
titleL.Position          = UDim2.new(0, 0, 0, 82)
titleL.BackgroundTransparency = 1
titleL.Text              = "VOLTYX.GG  PREMIUM"
titleL.TextColor3        = C.txt
titleL.Font              = Enum.Font.GothamBold
titleL.TextSize          = 18
titleL.TextXAlignment    = Enum.TextXAlignment.Center
titleL.ZIndex            = 3

-- Subtitle
local subL = Instance.new("TextLabel", card)
subL.Size              = UDim2.new(1, 0, 0, 18)
subL.Position          = UDim2.new(0, 0, 0, 110)
subL.BackgroundTransparency = 1
subL.Text              = "Enter your license key to continue"
subL.TextColor3        = C.txtD
subL.Font              = Enum.Font.GothamMedium
subL.TextSize          = 12
subL.TextXAlignment    = Enum.TextXAlignment.Center
subL.ZIndex            = 3

-- Divider
local div = Instance.new("Frame", card)
div.Size             = UDim2.new(1, -40, 0, 1)
div.Position         = UDim2.new(0, 20, 0, 136)
div.BackgroundColor3 = C.line
div.BorderSizePixel  = 0
div.ZIndex           = 3

-- TextBox label
local inputLabel = Instance.new("TextLabel", card)
inputLabel.Size              = UDim2.new(1, -40, 0, 16)
inputLabel.Position          = UDim2.new(0, 20, 0, 148)
inputLabel.BackgroundTransparency = 1
inputLabel.Text              = "LICENSE KEY"
inputLabel.TextColor3        = C.purple
inputLabel.Font              = Enum.Font.GothamBold
inputLabel.TextSize          = 11
inputLabel.TextXAlignment    = Enum.TextXAlignment.Left
inputLabel.ZIndex            = 3

-- TextBox background
local inputBg = Instance.new("Frame", card)
inputBg.Size             = UDim2.new(1, -40, 0, 44)
inputBg.Position         = UDim2.new(0, 20, 0, 166)
inputBg.BackgroundColor3 = C.panel
inputBg.BorderSizePixel  = 0
inputBg.ZIndex           = 3
corner(inputBg, 8)
local inputStroke = stroke(inputBg, C.line, 1)

local textBox = Instance.new("TextBox", inputBg)
textBox.Size              = UDim2.new(1, -20, 1, 0)
textBox.Position          = UDim2.new(0, 10, 0, 0)
textBox.BackgroundTransparency = 1
textBox.Text              = ""
textBox.PlaceholderText   = "VERNS-XXXX-XXXX-XXXX"
textBox.PlaceholderColor3 = C.txtD
textBox.TextColor3        = C.txt
textBox.Font              = Enum.Font.GothamBold
textBox.TextSize          = 14
textBox.TextXAlignment    = Enum.TextXAlignment.Center
textBox.ClearTextOnFocus  = false
textBox.ZIndex            = 4

textBox.Focused:Connect(function()
    tween(inputStroke, {Color = C.purple}, 0.15)
    tween(inputBg, {BackgroundColor3 = C.card}, 0.15)
end)
textBox.FocusLost:Connect(function()
    tween(inputStroke, {Color = C.line}, 0.15)
    tween(inputBg, {BackgroundColor3 = C.panel}, 0.15)
end)

-- Status label (feedback)
local statusL = Instance.new("TextLabel", card)
statusL.Size              = UDim2.new(1, -40, 0, 18)
statusL.Position          = UDim2.new(0, 20, 0, 216)
statusL.BackgroundTransparency = 1
statusL.Text              = ""
statusL.TextColor3        = C.txtD
statusL.Font              = Enum.Font.GothamMedium
statusL.TextSize          = 12
statusL.TextXAlignment    = Enum.TextXAlignment.Center
statusL.ZIndex            = 3

-- Confirm button
local confirmBg = Instance.new("Frame", card)
confirmBg.Size             = UDim2.new(1, -40, 0, 42)
confirmBg.Position         = UDim2.new(0, 20, 0, 242)
confirmBg.BackgroundColor3 = C.purpleD
confirmBg.BorderSizePixel  = 0
confirmBg.ZIndex           = 3
corner(confirmBg, 10)

local shineFx = Instance.new("Frame", confirmBg)
shineFx.Size             = UDim2.new(1, 0, 0.5, 0)
shineFx.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
shineFx.BackgroundTransparency = 0.92
shineFx.BorderSizePixel  = 0
shineFx.ZIndex           = 4
corner(shineFx, 10)

local confirmBtn = Instance.new("TextButton", confirmBg)
confirmBtn.Size              = UDim2.new(1, 0, 1, 0)
confirmBtn.BackgroundTransparency = 1
confirmBtn.Text              = "✓  ACTIVATE KEY"
confirmBtn.TextColor3        = C.txt
confirmBtn.Font              = Enum.Font.GothamBold
confirmBtn.TextSize          = 14
confirmBtn.ZIndex            = 5

confirmBtn.MouseEnter:Connect(function()
    tween(confirmBg, {BackgroundColor3 = C.purple}, 0.12)
end)
confirmBtn.MouseLeave:Connect(function()
    tween(confirmBg, {BackgroundColor3 = C.purpleD}, 0.12)
end)

-- Discord footer
local discordL = Instance.new("TextLabel", card)
discordL.Size              = UDim2.new(1, 0, 0, 18)
discordL.Position          = UDim2.new(0, 0, 0, 302)
discordL.BackgroundTransparency = 1
discordL.Text              = "Get a key →  discord.gg/M6EhJ3Rtu2"
discordL.TextColor3        = C.txtD
discordL.Font              = Enum.Font.GothamMedium
discordL.TextSize          = 11
discordL.TextXAlignment    = Enum.TextXAlignment.Center
discordL.ZIndex            = 3

-- ── SHAKE ANIMATION ──────────────────────────────────
local function shake()
    local base = card.Position
    local offsets = {8, -8, 6, -6, 3, 0}
    for _, ox in ipairs(offsets) do
        card.Position = UDim2.new(base.X.Scale, base.X.Offset + ox, base.Y.Scale, base.Y.Offset)
        task.wait(0.04)
    end
    card.Position = base
end

-- ── DESTROY KEY GATE UI ───────────────────────────────
local function destroyGate()
    tween(backdrop, {BackgroundTransparency = 1}, 0.3)
    tween(card, {BackgroundTransparency = 1}, 0.3)
    task.delay(0.35, function()
        pcall(function() keyGui:Destroy() end)
    end)
end

-- ── WRONG KEY → KICK ─────────────────────────────────
local function kickWrongKey(reason)
    statusL.TextColor3 = C.red
    statusL.Text       = "❌ " .. (reason or "Invalid key — kicking...")
    tween(confirmBg, {BackgroundColor3 = C.red}, 0.1)
    task.spawn(shake)
    task.delay(1.5, function()
        pcall(function()
            Players.LocalPlayer:Kick(
                "\n\n❌  WRONG KEY\n\nJoin our Discord server to get a license key:\n" .. DISCORD .. "\n\n— VOLTYX.GG"
            )
        end)
    end)
end

-- ── VALIDATE KEY AGAINST key.lua ─────────────────────
local function validateAndLaunch(inputKey)
    inputKey = inputKey:match("^%s*(.-)%s*$"):upper()

    if inputKey == "" then
        statusL.TextColor3 = C.orange
        statusL.Text = "⚠️  Please enter your key first."
        task.spawn(shake)
        return
    end

    statusL.TextColor3 = C.txtD
    statusL.Text       = "🔍  Verifying key..."
    tween(confirmBg, {BackgroundColor3 = C.purpleD}, 0.1)
    confirmBtn.Text    = "Checking..."

    task.spawn(function()
        -- Fetch key.lua from GitHub
        local ok, keyData = pcall(function()
            return loadstring(game:HttpGet(KEY_URL, true))()
        end)

        if not ok or type(keyData) ~= "table" then
            statusL.TextColor3 = C.red
            statusL.Text       = "❌  Failed to reach key server. Try again."
            confirmBtn.Text    = "✓  ACTIVATE KEY"
            tween(confirmBg, {BackgroundColor3 = C.purpleD}, 0.1)
            return
        end

        -- Search for matching key
        local matched = nil
        for _, entry in ipairs(keyData) do
            if type(entry) == "table" and entry.key == inputKey then
                matched = entry
                break
            end
        end

        if not matched then
            confirmBtn.Text = "✓  ACTIVATE KEY"
            kickWrongKey("Key not found.")
            return
        end

        -- Check expiry
        local dateTable = parseDate(matched.expire or "NEVER")
        if dateTable == false then
            confirmBtn.Text = "✓  ACTIVATE KEY"
            kickWrongKey("Key has invalid expiry format.")
            return
        end

        if isExpired(dateTable) then
            confirmBtn.Text = "✓  ACTIVATE KEY"
            kickWrongKey("Key expired on " .. matched.expire .. ".")
            return
        end

        -- ✅ Key valid
        statusL.TextColor3 = C.green
        statusL.Text       = "✅  Key verified! Loading Voltyx..."
        tween(confirmBg, {BackgroundColor3 = C.green}, 0.15)
        confirmBtn.Text    = "✓  Launching..."

        task.delay(1.2, function()
            destroyGate()
            task.delay(0.4, function()
                -- Load the actual main script
                local loadOk, loadErr = pcall(function()
                    loadstring(game:HttpGet(MAIN_URL, true))()
                end)
                if not loadOk then
                    warn("[Voltyx KeyGate] Failed to load main script: " .. tostring(loadErr))
                end
            end)
        end)
    end)
end

-- ── WIRE UP BUTTON & ENTER KEY ────────────────────────
confirmBtn.MouseButton1Click:Connect(function()
    validateAndLaunch(textBox.Text)
end)

textBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        validateAndLaunch(textBox.Text)
    end
end)

-- Auto-focus textbox on load
task.delay(0.3, function()
    pcall(function() textBox:CaptureFocus() end)
end)

-- Animate card in on load
card.Position = UDim2.new(0.5, -230, 0.5, -195)
tween(card, {Position = UDim2.new(0.5, -230, 0.5, -165)}, 0.25, Enum.EasingStyle.Back)
