source 'http://rubygems.org'

gemspec

# unreleased version of netzke-core
# gem 'netzke-core', github: 'netzke/netzke-core'

# gem 'netzke-core', path: '~/code/netzke/netzke-core'

gem 'carrierwave'

# This partial duplication of gemspec is required for rails_app to run
group :test do
  gem 'rspec'
  gem 'factory_girl'
  gem 'pickle'
  gem 'capybara', '~> 1.0'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'netzke-testing', '0.10.0.rc1'
end

group :test, :development do
  gem 'pry-rails'
end
