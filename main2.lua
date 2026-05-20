--real
--// Header.lua //--
local SharkHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/perdidoguru/sh/refs/heads/main/main.lua"))()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

local _savedKey = ""
if isfile and isfile("shkey") then
    local ok, content = pcall(readfile, "shkey")
    if ok and type(content) == "string" and #content > 0 then
        _savedKey = content:match("^%s*(.-)%s*$") -- trim whitespace
    end
end

SharkHub:CreateAccessGui(function(key, returnCallback)
    -- hashlib_slim.lua
    -- SHA-256 + HMAC-SHA256 apenas
    -- Drop-in: hashlib.sha256(msg) | hashlib.hmac(hashlib.sha256, key, data)
    -- Requer: bit32 (dispon├¡vel nativamente no Roblox/Luau e na maioria dos executores)

    local hashlib

    do
        local b = bit32

        local function u32(x)    return x % 0x100000000 end
        local function shr(x,n)  return b.rshift(x, n) end
        local function ror(x,n)  return b.rrotate(x, n) end
        local function band(a,c) return b.band(a, c) end
        local function bxor(a,c) return b.bxor(a, c) end
        local function bnot(a)   return b.bnot(a) end

        local K = {
            0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,
            0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
            0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,
            0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
            0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,
            0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
            0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,
            0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
            0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,
            0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
            0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,
            0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
            0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,
            0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
            0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,
            0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
        }

        local H0 = {
            0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,
            0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19,
        }

        local floor  = math.floor
        local char   = string.char
        local sub    = string.sub
        local rep    = string.rep
        local concat = table.concat
        local unpack = table.unpack

        local function bytes_to_u32(s, i)
            local a,bv,c,d = s:byte(i, i+3)
            return u32(a*0x1000000 + bv*0x10000 + c*0x100 + d)
        end

        local function u32_to_4bytes_be(x)
            return char(shr(x,24)%256, shr(x,16)%256, shr(x,8)%256, x%256)
        end

        local function sha256_block(H, block)
            local W = {}
            for i=1,16 do W[i] = bytes_to_u32(block, (i-1)*4+1) end
            for i=17,64 do
                local s0 = bxor(ror(W[i-15],7), bxor(ror(W[i-15],18), shr(W[i-15],3)))
                local s1 = bxor(ror(W[i-2],17), bxor(ror(W[i-2],19),  shr(W[i-2],10)))
                W[i] = u32(W[i-16] + s0 + W[i-7] + s1)
            end
            local a,bv,c,d,e,f,g,h = unpack(H)
            for i=1,64 do
                local S1  = bxor(ror(e,6),  bxor(ror(e,11),  ror(e,25)))
                local ch  = bxor(band(e,f), band(bnot(e),g))
                local t1  = u32(h + S1 + ch + K[i] + W[i])
                local S0  = bxor(ror(a,2),  bxor(ror(a,13),  ror(a,22)))
                local maj = bxor(band(a,bv), bxor(band(a,c), band(bv,c)))
                local t2  = u32(S0 + maj)
                h=g; g=f; f=e; e=u32(d+t1); d=c; c=bv; bv=a; a=u32(t1+t2)
            end
            H[1]=u32(H[1]+a);  H[2]=u32(H[2]+bv)
            H[3]=u32(H[3]+c);  H[4]=u32(H[4]+d)
            H[5]=u32(H[5]+e);  H[6]=u32(H[6]+f)
            H[7]=u32(H[7]+g);  H[8]=u32(H[8]+h)
        end

        local function sha256(msg)
            local H    = {unpack(H0)}
            local len  = #msg
            local blen = len * 8
            msg = msg .. "\x80"
            while #msg % 64 ~= 56 do msg = msg .. "\x00" end
            msg = msg .. "\x00\x00\x00\x00" .. u32_to_4bytes_be(blen)
            for i=1,#msg,64 do sha256_block(H, sub(msg, i, i+63)) end
            local t = {}
            for i=1,8 do t[i] = string.format("%08x", H[i]) end
            return concat(t)
        end

        local function hex_to_bin(hex)
            return hex:gsub("%x%x", function(h) return char(tonumber(h,16)) end)
        end

        local BS = 64

        local function hmac(hash_func, key, message)
            if #key > BS then key = hex_to_bin(hash_func(key)) end
            if #key < BS then key = key .. rep("\x00", BS - #key) end
            local ip, op = {}, {}
            for i=1,BS do
                local k = key:byte(i)
                ip[i] = char(bxor(k, 0x36))
                op[i] = char(bxor(k, 0x5C))
            end
            local ipad = concat(ip)
            local opad = concat(op)
            return hash_func(opad .. hex_to_bin(hash_func(ipad .. message)))
        end

        hashlib = {
            sha256 = sha256,
            hmac   = hmac,
        }
    end

    --// Main.lua //--
    local HttpService = game:GetService("HttpService")

    --// Globals
    local _session = {
        token       = nil,
        serverNonce = nil,
        hwid        = nil,
        expiry      = nil,
    }

    --// Config
    local BASE_URL    = "https://shserver-0wp1.onrender.com"
    local MASTER_SECRET = "IlOvEmYh __>_"
    local CHARSET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local LOG_ENABLED = true

    --// Initialize
    math.randomseed(os.clock() * 1e9 + os.time())

    --// Utils
    local function getRandomPart(errorCallback, msg)
        if LOG_ENABLED then print("[AUTH] Validate error") end
        local children = workspace:GetChildren()
        task.wait(math.random(.1,.38))
        errorCallback(msg)
        return children[math.random(1, #children)]
    end

    local function generateNonce(length)
        local result = {}
        for i = 1, length do
            local ci = math.random(1, #CHARSET)
            result[i] = CHARSET:sub(ci, ci)
        end
        return table.concat(result)
    end

    local function getTimestamp()
        return math.floor(os.time())
    end

    local function generateHWID()
        local ok, clientId = pcall(function()
            return game:GetService("RbxAnalyticsService"):GetClientId()
        end)
        if not ok or not clientId or clientId == "" then
            return nil
        end
        local executor = identifyexecutor and identifyexecutor() or "unknown"
        return hashlib.sha256(clientId.."|"..executor)
    end

    local function hmac(key, data)
        return hashlib.hmac(hashlib.sha256, key, data)
    end

    local function buildProof(scriptKey, serverNonce, hwid, clientNonce, timestamp)
        local data = serverNonce.."|"..hwid.."|"..clientNonce.."|"..tostring(timestamp)
        return hmac(scriptKey, data), data
    end

    local function verifySignature(response, masterSecret, errorCallback, callback)
        local data = tostring(response.visible).."|"
            ..response.color.."|"
            ..tostring(response.transparency).."|"
            ..tostring(response.cooldown)

        local expected = hmac(masterSecret, data)
        if expected == response.name then
            callback(nil, game) -- distra├º├úo pra filtragens e testes em fun├º├Áes na mem├│ria(callback deve verificar parametro game pra evitar manipula├º├úo)
        else
            task.wait(math.random(.1,2.9))
            callback({os.clock(), math="str"..tostring(os.time())}) -- embaralhamento
            return getRandomPart(errorCallback)
        end
    end

    local function httpPost(url, payload)
        local HttpService = game:GetService("HttpService")

        -- executor sempre exp├Áe uma dessas no ambiente global
        local fn = request
            or http_request
            or (syn and syn.request)
            or (fluxus and fluxus.request)

        if not fn then
            return nil, "no_http"
        end

        local ok, result = pcall(fn, {
            Url     = url,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = HttpService:JSONEncode(payload)
        })

        if not ok then
            return nil, "request_failed"
        end

        if result.StatusCode ~= 200 then
            return nil, "http_"..result.StatusCode
        end

        local ok2, parsed = pcall(HttpService.JSONDecode, HttpService, result.Body)
        if not ok2 then return nil, "json_parse_error" end
        return parsed, nil
    end

    local function check(key, errorCallback, callback)

        if LOG_ENABLED then print("[AUTH] Checking", key) end

        -- [1] Gera identidade do client
        local hwid        = generateHWID()
        local clientNonce = generateNonce(36)
        local timestamp   = getTimestamp()

        if type(hwid) ~= "string" then return getRandomPart(errorCallback, "Request failed") end

        -- [2] /get_challenge ÔÇö pede o server_nonce
        local challengeResp, err = httpPost(BASE_URL .. "/get_challenge", {
            hwid          = hwid,
            client_nonce  = clientNonce,
            timestamp     = timestamp,
        })

        if not challengeResp or err then
            return getRandomPart(errorCallback, "Request failed") -- falha silenciosa (mesmo retorno de erro e sucesso pra dificultar an├ílise)
        end

        local serverNonce = challengeResp.server_nonce

        if type(serverNonce) ~= "string" 
        or #serverNonce < 48 
        or serverNonce:match("[^%w]") then  -- s├│ aceita alfanum├®rico
            return getRandomPart(errorCallback, "Request failed")
        end

        -- [3] Monta o proof com a key do usu├írio como segredo HMAC
        local proof, _ = buildProof(key, serverNonce, hwid, clientNonce, timestamp)

        -- [4] /validate ÔÇö envia proof + key (apenas na primeira ativa├º├úo)
        local validateResp, err2 = httpPost(BASE_URL .. "/validate", {
            hwid          = hwid,
            server_nonce  = serverNonce,
            client_nonce  = clientNonce,
            timestamp     = timestamp,
            proof         = proof,
            key           = key, -- server ignora se o HWID j├í est├í bound
        })

        if not validateResp or err2 then
            return getRandomPart(errorCallback, "Request failed")
        end

        if validateResp.success == false or validateResp.error ~= nil then
            local err3 = validateResp.error

            if err3 == "invalid_key" then
                return errorCallback("Invalid key")
            elseif err3 == "key_expired" then
                return errorCallback("Key expired")
            elseif err3 == "hwid_mismatch" then
                return errorCallback("Hardware mismatch") 
            elseif err3 == "invalid_proof" then
                return errorCallback("Security verification failed")
            elseif err3 == "hwid_locked" or err3 == "too_many_attempts" then
                local tempo = validateResp.retryAfter and tostring(validateResp.retryAfter) or "few minutes"
                return errorCallback("Too many attempts. Retry in " .. tempo)
            else
                return errorCallback("Authentication error: " .. tostring(err3))
            end
        end

        local response = { -- entradas n├úo t├úo obvias
            visible = validateResp.success,
            color = validateResp.token,
            transparency = validateResp.expiry,
            cooldown = validateResp.new_server_nonce,
            name = validateResp.signature,
        }

        return verifySignature(response, MASTER_SECRET, errorCallback, function(sigErr, _gameRef)

            -- Quem chamar check() deve passar um callback que verifique
            -- se o segundo par├ómetro ├® `game` (refer├¬ncia real) como prova
            -- de que o fluxo n├úo foi manipulado na mem├│ria
            if sigErr ~= nil then return end
            if _gameRef ~= game then return end

            -- Valida├º├úo extra dos campos do response
            if not validateResp.success
            or type(validateResp.token) ~= "string"
            or type(validateResp.expiry) ~= "number"
            or type(validateResp.new_server_nonce) ~= "string" then
                return
            end

            -- Verifica expira├º├úo do token j├í na chegada
            if validateResp.expiry <= getTimestamp() then
                return
            end

            -- [6] Salva sess├úo para requests futuros (sem precisar reenviar key)
            _session.token       = validateResp.token
            _session.serverNonce = validateResp.new_server_nonce
            _session.hwid        = hwid
            _session.expiry      = validateResp.expiry

            -- [7] Chama o callback do caller com sucesso
            if LOG_ENABLED then print("[AUTH] Validate success") end
            callback(nil, game)
        end)
    end

    check(key,
        function(msg)
            returnCallback(false, msg or "Invalid key")
        end,
        function(_, gaem)
            if _ ~= nil or gaem ~= game then return end

            returnCallback(true)

            pcall(writefile, "shkey", key)

            --// Globals
            local window = SharkHub:Initialize()
            local player = Players.LocalPlayer
            local playerGui = player:WaitForChild("PlayerGui")

            --// Config
            local globalConfigs = {
                combat_aprange = 3,
                combat_appredict = 4,
                combat_detectFireball = true,
                combat_trackingMode = "Low Level",
                combat_parryMode = "Intern",
                combat_externalPort = 7832,
                auto_autoReady = false,
                auto_autoMove = false,
            }


--// Utils.lua //--
local uid = 0
local function newId()
    uid += 1
    return uid
end

local function getCCsLen()
    local len = 0

    for _, child in game:GetService("Lighting"):GetChildren() do
        if child:IsA("ColorCorrectionEffect") then len += 1 end
    end

    return len
end

local function detectBall(ball)
    local highlight = ball:FindFirstChildOfClass("Highlight")
    local name = highlight.OutlineColor:ToHex() == "ffee00" and "Fireball" or "Default"
    if name == "Default" and highlight.FillColor:ToHex() == "e10000" then name = "Fake" end

    --[[
    highlight:GetPropertyChangedSignal("OutlineColor"):Connect(function()
        --print("# outline_changed."..name, highlight.OutlineColor:ToHex(), highlight.FillColor:ToHex())
    end)

    highlight:GetPropertyChangedSignal("FillColor"):Connect(function()
        --print("# fill_changed."..name, highlight.OutlineColor:ToHex(), highlight.FillColor:ToHex())
    end)

    ball:GetPropertyChangedSignal("Transparency"):Connect(function()
        print("# transparency_changed."..name, ball.Transparency)
    end)

    print("# detected."..name, highlight.OutlineColor:ToHex(), highlight.FillColor:ToHex())
    ]]

    return name
end

local function raycastAgainstSphere(center, radius, rayOrigin, rayDirection, maxDistance)
    if rayDirection.Magnitude < 1e-6 then return nil end

    local oc = rayOrigin - center
    local a = rayDirection:Dot(rayDirection)
    local b = 2 * oc:Dot(rayDirection)
    local c = oc:Dot(oc) - radius * radius

    local discriminant = b * b - 4 * a * c
    if discriminant < 0 then return nil end

    local sqrtDisc = math.sqrt(discriminant)
    local t = (-b - sqrtDisc) / (2 * a)

    if t < 0 then t = (-b + sqrtDisc) / (2 * a) end
    if t < 0 or t > maxDistance then return nil end

    local hitPosition = rayOrigin + rayDirection * t
    return {
        Distance = t,
        Position = hitPosition,
        Normal = (hitPosition - center).Unit,
    }
end

local function getLabel(label)
    return label..newId()
end

--// Parry.lua //--
local SCALES = { 0.1, 0.2, 0.3, 0.5, 0.7, 0.8, 0.9 }
local activeScale: Vector2? = nil
local sortedPositions = nil

--// Utils
local function isBlockedByUI(position: Vector2): boolean
	local objects = playerGui:GetGuiObjectsAtPosition(position.X, position.Y)
	for _, obj in ipairs(objects) do
		if obj:IsA("TextButton") or obj:IsA("ImageButton") then
			return true
		elseif (obj:IsA("Frame") or obj:IsA("ScrollingFrame") or obj:IsA("TextBox")) and obj.Active then
			return true
		end
	end
	return false
end

local function buildSortedPositions()
    local entries = {}

    for _, sx in ipairs(SCALES) do
        for _, sy in ipairs(SCALES) do
            local dx = sx - 0.5
            local dy = sy - 0.5
            table.insert(entries, {
                scale = Vector2.new(sx, sy),
                dist  = math.sqrt(dx * dx + dy * dy),
            })
        end
    end

    table.sort(entries, function(a, b) return a.dist < b.dist end)

    local result = {}
    for _, entry in ipairs(entries) do
        table.insert(result, entry.scale)
    end
    return result
end

local function getNearestUnblockedPos(): Vector2?
    local viewport = workspace.CurrentCamera.ViewportSize

    for _, entry in ipairs(sortedPositions) do
        local pos = Vector2.new(entry.X * viewport.X, entry.Y * viewport.Y)
        if not isBlockedByUI(pos) then
            return entry  -- retorna a escala, n├úo o pixel
        end
    end

    return nil
end

local function mouseClick()
    if not sortedPositions then
        sortedPositions = buildSortedPositions()
    end

    local viewport = workspace.CurrentCamera.ViewportSize

    if activeScale ~= nil then
        local pos = Vector2.new(activeScale.X * viewport.X, activeScale.Y * viewport.Y)
        if isBlockedByUI(pos) then activeScale = nil end
    end

    if activeScale == nil then
        activeScale = getNearestUnblockedPos()
		if activeScale == nil then return end
    end

    local pos = Vector2.new(activeScale.X * viewport.X, activeScale.Y * viewport.Y)
    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
    task.wait()
    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
end

--// Internal
local useClick = false
local keyActive = false
local function parryInternal()
    if keyActive then useClick = false end

    if useClick then
        mouseClick()
    else
        keyActive = true

        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)

        keyActive = false
    end
    useClick = not useClick
end

--// External
local externalParryBusy = false
local function parryExternal()
    if externalParryBusy then return end
	if isBlockedByUI(UserInputService:GetMouseLocation()) then return end
    externalParryBusy = true

    task.spawn(function()
        local ok, err = pcall(function()
            local httpFunc = request or (syn and syn.request) or (http and http.request)
            if not httpFunc then
                warn("[External Parry] Executor n├úo suporta HTTP requests.")
                return
            end

            httpFunc({
                Url    = "http://127.0.0.1:" .. globalConfigs.combat_externalPort .. "/parry",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body   = '{"action":"click"}',
            })
        end)

        if not ok then
            warn("[External Parry] Falha ao enviar: " .. tostring(err))
        end

        externalParryBusy = false
    end)
end

--// General
local function parry()
    if globalConfigs.combat_parryMode == "Extern" then
        parryExternal()
    else
        parryInternal()
    end
end

--// Tracking.lua //--
local TrackingHandler, SemiBallHandler, FullBallHandler = { Active = false, _connections = {} }, nil, nil


function TrackingHandler:Connect(label, callback)
    self._connections[label] = callback
    if not self.Active then
        self:Activate()
    end
end

function TrackingHandler:Disconnect(label)
    self._connections[label] = nil
    if next(self._connections) == nil and self.Active then
        self:Deactivate()
    end
end

function TrackingHandler:Fire(ballId, ballName, position, velocity, delta)
    for _, callback in pairs(self._connections) do
        callback(ballId, ballName, position, velocity, delta)
    end
end

function TrackingHandler:Activate()
    if globalConfigs.combat_trackingMode == "Low Level" then
        SemiBallHandler:Activate()
    elseif globalConfigs.combat_trackingMode == "High Level" then
        FullBallHandler:Activate()
    end
    self.Active = true
end

function TrackingHandler:Deactivate()
    SemiBallHandler:Deactivate()
    FullBallHandler:Deactivate()
    self.Active = false
end

function TrackingHandler:Reload()
    if not self.Active then return end
    SemiBallHandler:Deactivate()
    FullBallHandler:Deactivate()
    self:Activate()
end

--// Semiball.lua //--
SemiBallHandler = { Balls = {}, Active = false }

do
    local function getLabel(label, ballId)
        if ballId then
            return "semiball"..ballId.."_"..label..newId()
        else
            return "semiball_"..label..newId()
        end
    end

    local function positionUpdated(data, position)
        if data.lastPosition then
            local timeDelta = tick() - data.lastUpdateTime
            if timeDelta > 0 then
                data.lastVelocity = (position - data.lastPosition) / timeDelta
            end
            data.previousPosition = data.lastPosition
        end

        data.lastPosition   = position
        data.lastUpdateTime = tick()
    end

    local function processUpdate(data, deltaTime)
        if not data.lastPosition then return end
        TrackingHandler:Fire(data.Id, data.Name, data.lastPosition, data.lastVelocity, deltaTime)
    end

    function SemiBallHandler.loadBall(data)
        data.lastPosition    = nil
        data.previousPosition = nil
        data.lastUpdateTime  = tick()
        data.lastVelocity    = Vector3.new()

        local highlight = data.Ball:FindFirstChildOfClass("Highlight")

        data.frame = Instance.new("Frame")
        data.frame.Size                   = UDim2.new(0, 25, 0, 25)
        data.frame.AnchorPoint            = Vector2.new(.5, .5)
        data.frame.BackgroundTransparency = .5
        data.frame.BackgroundColor3       = highlight.FillColor
        data.frame.Visible                = false
        data.frame.Parent                 = Instance.new("ScreenGui", CoreGui)

        Instance.new("UICorner", data.frame).CornerRadius = UDim.new(1, 0)

        local stroke = Instance.new("UIStroke", data.frame)
        stroke.Thickness = 4
        stroke.Color     = highlight.OutlineColor

        SharkHub:Connect(getLabel("pr", data.Id), RunService.PreRender, function()
            task.defer(function()
                if not data.Ball or not data.Ball.Parent then return end
                positionUpdated(data, data.Ball.CFrame.Position)
            end)
        end)

        SharkHub:Connect(getLabel("h", data.Id), RunService.Heartbeat, function(deltaTime)
            processUpdate(data, deltaTime)
        end)

        SharkHub:Connect(getLabel("d", data.Id), data.Ball.Destroying, function()
            task.spawn(SemiBallHandler.unloadBall, data)
        end)
    end

    function SemiBallHandler.unloadBall(data)
        SharkHub:ClearConnections("semiball"..data.Id)
        data.frame:Destroy()
    end

    function SemiBallHandler:Activate()
        if self.Active then return end

        for _, ball in workspace:GetChildren() do
            if not ball:IsA("MeshPart") or ball.Name ~= "Part" then continue end
            local data = { Ball = ball, Name = detectBall(ball), Id = newId() }
            SemiBallHandler.loadBall(data)
            table.insert(SemiBallHandler.Balls, data)
        end

        SharkHub:Connect(getLabel("ca"), workspace.ChildAdded, function(ball)
            if not ball:IsA("MeshPart") or ball.Name ~= "Part" then return end
            local data = { Ball = ball, Name = detectBall(ball), Id = newId() }
            SemiBallHandler.loadBall(data)
            table.insert(SemiBallHandler.Balls, data)
        end)

        self.Active = true
    end

    function SemiBallHandler:Deactivate()
        if not self.Active then return end

        for _, data in SemiBallHandler.Balls do
            SemiBallHandler.unloadBall(data)
        end

        table.clear(SemiBallHandler.Balls)
        SharkHub:ClearConnections("semiball")
        self.Active = false
    end
end

--// Fullball.lua //--
FullBallHandler = { Balls = {}, Active=false }
local preRenderConnections = nil

do
    --// Methods
    local function getLabel(label, ballId)
        if ballId then
            return "fullball"..ballId.."_"..label..newId()
        else
            return "fullball_"..label..newId()
        end
    end

    local function positionUpdated(data, position)
        if data.lastPosition then
            local timeDelta = tick() - data.lastUpdateTime
            if timeDelta > 0 then
                data.lastVelocity = (position - data.lastPosition) / timeDelta
            end
            data.previousPosition = data.lastPosition
        end

        data.lastPosition    = position
        data.lastUpdateTime  = tick()
    end

    local function processUpdate(data, deltaTime)
        if not data.lastPosition then return end

        --[[
        local direction = data.lastVelocity.Magnitude > 0 and data.lastVelocity.Unit or Vector3.zero
        local predictedPos = data.lastPosition + direction * globalConfigs.combat_appredict
        local pos2d, inScreen = workspace.CurrentCamera:WorldToScreenPoint(predictedPos)
        if inScreen then
            data.frame.Position = UDim2.new(0, pos2d.X, 0, pos2d.Y)
            data.frame.Visible = true
        else
            data.frame.Visible = false
        end
        ]]

        TrackingHandler:Fire(data.Id, data.Name, data.lastPosition, data.lastVelocity, deltaTime)
    end

    --// Hook
    local function hookPreRender()
        preRenderConnections = getconnections(RunService.PreRender)
        for _, conn in preRenderConnections do
            conn:Disable()
        end

        SharkHub:Connect(getLabel("pr"), RunService.PreRender, function(...)
            for _, conn in preRenderConnections do
                conn:Fire(...)
            end

            for _, data in FullBallHandler.Balls do
                if not data.Ball or not data.Ball.Parent then continue end
                positionUpdated(data, data.Ball.CFrame.Position)
                processUpdate(data, ...)
            end
        end)
    end

    local function unhookPreRender()
        SharkHub:ClearConnections("fullball_pr")

        if preRenderConnections then
            for _, conn in preRenderConnections do
                conn:Enable()
            end
            preRenderConnections = nil
        end
    end

    --// Load / Unload
    function FullBallHandler.loadBall(data)
        data.lastPosition    = nil
        data.previousPosition = nil
        data.lastUpdateTime  = tick()
        data.lastVelocity    = Vector3.new()

        local highlight = data.Ball:FindFirstChildOfClass("Highlight")

        data.frame = Instance.new("Frame")
        data.frame.Size                 = UDim2.new(0, 25, 0, 25)
        data.frame.AnchorPoint          = Vector2.new(.5, .5)
        data.frame.BackgroundTransparency = .5
        data.frame.BackgroundColor3     = highlight.FillColor
        data.frame.Visible              = false
        data.frame.Parent               = Instance.new("ScreenGui", CoreGui)

        Instance.new("UICorner", data.frame).CornerRadius = UDim.new(1, 0)

        local stroke = Instance.new("UIStroke", data.frame)
        stroke.Thickness = 4
        stroke.Color     = highlight.OutlineColor

        SharkHub:Connect(getLabel("d", data.Id), data.Ball.Destroying, function()
            task.spawn(FullBallHandler.unloadBall, data)
        end)
    end

    function FullBallHandler.unloadBall(data)
        SharkHub:ClearConnections("fullball" .. data.Id)
        data.frame:Destroy()
    end

    --// Public API
    function FullBallHandler:Activate()
        if self.Active then return end

        for _, ball in workspace:GetChildren() do
            if not ball:IsA("MeshPart") or ball.Name ~= "Part" then continue end
            local data = { Ball = ball, Name = detectBall(ball), Id = newId() }
            FullBallHandler.loadBall(data)
            table.insert(FullBallHandler.Balls, data)
        end

        SharkHub:Connect(getLabel("ca"), workspace.ChildAdded, function(ball)
            if not ball:IsA("MeshPart") or ball.Name ~= "Part" then return end
            local data = { Ball = ball, Name = detectBall(ball), Id = newId() }
            FullBallHandler.loadBall(data)
            table.insert(FullBallHandler.Balls, data)
        end)

        hookPreRender()
        self.Active = true
    end

    function FullBallHandler:Deactivate()
        if not self.Active then return end
        unhookPreRender()

        for _, data in FullBallHandler.Balls do
            FullBallHandler.unloadBall(data)
        end

        table.clear(FullBallHandler.Balls)
        SharkHub:ClearConnections("fullball")
        self.Active = false
    end
end

--// BallESP.lua //--
local BallESP = { Active = false, _cache = {}, _drawings = {} }

do
    local Camera = workspace.CurrentCamera

    local TYPE_COLORS = {
        Default  = Color3.fromRGB(0, 229, 255),
        Fireball = Color3.fromRGB(255, 107, 0),
        Fake     = Color3.fromRGB(255, 34, 119),
    }

    local function newLine(thickness, color)
        local d = Drawing.new("Line")
        d.Thickness = thickness
        d.Color = color or Color3.new(1,1,1)
        d.Visible = false
        return d
    end

    local function newCircle(radius, filled, thickness)
        local d = Drawing.new("Circle")
        d.Radius = radius
        d.Filled = filled
        d.Thickness = thickness or 1
        d.Visible = false
        return d
    end

    local function newText(size)
        local d = Drawing.new("Text")
        d.Size = size
        d.Center = true
        d.Outline = true
        d.OutlineColor = Color3.new(0,0,0)
        d.Visible = false
        return d
    end

    local function createEntry()
        return {
            box     = { newLine(1), newLine(1), newLine(1), newLine(1) },
            dot     = newCircle(4, true),
            name    = newText(13),
            dist    = newText(11),
            velLine = newLine(1.5, Color3.fromRGB(255, 200, 0)),
            predDot = newCircle(5, false, 1.5),
            predCH  = { newLine(1), newLine(1) },
        }
    end

    local function destroyEntry(entry)
        for _, d in entry.box    do d:Remove() end
        for _, d in entry.predCH do d:Remove() end
        entry.dot:Remove()
        entry.name:Remove()
        entry.dist:Remove()
        entry.velLine:Remove()
        entry.predDot:Remove()
    end

    local function hideEntry(entry)
        for _, d in entry.box    do d.Visible = false end
        for _, d in entry.predCH do d.Visible = false end
        entry.dot.Visible     = false
        entry.name.Visible    = false
        entry.dist.Visible    = false
        entry.velLine.Visible = false
        entry.predDot.Visible = false
    end

    -- s├│ escreve dados ÔÇö zero custo
    local function onTrackingFire(ballId, ballName, position, velocity)
        BallESP._cache[ballId] = {
            name          = ballName,
            position      = position,
            velocity      = velocity,
            lastFireTime  = tick(),
        }
    end

    -- toda l├│gica de desenho aqui, roda no PreRender
    local function renderAll()
        local root = Players.LocalPlayer.Character
            and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        local now = tick()
        local viewportH = Camera.ViewportSize.Y
        local fovFactor = viewportH / (2 * math.tan(math.rad(Camera.FieldOfView) / 2))

        for ballId, data in pairs(BallESP._cache) do
            if now - data.lastFireTime > 0.1 then
                if BallESP._drawings[ballId] then
                    destroyEntry(BallESP._drawings[ballId])
                    BallESP._drawings[ballId] = nil
                end
                BallESP._cache[ballId] = nil
                continue
            end

            if not BallESP._drawings[ballId] then
                BallESP._drawings[ballId] = createEntry()
            end

            local entry    = BallESP._drawings[ballId]
            local color    = TYPE_COLORS[data.name] or TYPE_COLORS.Default
            local position = data.position
            local velocity = data.velocity

            local screenPos, onScreen = Camera:WorldToViewportPoint(position)
            local depth = screenPos.Z

            if not onScreen or depth <= 0 then
                hideEntry(entry)
                continue
            end

            local sp   = Vector2.new(screenPos.X, screenPos.Y)
            local half = math.clamp((5 / depth) * fovFactor, 20, 40)

            -- Box
            local bx, by = sp.X, sp.Y
            local boxThickness = math.clamp(half * 0.08, 1, 4)
            local corners = {
                {Vector2.new(bx-half, by-half), Vector2.new(bx+half, by-half)},
                {Vector2.new(bx+half, by-half), Vector2.new(bx+half, by+half)},
                {Vector2.new(bx+half, by+half), Vector2.new(bx-half, by+half)},
                {Vector2.new(bx-half, by+half), Vector2.new(bx-half, by-half)},
            }
            for i, line in entry.box do
                line.From      = corners[i][1]
                line.To        = corners[i][2]
                line.Color     = color
                line.Thickness = boxThickness
                line.Visible   = true
            end

            -- Dot
            entry.dot.Radius   = math.clamp(half * 0.18, 2, 10)
            entry.dot.Position = sp
            entry.dot.Color    = color
            entry.dot.Visible  = true

            -- Name
            entry.name.Position = Vector2.new(bx, by - half - 16)
            entry.name.Text     = data.name:upper()
            entry.name.Color    = color
            entry.name.Visible  = true

            -- Distance
            local distStuds = root and (root.Position - position).Magnitude or 0
            entry.dist.Position = Vector2.new(bx, by + half + 4)
            entry.dist.Text     = string.format("%.1f studs", distStuds)
            entry.dist.Color    = Color3.fromRGB(180, 210, 220)
            entry.dist.Visible  = true

            -- Velocity line
            entry.velLine.Visible = false

            -- Predicted pos
            local vmag = velocity.Magnitude  -- ÔåÉ adiciona essa linha
            local direction = vmag > 0 and velocity.Unit or Vector3.zero
            local predWorld = position + direction * globalConfigs.combat_appredict
            local ps, pon = Camera:WorldToViewportPoint(predWorld)

            if pon and ps.Z > 0 then
                local pp = Vector2.new(ps.X, ps.Y)
                local cs = math.clamp(half * 0.25, 4, 12)

                entry.predDot.Radius    = math.clamp(half * 0.12, 2, 8)
                entry.predDot.Position  = pp
                entry.predDot.Color     = color
                entry.predDot.Visible   = true

                entry.predCH[1].From = Vector2.new(pp.X-cs, pp.Y)
                entry.predCH[1].To   = Vector2.new(pp.X+cs, pp.Y)
                entry.predCH[2].From = Vector2.new(pp.X, pp.Y-cs)
                entry.predCH[2].To   = Vector2.new(pp.X, pp.Y+cs)
                for _, line in entry.predCH do
                    line.Thickness = math.clamp(half * 0.06, 1, 3)
                    line.Color     = color
                    line.Visible   = true
                end
            else
                entry.predDot.Visible = false
                for _, d in entry.predCH do d.Visible = false end
            end
        end
    end

    function BallESP:Activate()
        if self.Active then return end
        self.Active = true

        TrackingHandler:Connect("esp", onTrackingFire)

        SharkHub:Connect(getLabel("esp_render"), RunService.PreRender, renderAll)
    end

    function BallESP:Deactivate()
        if not self.Active then return end

        TrackingHandler:Disconnect("esp")
        SharkHub:ClearConnections("esp_render")

        for _, entry in pairs(self._drawings) do
            destroyEntry(entry)
        end
        table.clear(self._drawings)
        table.clear(self._cache)
        self.Active = false
    end
end

--// Automove.lua //--
local AutoMove = {} do

    local character = player.Character
    local humanoid = character.Humanoid
    local rootPart = character.HumanoidRootPart
    local active = false
    local threadCount = 0

    local function move(pos)
        humanoid:MoveTo(pos)
    end

    local function moveRelative(dir)
        local globalDir = dir.X * workspace.CurrentCamera.CFrame.RightVector
            + dir.Z * workspace.CurrentCamera.CFrame.LookVector
        if dir ~= Vector3.zero then
            globalDir = globalDir.Unit
        end

        humanoid:MoveTo(rootPart.Position + globalDir * dir.Magnitude)
    end

    local function jump()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end

    local function dash()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        task.wait()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    end

    local function passiveThread()
        active = true
        threadCount += 1
        local threadShot = threadCount

        local nextWalkClock = os.clock() + math.random(1,5)
        local nextJumpClock = os.clock() + math.random(1.5,7)

        while task.wait(1) and threadShot == threadCount do
            local now = os.clock()
            local nearestPlayer = nil

            if not nearestPlayer then
                if now > nextWalkClock then -- faltando raycast
                    local x = math.random(1,2) == 1 and 1 or -2
                    local z = math.random(0,1)
                    local cooldown = math.random(1,5)
                    local walkTime = cooldown - math.random(0,2)

                    local dir = Vector3.new(x,0,z*2).Unit

                    moveRelative( dir * humanoid.WalkSpeed * walkTime )
                    nextWalkClock = now + cooldown
                end

                if now > nextJumpClock then -- faltando girar
                    local double = math.random(1,2) == 1

                    if not double then
                        jump()
                    else
                        jump()
                        task.wait(.5)
                        jump()
                    end

                    nextJumpClock = now + math.random(1.5,7)
                end

            else
                local playerDir = rootPart.Position - nearestPlayer.Character.HumanoidRootPart.Position
                move(rootPart.Position + playerDir)

                if now > nextJumpClock then -- faltando girar
                    jump()
                    task.wait(.5)
                    jump()

                    nextJumpClock = now + 1.5
                end
            end
        end
        -- MODO SAFE:
        -- gera random X em rela├º├úo a bola
        -- calcula raycast pra nao ficar andando na parede do nada

        -- pulos em tempos bem longos indeterminados
        -- se tiver gente perto da double jump repetidamente e fica girando

        -- MODO PERIGO:
        -- se afasta do jogador mais proximo se tiver num raio de 20 studs
        -- se tiver muito colado fica pulando pra desviar o clash
    end

    local function agressiveThread()
        active = true
        threadCount += 1
        local threadShot = threadCount
        -- corre at├® a bola
        -- da dash quando muito longe dela
        -- se tiver muito perto de alguem fica pulando
        -- se afasta pra evitar clash
        -- quando a bola ta muito rapida fica pulando frequentemente
    end

    local function exitThread()
        if not active then return end
        threadCount += 1
        move(rootPart.Position)
    end

    AutoMove.StartPassiveMove = passiveThread
    AutoMove.StartAgressiveMove = agressiveThread
    AutoMove.ExitMove = exitThread

end

--// AbilityHandler.lua //--
local AbilityHandler = { Active = false }

--// Globals
local toolbar   = playerGui:WaitForChild("HUD"):WaitForChild("HolderBottom"):WaitForChild("ToolbarButtons")
local deflectButton   = toolbar:WaitForChild("DeflectButton")
local deflectGradient = deflectButton:WaitForChild("Cooldown"):WaitForChild("UIGradient")
local abilityButtons  = {
    toolbar:WaitForChild("AbilityButton1"),
    toolbar:WaitForChild("AbilityButton2"),
    toolbar:WaitForChild("AbilityButton3"),
    toolbar:WaitForChild("AbilityButton4"),
}

--// State
local currentAbilities = {}

--// Utils
local SUPPORTED_ABILITIES = {
    -- Saito
    "UPPER CUT", "SONIC SLIDE", "GROUND WALLS", "AFTERSHOCK",
    -- Keilo
    "ZAP FREEZE", "ZAP DEFLECT", "GODSPEED", "ASSASSIN INVISIBILITY", "LIGHTNING INTERCEPT",
    -- Torokai
    "ICE SLIDE", "ICE SHIELD",
    -- JJ
    "FIST BARRAGE", "STANDOFF",
    -- Denjin
    "ORBITAL CANNON", "GRAVITY HOLD",
    -- Kameki
    "DRAGON RUSH", "KI BLAST", "INSTANT TRAVEL",
    -- Koju
    "LEAP STRIKE", "CHAIN SPEAR", "HANDGUN",
    -- Dr
    "JUICE UP", "SENTRY GUN", "TANK",
    -- Gazo
    "FAKE BALL", "CURSED BLUE", "ASTRAL PORTAL",
    -- Lufus
    "EXTEND-O ARM", "GLASS WALL", "TIME HAKI",
}
local NUM_MAP = { ["1"]="One",["2"]="Two",["3"]="Three",["4"]="Four",
                  ["5"]="Five",["6"]="Six",["7"]="Seven",["8"]="Eight",
                  ["9"]="Nine",["0"]="Zero" }

local function pressAbility(abilityButton)
    local keyName = abilityButton:WaitForChild("KeyCodeLabel").Text
    local enumName = NUM_MAP[keyName] or keyName
    VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode[enumName], false, game)
    task.wait()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[enumName], false, game)
end

local function freeAbilities()
    local list = {}
    for _, btn in currentAbilities do
        local name = btn:FindFirstChild("AbilityNameLabel") and btn.AbilityNameLabel.Text
        if table.find(SUPPORTED_ABILITIES, name) then
            table.insert(list, btn)
        end
    end
    return list
end

--// Public
function AbilityHandler:GetParryStatus()
    local t = deflectButton.BackgroundTransparency
    if math.abs(t - .85) < .1 then
        local timing = deflectGradient.Transparency.Keypoints[2].Time
        if timing < .5  then return "busy"      end
        if timing < .9  then return "unsafe"    end
        return "recovering"
    elseif math.abs(t - .5) < .1 then
        return "free"
    end
    return nil
end

local _lastAbilityTime = 0

function AbilityHandler:UseAbility()
    if tick() - _lastAbilityTime < 0.5 then return end
    local btn = freeAbilities()[1]
    if btn then
        pressAbility(btn)
        _lastAbilityTime = tick()
    end
end

function AbilityHandler:Activate()
    if self.Active then return end
    self.Active = true

    SharkHub:Connect(getLabel("ability_track"), RunService.PreRender, function()
        for _, btn in abilityButtons do
            local t = btn.BackgroundTransparency
            local idx = table.find(currentAbilities, btn)
            if math.abs(t - .35) < .1 then
                if idx then table.remove(currentAbilities, idx) end
            elseif math.abs(t - .5) < .1 then
                if not idx then table.insert(currentAbilities, btn) end
            end
        end
    end)
end

function AbilityHandler:Deactivate()
    if not self.Active then return end
    SharkHub:ClearConnections("ability_track")
    table.clear(currentAbilities)
    self.Active = false
end

--// DelayedRoot.lua //--
local DelayedRoot = { _position = nil }

do
    local player = Players.LocalPlayer

    function DelayedRoot:Activate()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local history = {}

        SharkHub:Connect(getLabel("delayedroot"), RunService.Heartbeat, function()
            local now = tick()
            local DELAY = player:GetNetworkPing() * 3

            table.insert(history, {t = now, cf = root.CFrame})

            while #history > 2 and now - history[1].t > DELAY + 0.1 do
                table.remove(history, 1)
            end

            local target = now - DELAY
            local prev, nxt
            for i = 1, #history - 1 do
                if history[i].t <= target and history[i+1].t >= target then
                    prev = history[i]
                    nxt  = history[i+1]
                    break
                end
            end

            if prev and nxt then
                local alpha = (target - prev.t) / (nxt.t - prev.t)
                self._position = prev.cf:Lerp(nxt.cf, alpha).Position
            end
        end)
    end

    function DelayedRoot:Deactivate()
        SharkHub:ClearConnections("delayedroot")
        self._position = nil
    end

    function DelayedRoot:GetPosition(fallback)
        return self._position or fallback
    end
end

--// Combat.lua //--
local function checkRange(pos2, velocity, range, ballName, callback)
    local char = Players.LocalPlayer.Character;                   if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart");         if not root then return end
    local rootPos = DelayedRoot:GetPosition(root.Position)
    local charHighlight = char:FindFirstChildOfClass("Highlight")

    local direction = velocity.Magnitude > 0 and velocity.Unit or Vector3.zero
    local rayResult = raycastAgainstSphere(
        rootPos, range,
        pos2, direction, globalConfigs.combat_appredict
    )

    if ((pos2 - rootPos).Magnitude < range or rayResult) then

        if ballName == "Default" then
            if charHighlight and charHighlight.FillTransparency < 1 then
                callback()
            end
        elseif ballName == "Fireball" and globalConfigs.combat_detectFireball then
            if getCCsLen() >= 2 then
                callback()
            end
        end

    end
end

local function parryCallback(ballId, ballName, position, velocity, delta)
    local initPos = position + velocity * delta
    local range = globalConfigs.combat_aprange + (ballName == "Fireball" and 3 or 0)
    local status = AbilityHandler.Active and AbilityHandler:GetParryStatus()

    if status == "unsafe" or status == "recovering" then
        checkRange(initPos, velocity, range > 5 and range or 5, ballName, function()
            AbilityHandler:UseAbility()
        end)
    else
        checkRange(initPos, velocity, range, ballName, function()
            parry()
        end)
    end
end

--// Initializate
DelayedRoot:Activate()

--// Interface
local combat = window:CreateTab("Combat", "rbxassetid://10734951847") do

    combat:NewSection({Title = "Auto Parry"})
    local at = combat:NewToggle({Default = false, Title = "Enable Auto Parry", Callback = function(active)
        if active then
            TrackingHandler:Connect("autoparry", parryCallback)
        else
            TrackingHandler:Disconnect("autoparry")
        end
    end})
    combat:NewKeybind({Default = Enum.KeyCode.E, Title = "Parry Keybind", InputCallback = function(pressing)
        if pressing then
            at:SetValue()
        end
    end})
    combat:NewSlider({Default = globalConfigs.combat_aprange, Min = 1, Max = 30, Title = "Parry Range", Description = "Distance at which the ball gets parried.", Callback = function(value)
        globalConfigs.combat_aprange = value
    end})
    combat:NewSlider({Default = globalConfigs.combat_appredict, Min = 1, Max = 30, Title = "Prediction Distance", Description = "How far ahead the ball's path is predicted. Increase if parrying too late.", Callback = function(value)
        globalConfigs.combat_appredict = value
    end})
    combat:NewToggle({Default = globalConfigs.combat_detectFireball, Title = "Parry Fireball", Description = "Also parries Torokai's fireball ability.", Callback = function(active)
        globalConfigs.combat_detectFireball = active
    end})

    combat:NewSection({Title = "Auto Ability"})
    combat:NewToggle({ Default = false, Title = "Auto Ability", Description = "Automatically uses available abilities.", Callback = function(active)
        if active then AbilityHandler:Activate() else AbilityHandler:Deactivate() end
    end})

    combat:NewSection({Title = "Parry Configuration"})
    combat:NewDropdown({Default = globalConfigs.combat_parryMode, Options = {"Intern", "Extern"}, Title = "Parry Mode", Description = "How the parry click is executed.", Callback = function(value)
        globalConfigs.combat_parryMode = value
    end})
    combat:NewParagraph({Description = "INTERN: clicked by the script (invisible to Medal). EXTERN: clicked by an external program (shows up in recordings)."})
    combat:NewDropdown({Default = globalConfigs.combat_trackingMode, Options = {"Low Level", "High Level"}, Title = "Tracking Mode", Description = "Ball tracking accuracy.", Callback=function(value)
        globalConfigs.combat_trackingMode = value
        TrackingHandler:Reload()
    end})
    combat:NewParagraph({Description = "LOW LEVEL: for executors like Xeno that lack some required functions (less precise). HIGH LEVEL: for full-featured executors (more accurate)."})
end

window:SetActiveTab(combat)

--// Visuals.lua //--

--// Interface
local visuals = window:CreateTab("Visuals", "rbxassetid://10709782758") do

    visuals:NewToggle({Default = false, Title = "Ball ESP", Description = "Draws ESP on the ball.", Callback = function(active)
        if active then
            BallESP:Activate()
        else
            BallESP:Deactivate()
        end
    end})

end

--// Auto.lua //--
local readyButton = playerGui:WaitForChild("HUD"):WaitForChild("HolderBottom"):WaitForChild("PlayButton")
local stateChangedSignal = readyButton:GetPropertyChangedSignal("Visible")
local readyPos = Vector3.new(570, 293, -783)
local inGame = not readyButton.Visible

--// Callbacks
local function autoReady(first)
    if inGame then return end
    if not first then
        task.wait(math.random(5,10))
    end

    local character = player.Character
    character.Humanoid:MoveTo(readyPos + Vector3.new(math.random(-5,5),0,math.random(-5,5)))
end

local function autoReadyStop()
    local character = player.Character
    character.Humanoid:MoveTo(character.HumanoidRootPart.Position)
end

local function autoMove()
    if inGame then
        task.spawn(function() AutoMove:StartPassiveMove() end)
    else
        task.spawn(function() AutoMove:ExitMove() end)
    end
end

local function onStateChanged()
    inGame = not readyButton.Visible

    if globalConfigs.auto_autoMove then -- Auto move
        autoMove()
    end

    if globalConfigs.auto_autoReady and not inGame then -- Auto ready
        autoReady()
    end
end

--// Connections
SharkHub:Connect(getLabel("autoready"), stateChangedSignal, onStateChanged)

--// Interface
local auto = window:CreateTab("Auto", "rbxassetid://10709782230") do

    auto:NewToggle({Default = globalConfigs.auto_autoReady, Title = "Auto ready", Description = "Auto joins in ready zone", Callback = function(active)
        globalConfigs.auto_autoReady = active
        if active then
            autoReady(true)
        else
            autoReadyStop()
        end
    end})

    auto:NewToggle({Default = globalConfigs.auto_autoMove, Title =  "Auto move", Description = "Auto moves in the game simulating a real player", Callback = function(active)
        globalConfigs.auto_autoMove = active
        if active then
            autoMove()
        else
            task.spawn(function() AutoMove:ExitMove() end)
        end
    end})

end

--// Misc.lua //--
local serverIds = {
    ["Classic"] = 71000936793663,
    ["Pro"] = 89775940525999,
    ["Beginning"] = 83678792452277,
    ["Trading"] = 109661515411512,
}

--// Interface
local misc = window:CreateTab("Misc", "rbxassetid://10747376349") do

    local md

    misc:NewButton({Title = "Teleport to mode", Description = "Teleport to a mode without unlock", Callback = function()
        local mode = md:GetValue()
        local serverId = serverIds[mode]

        game:GetService("TeleportService"):Teleport(serverId, game.Players.LocalPlayer)
    end})

    md = misc:NewDropdown({Title = "Modes", Default = "Classic", Options = {"Classic", "Pro", "Trading", "Beginning"}})

end

        end
    )
end, _savedKey)
