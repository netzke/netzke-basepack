Netzke::Core.setup do |config|
  config.ext_uri = "http://cdn.sencha.com/ext-4.1.1a-gpl" if ENV['EXTJS_SRC'] == 'cdn'
  config.js_direct_max_retries = 0
end
