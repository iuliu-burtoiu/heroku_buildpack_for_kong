local etlua  = require "etlua"

-- Kong admin config generator
-- execute with `kong-yml-env-generator {template-file} {destination-dir}`

-- Use shell command arguments to set file locations
-- first arg: the ETLUA template
-- second arg: the buildpack/app directory

local rel_config_file = os.getenv("KONG_DECLARATIVE_CONFIG") or "config/kong.yml"

local template_filename = arg[1]
local config_filename   = arg[2].."/"..rel_config_file


-- Read environment variables for runtime config
-- local env_name = os.getenv("ENV_NAME")

-- Render the Kong configuration file
local template_file = io.open(template_filename, "r")
local template = etlua.compile(template_file:read("*a"))
template_file:close()

local values = {
  -- authentication_service_url        = os.getenv("AUTHENTICATION_SERVICE_URL"),
  -- authentication_static_service_url = os.getenv("AUTHENTICATION_STATIC_SERVICE_URL"),
  -- bilateral_service_url             = os.getenv("BILATERAL_SERVICE_URL"),
  -- communities_service_url           = os.getenv("COMMUNITIES_SERVICE_URL"),
  -- engagements_service_url           = os.getenv("ENGAGEMENTS_SERVICE_URL"),
  -- events_service_url                = os.getenv("EVENTS_SERVICE_URL"),
  -- feature_flags_service_url         = os.getenv("FEATURE_FLAGS_SERVICE_URL"),
  -- go_service_url                    = os.getenv("GO_SERVICE_URL"),
  -- images_service_url                = os.getenv("IMAGES_SERVICE_URL"),
  -- knowledge_service_url             = os.getenv("KNOWLEDGE_SERVICE_URL"),
  -- library_service_url               = os.getenv("LIBRARY_SERVICE_URL"),
  -- messages_service_url              = os.getenv("MESSAGES_SERVICE_URL"),
  -- notifications_service_url         = os.getenv("NOTIFICATIONS_SERVICE_URL"),
  -- obb_service_url                   = os.getenv("OBB_SERVICE_URL"),
  -- organizations_service_url         = os.getenv("ORGANIZATIONS_SERVICE_URL"),
  -- payment_service_url               = os.getenv("PAYMENT_SERVICE_URL"),
  -- pdf_export_service_url            = os.getenv("PDF_EXPORT_SERVICE_URL"),
  -- recommendations_service_url       = os.getenv("RECOMMENDATIONS_SERVICE_URL"),
  -- recommendation_ml_service_url     = os.getenv("RECOMMENDATIONS_ML_SERVICE_URL"),
  -- registration_service_url          = os.getenv("REGISTRATION_SERVICE_URL"),
  -- search_service_url                = os.getenv("SEARCH_SERVICE_URL"),
  -- toplink_backend_service_url       = os.getenv("TOPLINK_BACKEND_SERVICE_URL"),
  -- users_service_url                 = os.getenv("USERS_SERVICE_URL"),
  -- zoom_service_url                  = os.getenv("ZOOM_SERVICE_URL")
}

local config = template(values)

local config_file
config_file = io.open(config_filename, "w")
config_file:write(config)
config_file:close()

print("Wrote kong.yml file: "..config_filename..": \n"..config)