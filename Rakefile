begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.version = "0.5.5"
    gemspec.name = "netzke-basepack"
    gemspec.summary = "Pre-built Rails + ExtJS widgets for your RIA"
    gemspec.description = "A set of full-featured extendible Netzke widgets (such as FormPanel, GridPanel, Window, BorderLayoutPanel, etc) which can be used as building block for your RIA"
    gemspec.email = "sergei@playcode.nl"
    gemspec.homepage = "http://github.com/skozlov/netzke-basepack"
    gemspec.rubyforge_project = "netzke-basepack"
    gemspec.authors = ["Sergei Kozlov"]
    gemspec.add_dependency("netzke-core", ">=0.4.5.1")
    gemspec.add_dependency("searchlogic", ">=2.0.0")
    gemspec.add_dependency("will_paginate", ">=2.0.0")
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "netzke-basepack #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end
