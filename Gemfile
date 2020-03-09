source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4'
# Use postgres as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# downgrade sassc per:
# https://github.com/sass/sassc-ruby/issues/146#issuecomment-577597106
gem 'sassc', '2.1.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# ui framework
gem 'bootstrap', '~> 4.2'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-migrate-rails'
gem 'outfielding-jqplot-rails'
gem 'jquery-tablesorter'
gem 'jquery-tokeninput-rails'

# datatables
gem 'ajax-datatables-rails'
gem 'jquery-datatables'

# in place editing
gem "best_in_place"
# move to font-awesome
gem "font-awesome-sass"

# configuration
gem 'config'

# better uri parsing
# gem 'addressable'

# bootstrappy forms
gem 'simple_form'

# http retrieval
gem 'rest-client'

# pagination
gem 'kaminari'

# exception handling
gem 'rollbar'

# background jobs
gem 'sidekiq'

# mobile device detection
gem 'mobile-fu'

# terse logging
gem 'lograge'

# caching
#gem 'redis-rails'

# slack integration
#gem "slack-ruby-client"
gem "slack-notifier"

# scripts
gem 'thor'

# uploads
gem 'mimemagic'
gem 'rubyzip'
gem "shrine", "~> 3.0"

# xlsx file processing
gem 'roo', '~> 2'

# mathn is removed in ruby 2.5
gem 'mathn'

# nice emails
gem 'bootstrap-email'

# inline svg for team logos
gem 'inline_svg'
gem 'rmagick'

# health check
gem 'okcomputer'


# pull pry out of the development set
gem 'pry-rails'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'httplog'
  gem 'pry-byebug'
  gem "better_errors"
  gem 'binding_of_caller'

  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end
