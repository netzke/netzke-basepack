source 'http://rubygems.org'

gemspec

# use unreleased version of netzke-core
# gem 'netzke-core', github: 'netzke/netzke-core'

# for local testing
gem 'netzke-core', path: '~/code/netzke/netzke-core'

gem 'carrierwave'

group :test do
  gem 'rspec', '~> 2.13.0'
  gem 'factory_girl'
  gem 'pickle'
  gem 'capybara', '~> 1.0'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rspec-rails'
end

group :test, :development do
  gem 'pry-rails'
end
