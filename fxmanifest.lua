fx_version 'cerulean'
lua54 'yes'
game 'gta5'

version	'1.0'

client_scripts {
	'client/framework.lua',
	'client/functions.lua',
    'client/client.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/framework.lua',
	'server/functions.lua',
	'server/server.lua',
}

shared_scripts {
	'shared/notification.lua',
	'shared/dispatch_list.lua',
	'shared/player_info.lua',
	'shared/player_list.lua',
	'shared/blip.lua',
	'@ox_lib/init.lua',
	'locales.lua',
    'config.lua',
}

ui_page 'web/ui.html'

files {
	'web/ui.html',
	"web/index.html",
    "web/*.png",
    "web/**/*.png",
    "web/*.js",
    "web/**/*.js",
	"web/*.map",
    "web/*.json",
    "web/**/*.json",
    "web/**/*.wasm",
    "web/**/*.otf",
    "web/**/*.ttf",
}