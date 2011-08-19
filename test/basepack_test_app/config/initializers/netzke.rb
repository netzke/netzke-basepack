Netzke::Basepack.setup do |config|
  # config.icons_uri = "/images/icons"
end

Netzke::Core.setup do |config|
  # config.ext_uri = "/extjs4"
  # config.ext3_compat_uri = "/extjs-compatibility"
  config.js_direct_max_retries = 0
end