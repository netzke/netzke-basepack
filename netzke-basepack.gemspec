require "./lib/netzke/basepack/version"

Gem::Specification.new do |s|
  s.name        = "netzke-basepack"
  s.version     = Netzke::Basepack::VERSION
  s.author      = "Max Gorin"
  s.email       = "max@goodbitlabs.com"
  s.homepage    = "http://netzke.org"
  s.summary     = "Pre-built Netzke components"
  s.description = "A set of feature-rich extendible Netzke components (such as Form, Grid, Window, TabPanel, etc) and component extensions which can be used as building blocks for your RIA"

  s.files         = Dir["{javascripts,lib,locales,stylesheets}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.test_files    = Dir["{test}/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency 'netzke-core', '1.0.0.0.alpha'
  s.add_dependency 'netzke-testing', '1.0.0.0.alpha'

  s.required_rubygems_version = ">= 1.3.4"
end
