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
	'@ox_lib/init.lua',
	'locales.lua',
    'config.lua',
}

ui_page 'web/ui.html'

files {
	'web/css/*',
	'web/js/script.js',
	'web/img/*',
	'web/ui.html',
}