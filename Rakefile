# require 'echoe'
# 
# Echoe.new("netzke-basepack") do |p|
#   p.author = "Sergei Kozlov"
#   p.email = "sergei@playcode.nl"
#   p.summary = "Prebuilt Netzke widgets for your RIA"
#   p.url = "http://playcode.nl"
#   p.runtime_dependencies = ["binarylogic-searchlogic >= 2.0.0", "skozlov-netzke-core >= 0.4.0"]
#   p.development_dependencies = []
#   p.test_pattern = 'test/**/*_test.rb'
# 
#   # fixing the problem with lib/*-* files being removed while doing manifest
#   p.clean_pattern = ["pkg", "doc", 'build/*', '**/coverage', '**/*.o', '**/*.so', '**/*.a', '**/*.log', "{ext,lib}/*.{bundle,so,obj,pdb,lib,def,exp}", "ext/Makefile", "{ext,lib}/**/*.{bundle,so,obj,pdb,lib,def,exp}", "ext/**/Makefile", "pkg", "*.gem", ".config"]
# end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "netzke-basepack"
    gemspec.summary = "Pre-built Netzke widgets for your RIA"
    gemspec.description = "Pre-built Netzke widgets for your RIA"
    gemspec.email = "sergei@playcode.nl"
    gemspec.homepage = "http://github.com/skozlov/netzke-basepack"
    gemspec.rubyforge_project = "netzke-basepack"
    gemspec.authors = ["Sergei Kozlov"]
    gemspec.add_dependency "skozlov-netzke-core", ">= 0.4.0"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
