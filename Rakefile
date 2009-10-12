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
    gemspec.add_dependency("netzke-core", ">=0.4.4")
    gemspec.add_dependency("searchlogic", ">=2.0.0")
    gemspec.add_dependency("will_paginate", ">=2.0.0")
  end
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
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
