source 'https://rubygems.org'

gem 'rails', '3.2.22'

gem 'pg', '~> 0.18.4'
gem 'bootstrap-generators', '~> 2.1', :git => 'git://github.com/decioferreira/bootstrap-generators.git'
gem 'simple_form'
gem 'devise'
gem 'rack-cors', :require => 'rack/cors'
gem 'cancan'

gem 'rails-backbone'

gem 'daemons'
gem 'delayed_job_active_record'
gem 'delayed_job_web'

gem 'rvm-capistrano'
gem 'rabl'
gem 'httparty', '~> 0.13.7'

gem 'activerecord-postgis-adapter', '0.4.1'

gem 'paperclip', '~> 4.2.2'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  gem 'uglifier', '>= 1.0.3'

  gem 'compass', '>= 0.12.2'
  gem 'compass-rails', '>= 1.0.3'
  gem 'sassy-buttons'
end

gem "susy"

gem 'jquery-rails'

gem 'libv8', '~> 3.11.8'

# Deploy with Capistrano
gem 'capistrano'
gem 'capistrano-ext'

gem 'rspec-rails', '~> 2.0', :group => [:test, :development]
gem 'database_cleaner', :group => :test

group :development do
  gem 'guard-rspec'
  gem 'rb-inotify', '~> 0.8.8', :require => RUBY_PLATFORM.include?('linux') && 'rb-inotify'
  gem 'rb-fsevent', '~> 0.9.1', :require => RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'
end
