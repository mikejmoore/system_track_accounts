source 'http://rubygems.org'
source "http://gemserver.openlogic.local:10080"



# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'devise', '~> 3.2'
gem 'devise_token_auth'
gem 'omniauth', '>= 1.0.0'
gem 'mysql2'

gem 'docker-rails-app'
gem 'request_store'

gem 'faraday'

gem 'puma'



group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :test do
  gem "webmock", "~> 1.8"
  
  # API Testing
  
  gem 'rspec', '~> 3.1'
  gem 'rspec-rails', '~> 3.1'
  gem 'rspec-expectations', '~> 3.1'

  gem "random-word", "~> 1.3.0"
  gem "database_cleaner", "~> 1.2.0"
  gem 'factory_girl', '~> 4.4.0'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'spring'
end

