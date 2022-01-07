local etlua  = require "etlua"

-- Kong admin config generator
-- execute with `kong-yml-env-generator {template-file} {destination-dir}`

-- Use shell command arguments to set file locations
-- first arg: the ETLUA template
-- second arg: the buildpack/app directory

local nginx_template_file = "config/nginx.template"

local template_filename = arg[1]
local config_filename   = arg[2].."/"..nginx_template_file


local template_file = io.open(template_filename, "r")
local template = etlua.compile(template_file:read("*a"))
template_file:close()
local config = template({})

local config_file
config_file = io.open(config_filename, "w")
config_file:write(config)
config_file:close()

print("Wrote nginx_template file: "..config_filename)