module("luci.controller.usb", package.seeall)

I18N = require "luci.i18n"
translate = I18N.translate

function index()
	local fs = require "nixio.fs"
	local multilock = luci.model.uci.cursor():get("custom", "multiuser", "multi") or "0"
	local rootlock = luci.model.uci.cursor():get("custom", "multiuser", "root") or "0"
	if (multilock == "0") or (multilock == "1" and rootlock == "1") then
		local page
		page = entry({"admin", "system", "usb"}, template("admin_system/usb"), translate("USB Configuration"), 96)
		page.dependent = true
	end

	entry({"admin", "system", "getusb"}, call("action_getusb"))
	entry({"admin", "system", "setusb"}, call("action_setusb"))
end

function action_getusb()
	local rv ={}
	
	rv['usb'] = luci.model.uci.cursor():get("usb", "usb", "usb")

	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function action_setusb()
	local set = luci.http.formvalue("set")
	os.execute("/usr/lib/rooter/usb.sh " .. set)
end