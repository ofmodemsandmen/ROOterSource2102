module("luci.controller.fullmenu", package.seeall)
function index()
	local page
	local df = luci.model.uci.cursor():get("custom", "menu", "default")
	if df == '0' then
		page = entry({"admin", "services", "fullmenu"}, template("fullmenu/fullmenu"), "Administrative Menus", 5)
		page.dependent = true
	end
	
	entry({"admin", "menu", "getmenu"}, call("action_getmenu"))
	entry({"admin", "menu", "setmenu"}, call("action_setmenu"))
	
end

function action_getmenu()
	local rv = {}
	id = luci.model.uci.cursor():get("custom", "menu", "full")
	rv["full"] = id
	password = luci.model.uci.cursor():get("custom", "menu", "password")
	rv["password"] = password

	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function action_setmenu()
	local set = luci.http.formvalue("set")
	os.execute("/usr/lib/fullmenu/setmenu.sh " .. set)
	
end