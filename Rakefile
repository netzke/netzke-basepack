begin
  require 'jeweler'
  require './lib/netzke/basepack/version'
  Jeweler::Tasks.new do |gemspec|
    gemspec.version = Netzke::Basepack::Version::STRING
    gemspec.name = "netzke-basepack"
    gemspec.summary = "Pre-built Rails + ExtJS components for your RIA"
    gemspec.description = "A set of full-featured extendible Netzke components (such as Form, Grid, Window, BorderLayoutPanel, etc) which can be used as building block for your RIA"
    gemspec.email = "nmcoder@gmail.com"
    gemspec.homepage = "http://netzke.org"
    gemspec.add_dependency("netzke-core",   "~>0.8.0")
    gemspec.authors = ["nomadcoder"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

# Load tasks, that will be available for Rails user
Dir[File.join(File.dirname(__FILE__), './lib/tasks/*.rake')].each { |file| load file }
# Load tasks for gem development
Dir[File.join(File.dirname(__FILE__), 'tasks/*.rake')].each { |file| load file }

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
    task publish: :yard do
      dir = 'www/api.netzke.org/basepack'
      puts "Publishing to fl:#{dir}..."
      `ssh fl "mkdir -p #{dir}"`
      `scp -r doc/* fl:#{dir}`
    end
  end
rescue
  puts "To enable yard do 'gem install yard'"
end
