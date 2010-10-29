begin
  require 'jeweler'
  require './lib/netzke/basepack/version'
  Jeweler::Tasks.new do |gemspec|
    gemspec.version = Netzke::Basepack::Version::STRING
    gemspec.name = "netzke-basepack"
    gemspec.summary = "Pre-built Rails + ExtJS components for your RIA"
    gemspec.description = "A set of full-featured extendible Netzke components (such as FormPanel, GridPanel, Window, BorderLayoutPanel, etc) which can be used as building block for your RIA"
    gemspec.email = "sergei@playcode.nl"
    gemspec.homepage = "http://github.com/skozlov/netzke-basepack"
    gemspec.authors = ["Sergei Kozlov"]
    gemspec.add_dependency("netzke-core", "~>0.6.0")
    gemspec.add_dependency("meta_where", ">=0.9.3")
    gemspec.add_dependency("will_paginate", "~>3.0.pre2")
    gemspec.add_dependency("acts_as_list")
    gemspec.post_install_message = <<-MESSAGE

========================================================================

           Thanks for installing Netzke Basepack!

  Don't forget to run "./script/generate netzke_basepack" for each
  Rails app that will be using this gem.

  Netzke home page:     http://netzke.org
  Netzke Google Groups: http://groups.google.com/group/netzke
  Netzke tutorials:     http://blog.writelesscode.com

========================================================================

    MESSAGE

  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  require './lib/netzke/basepack/version'
  version = Netzke::Basepack::Version::STRING

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "netzke-basepack #{version}"
  # rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('CHANGELOG*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :rdoc do
  desc "Publish rdocs"
  task :publish => :rdoc do
    `scp -r rdoc/* fl:www/api.netzke.org/basepack`
  end
end