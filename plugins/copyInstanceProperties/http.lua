local httpService = game:GetService("HttpService")

local promise = require(script.Parent.promise)

local http = {}

function http.get(url, nocache, headers)
    local success, result  = promise.new(function(resolve, reject)
        local ok, body = pcall(httpService.GetAsync, httpService, url, nocache, headers)

        if ok then
            resolve(body)
        else
            reject(body)
        end
    end):await()
    if success then
        return result
    else
        warn(result)
    end
end

function http.decode(jsonString)
    return httpService:JSONDecode(jsonString)
end

return http