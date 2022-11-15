module("luci.controller.dawn", package.seeall)

I18N = require "luci.i18n"
translate = I18N.translate

function index()
    local e = entry({ "admin", "dawn" }, firstchild(), translate("Dawn"), 60)
    e.dependent = false
    e.acl_depends = { "luci-app-dawn" }

    entry({ "admin", "dawn", "configure_daemon" }, cbi("dawn/dawn_config"), translate("Configure Dawn"), 1)
    entry({ "admin", "dawn", "view_network" }, cbi("dawn/dawn_network"), translate("View Network Overview"), 2)
    entry({ "admin", "dawn", "view_hearing_map" }, cbi("dawn/dawn_hearing_map"), translate("View Hearing Map"), 3)
end
