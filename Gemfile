source 'http://rubygems.org'

gemspec

gem 'rails', '~>4.2.0'
gem 'sqlite3'
gem 'yard'
gem 'rake'

gem 'awesome_nested_set', '~>3.0.0'
gem 'carrierwave'

group :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
end

group :development do
  gem 'web-console', '~> 2.0'
end

group :development, :test do
  # gem 'spring' # troubles...
  gem 'pry-rails'
  gem 'netzke-core', github: 'netzke/netzke-core', branch: 'master'
  gem 'netzke-testing', github: 'netzke/netzke-testing', branch: 'master'
  gem 'faker'
end
