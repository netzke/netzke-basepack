source 'http://rubygems.org'

gemspec

# unreleased version of netzke-core
# gem 'netzke-core', github: 'netzke/netzke-core'

# for local testing
# gem 'netzke-testing', path: '~/code/netzke/netzke-testing'
# gem 'netzke-core', path: '~/code/netzke/netzke-core'

gem 'carrierwave'

gem 'protected_attributes'

group :test do
  gem 'rspec'
  gem 'factory_girl'
  gem 'pickle'
  gem 'capybara', '~> 1.0'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rspec-rails'
end

group :test, :development do
  gem 'pry-rails'
  gem 'netzke-testing'
end
