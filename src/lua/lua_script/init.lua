--
-- Created by IntelliJ IDEA.
-- User: LandingLX
-- Date: 2018/8/11
-- Time: 11:31
-- To change this template use File | Settings | File Templates.
--

local require = require
local ngx_re_find = ngx.re.find
local lrucache = require "resty.lrucache"
local resolver = require "resty.dns.resolver"
local cache_storage = lrucache.new(200)

local _is_addr = function(hostname)
    return ngx_re_find(hostname, [[\d+?\.\d+?\.\d+?\.\d+$]], "jo")
end

local _get_addr = function(hostname)
    if _is_addr(hostname) then
        return hostname, hostname
    end

    local addr = cache_storage:get(hostname)

    if addr then
        return addr, hostname
    end

    local r, err = resolver:new({
        nameservers = _dns_servers,
        retrans = 5,  -- 5 retransmissions on receive timeout
        timeout = 2000,  -- 2 sec
    })

    if not r then
        return nil, hostname
    end

    local answers, err = r:query(hostname, {qtype = r.TYPE_A})

    if not answers or answers.errcode then
        return nil, hostname
    end

    for i, ans in ipairs(answers) do
        if ans.address then
            cache_storage:set(hostname, ans.address, 300)
            return ans.address, hostname
        end
    end

    return nil, hostname
end

ngx.say(_get_addr("www.baidu.com"))
ngx.say(_get_addr("192.168.0.1"))