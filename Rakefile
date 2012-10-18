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

begin
  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    t.options = ['--title', "Netzke Basepack #{Netzke::Basepack::Version::STRING}"]
  end

  namespace :yard do
    desc "Publish docs to api.netzke.org"
    task :publish => :yard do
      dir = 'www/api.netzke.org/basepack'
      puts "Publishing to fl:#{dir}..."
      `ssh fl "mkdir -p #{dir}"`
      `scp -r doc/* fl:#{dir}`
    end
  end
rescue LoadError
  puts "To enable yard do 'gem install yard'"
end
