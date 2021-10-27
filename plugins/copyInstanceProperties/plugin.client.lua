-- TODOLIST:

    -- Start looking into plugin properties etc. so you can find out how to optimize the plugin.

    local lighting = game:GetService("Lighting")
    local selection = game:GetService("Selection")
    local toolbar = plugin:CreateToolbar("LightingSceneConstructor")
    local toggleButton = toolbar:CreateButton("New Scene", "Creates a new lighting scene", "")
    local host = "https://raw.githubusercontent.com/darmyn/Roblox-Class-Properties-Lookup/main/dump.json"
    
    local http = require(script.Parent.http)
    local tab = "    "
    
    local robloxApiDump = http.decode(http.get(host))
    
    local function readAndWritePropertiesOfInstanceToSceneFile(instance, file)
        print("WRITING TO FILE")
        local propertyNamesOfInstance = robloxApiDump[instance.ClassName].properties
        if propertyNamesOfInstance then
			print("INIT")
			print(propertyNamesOfInstance)
            file.Source = file.Source.."\n "..tab..instance.ClassName.." = {"
            for _, propertyName in ipairs(propertyNamesOfInstance) do
                print(propertyName)
                local propertyValue = instance[propertyName]
                if propertyValue then
                    if typeof(propertyValue) == "string" then
                        print("WAS STRING PROPERTY")
                        continue
                    elseif typeof(propertyValue) == "Color3" then
                        print("WAS COLOR PROPERTY")
                        propertyValue = "Color3.fromRGB("..propertyValue.R..", ".. propertyValue.G.. ", ".. propertyValue.B.. ")"
                    elseif typeof(propertyValue) == "boolean" then
                        print("WAS BOOLEAN")
                        continue
                    end
                    file.Source = file.Source.."\n "..tab..tab..propertyName.." = "..tostring(propertyValue)..";"
                end
            end
            print("WRITE COMPLETE")
            file.Source = file.Source.."\n ".. tab.."};"
        end
    end
    
    local function generateScene()
        print("GENERATING SCENE")
        local file = Instance.new("ModuleScript")
        file.Source = "return {"
        for _, selected in ipairs(selection:Get()) do
            readAndWritePropertiesOfInstanceToSceneFile(selected, file)
        end
        file.Source = file.Source.."\n}"
        file.Parent = lighting
    end
    
    toggleButton.Click:Connect(generateScene)