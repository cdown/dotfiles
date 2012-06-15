--------------------
-- Simple adblock --
--------------------

-- Basically a simplified version of:
-- https://github.com/quigybo/luakit/blob/d19c3014d0bc5603bf5f6eae5cf689a95d3eb97d/lib/adblock.lua

local table = table
local ipairs = ipairs
local string = string
local info = info
local webview = webview
local luakit = luakit
local strip = lousy.util.string.strip
local os = os
local io = io

module("adblock")

-- Each line must contain a regular expression which is matched against each
-- request. Note that in lua you have to escape characters with a "%" instead of
-- "\".
-- Example line:
--     ^http://.*%.advertising%.com/
whitelist_path = luakit.config_dir .. "/adblock.whitelist"
blacklist_path = luakit.config_dir .. "/adblock.blacklist"

function match(v, uri, signame)
    -- Possible return values:
    -- - signal "navigation-request":
    --      - return true: Proceed.
    --      - return false: Deny request.
    --      - return nothing: No decision, let other handlers decide.
    -- - signal "resource-request-starting":
    --      - return false: Dency request.
    --      - other return values are treated as "proceed".

    for i, pat in ipairs(white)
    do
        if string.match(uri, pat)
        then
            info("[adblock] whitelist match: %s %s", pat, uri)
            return true
        end
    end

    for i, pat in ipairs(black)
    do
        if string.match(uri, pat)
        then
            info("[adblock] blacklist match: %s %s", pat, uri)
            return false
        end
    end

    info("[adblock] no decision: %s", uri)
end

function load_list(file)
    if os.exists(file)
    then
        local target = {}
        for line in io.lines(file)
        do
            table.insert(target, strip(line))
        end
        return target
    end
end

-- Load lists.
white = load_list(whitelist_path) or {}
black = load_list(blacklist_path) or {}

-- Install signal handlers.
webview.init_funcs.adblock_signals = function(view, w)
    view:add_signal("navigation-request",
        function(v, uri)
            return match(v, uri, "navigation-request")
        end)
    view:add_signal("resource-request-starting",
        function(v, uri)
            return match(v, uri, "resource-request-starting")
        end)
end

-- vim: et ts=4 sw=4 sts=4 tw=80 :
