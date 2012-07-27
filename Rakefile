begin
  require 'jeweler'
  require './lib/netzke/basepack/version'
  Jeweler::Tasks.new do |gemspec|
    gemspec.version = Netzke::Basepack::Version::STRING
    gemspec.name = "netzke-basepack"
    gemspec.summary = "Pre-built Rails + ExtJS components for your RIA"
    gemspec.description = "A set of full-featured extendible Netzke components (such as FormPanel, GridPanel, Window, BorderLayoutPanel, etc) which can be used as building block for your RIA"
    gemspec.email = "nmcoder@gmail.com"
    gemspec.homepage = "http://netzke.org"
    gemspec.authors = ["Denis Gorin"]
    gemspec.add_dependency("netzke-core",   "~>0.7.6")
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
