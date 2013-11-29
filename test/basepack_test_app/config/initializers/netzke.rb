Netzke::Core.setup do |config|
  config.ext_uri = "http://cdn.sencha.com/ext-4.1.1a-gpl" if ENV['EXTJS_SRC'] == 'cdn'
  config.js_direct_max_retries = 0
end

Netzke::Testing.setup do |config|
  config.spec_root = File.expand_path("../../../../..", __FILE__)
end
