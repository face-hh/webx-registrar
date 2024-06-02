print(window.query)

local publish_domain = get("publish-input-domain")
local publish_tld = get("publish-input-tld")
local publish_ip = get("publish-input-ip")
local publish_done = get("done-1")

local update_key = get("update-input-key")
local update_ip = get("update-input-ip")
local update_done = get("done-2")

local delete_key = get("delete-input-key")
local delete_done = get("done-3")

local result = get("result")

coroutine.wrap(function()
    local res = fetch({
        url = "https://api.buss.lol/tlds",
        method = "GET",
        headers = { ["Content-Type"] = "application/json" },
    })

    local tld_list = table.concat(res, ", ")
    get("tlds").set_content("Available TLDs: " .. tld_list)
end)()

function fetch_dns()
    local body = "{"
    .. '"tld": "'
    .. publish_tld.get_content()
    .. '", '
    .. '"name": "'
    .. publish_domain.get_content()
    .. '", '
    .. '"ip": "'
    .. publish_ip.get_content()
    .. '" }'

    print(body)
    local res = fetch({
        url = "https://api.buss.lol/domain",
        method = "POST",
        headers = { ["Content-Type"] = "application/json" },
        body = body,
    })
   
    return res
end

publish_done.on_click(function()
    local res = fetch_dns()

    if res["secret_key"] then
        result.set_content("Congrats! Your key: " .. res["secret_key"] .. "\nPLEASE SAVE IT.")
    else
        result.set_content(res.status .. ": " .. res.content)
    end
end)

update_done.on_click(function()
    local body = "{"
        .. '"ip": "'
        .. update_ip.get_content()
        .. '"'
        .. "}"

    local res = fetch({
        url = "https://api.buss.lol/domain/" .. update_key.get_content(),
        method = "PUT",
        headers = { ["Content-Type"] = "application/json" },
        body = body,
    })

    print(res)

    if res and res.status then
        if res.status == 429 then
            result.set_content("Failed due to ratelimit.")
        elseif res.status == 404 then
            result.set_content("Failed due to: domain not found.")
        elseif res.status == 400 then
            result.set_content("Failed due to: invalid body.\nMake sure all fields are completed")
        elseif res.status == 200 then
            result.set_content("Success!")
        else
            result.set_content("Failed due to error: " .. res.status)
        end
    elseif res and res.ip then
        result.set_content("Success!")
    else
        result.set_content("Failed due to unknown error.")
    end
end)

delete_done.on_click(function()
    local res = fetch({
        url = "https://api.buss.lol/domain/" .. delete_key.get_content(),
        method = "DELETE",
        headers = { ["Content-Type"] = "application/json" },
    })

    print(res)

    if res and res.status then
        if res.status == 429 then
            result.set_content("Failed due to ratelimit.")
        elseif res.status == 404 then
            result.set_content("Failed due to: domain not found.")
        elseif res.status == 200 then
            result.set_content("Success!")
        else
            result.set_content("Failed due to error: " .. res.status)
        end
    elseif res and res.secret_key then
        result.set_content("Success!")
    else
        result.set_content("Failed due to unknown error.")
    end
end)
