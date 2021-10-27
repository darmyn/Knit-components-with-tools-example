print("running CloakClient.lua")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local players = game:GetService("Players")
local lighting = game:GetService("Lighting")

local knit = require(replicatedStorage.modules.Knit)
local janitor = require(knit.Util.Janitor)

local assets = replicatedStorage:WaitForChild("assets"):WaitForChild("cloak")

local defaultLightingConfig = {
    Atmosphere = {
        Color = Color3.fromRGB(0, 0, 0);
        Decay = Color3.fromRGB(0.36079999804497, 0.23530000448227, 0.054900001734495);
        Density = 0.39500001072884;
        Glare = 0;
        Haze = 0;
        Offset = 0;
    };
    Sky = {
        MoonAngularSize = 11;
        StarCount = 3000;
        SunAngularSize = 21;
    };
    BloomEffect = {
        Intensity = 1;
        Size = 24;
        Threshold = 2;
    };
    ColorCorrectionEffect = {
        Brightness = 0;
        Contrast = 0;
        Saturation = 0;
        TintColor = Color3.new(1, 1, 1);
    };
    Lighting = {
        Ambient = Color3.fromRGB(0, 0, 0);
        Brightness = 2;
        ClockTime = 14.5;
        ColorShift_Bottom = Color3.fromRGB(0, 0, 0);
        ColorShift_Top = Color3.fromRGB(0, 0, 0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        ExposureCompensation = 0;
        FogColor = Color3.fromRGB(0.75294125080109, 0.75294125080109, 0.75294125080109);
        FogEnd = 100000;
        FogStart = 0;
        GeographicLatitude = 0;
        OutdoorAmbient = Color3.fromRGB(0.27450981736183, 0.27450981736183, 0.27450981736183);
        ShadowColor = Color3.fromRGB(0.69999998807907, 0.69999998807907, 0.72000002861023);
        ShadowSoftness = 0.20000000298023;
    };
    SunRaysEffect = {
    };
}

local fogLightingConfig = {
    Atmosphere = {
        Color = Color3.fromRGB(0, 0, 0);
        Decay = Color3.fromRGB(0.36079999804497, 0.23530000448227, 0.054900001734495);
        Density = 1;
        Glare = 0;
        Haze = 10;
        Offset = 0;
    };
    Sky = {
        MoonAngularSize = 11;
        StarCount = 3000;
        SunAngularSize = 21;
    };
    BloomEffect = {
        Intensity = 1;
        Size = 24;
        Threshold = 2;
    };
    ColorCorrectionEffect = {
        Brightness = 0;
        Contrast = 0;
        Saturation = 0;
        TintColor = Color3.fromRGB(129, 129, 129);
    };
    Lighting = {
        Ambient = Color3.fromRGB(0, 0, 0);
        Brightness = 2;
        ClockTime = 14.5;
        ColorShift_Bottom = Color3.fromRGB(0, 0, 0);
        ColorShift_Top = Color3.fromRGB(0, 0, 0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        ExposureCompensation = 0;
        FogColor = Color3.fromRGB(0.75294125080109, 0.75294125080109, 0.75294125080109);
        FogEnd = 100000;
        FogStart = 0;
        GeographicLatitude = 0;
        OutdoorAmbient = Color3.fromRGB(0.27450981736183, 0.27450981736183, 0.27450981736183);
        ShadowColor = Color3.fromRGB(0.69999998807907, 0.69999998807907, 0.72000002861023);
        ShadowSoftness = 0.20000000298023;
    };
    SunRaysEffect = {
    };
}
local config = {
    localTransparency = .8;
    transitionSpeed = .5;
    debounceLength = 3;
}
local cloakClient = {}
cloakClient.__index = cloakClient
cloakClient.Tag = "Cloak"

function cloakClient.new(instance)
    print("new cloak", instance)
    return setmetatable({
        isPlayerInvisible = false;
        janitor = janitor.new();
        onActivation = instance:WaitForChild("onActivation");
        onDeactivation = instance:WaitForChild("onDeactivation");
        onReplication = instance:WaitForChild("onReplication");
        activatedSound = instance:WaitForChild("activatedSound");
        deactivatedSound = instance:WaitForChild("deactivatedSound")
    }, cloakClient)
end

function cloakClient:SetPlayerTransparency(player, newTransparency)
    local character = player.Character
    if character then
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") and character.PrimaryPart ~= v or v:IsA("Decal") then
                tweenService:Create(
                    v,
                    TweenInfo.new(config.transitionSpeed),
                    {
                        Transparency = newTransparency;
                    }
                ):Play()
            end
        end
    end
end

function cloakClient:AddFog()
    tweenService:Create(lighting, TweenInfo.new(.5), fogLightingConfig.Lighting):Play()
    for _, v in ipairs(lighting:GetChildren()) do
        if fogLightingConfig[v.ClassName] then
            tweenService:Create(v, TweenInfo.new(.5), fogLightingConfig[v.ClassName]):Play()
        end
    end
end

function cloakClient:RemoveFog()
    tweenService:Create(lighting, TweenInfo.new(.5), defaultLightingConfig.Lighting):Play()
    for _, v in ipairs(lighting:GetChildren()) do
        if defaultLightingConfig[v.ClassName] then
            tweenService:Create(v, TweenInfo.new(.5), defaultLightingConfig[v.ClassName]):Play()
        end
    end
end

function cloakClient:PlayActivationSound()
    if self.activatedSound.IsLoaded then
        if self.deactivatedSound.IsPlaying then
            self.deactivatedSound:Stop()
        end
        self.activatedSound:Play()
    end
end

function cloakClient:PlayDeactivationSound()
    if self.deactivatedSound.IsLoaded then
        if self.activatedSound.IsPlaying then
            self.activatedSound:Stop()
        end
        self.deactivatedSound:Play()
    end
end

function cloakClient:Activate()
    if not self.isPlayerInvisible then
        self:SetPlayerTransparency(players.LocalPlayer, config.localTransparency)
        self:PlayActivationSound()
        self:AddFog()
        self.onActivation:FireServer()
        self.isPlayerInvisible = true
    else
        self.isPlayerInvisible = false
        self:SetPlayerTransparency(players.LocalPlayer, 0)
        self:PlayDeactivationSound()
        self:RemoveFog()
        self.onDeactivation:FireServer()
    end
end

function cloakClient:Init()
    self.janitor:Add(self.Instance.Activated:Connect(function()
        self:Activate()
    end))
    self.janitor:Add(self.onReplication.OnClientEvent:Connect(function(playerName, newTransparency, shouldApplyForLocalPlayer)
        print("Replicating "..playerName.." and making transparency = "..newTransparency)
        local player = players[playerName]
        if player then
            print("GOT PLAYER")
            if shouldApplyForLocalPlayer and player == players.LocalPlayer then
                print("setting for local player")
                task.spawn(self.Activate, self)
            end
            if player ~= players.LocalPlayer then
                print("setting for other player")
                self:SetPlayerTransparency(player, newTransparency)
                if newTransparency == 0 then
                    local deactivatedSound = self.deactivatedSound:Clone()
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        deactivatedSound.Parent = hrp
                        deactivatedSound.PlayOnRemove = true
                        deactivatedSound:Destroy()
                    end
                else
                    local activatedSound = self.deactivatedSound:Clone()
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        activatedSound.Parent = hrp
                        activatedSound.PlayOnRemove = true
                        activatedSound:Destroy()
                    end
                end
            end
        end
    end))
end

function cloakClient:Destroy()
    self.janitor:Destroy()
end

return cloakClient