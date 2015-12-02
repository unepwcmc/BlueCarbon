source 'https://rubygems.org'

gem 'rails', '3.2.22'

gem 'pg', '~> 0.18.4'
gem 'bootstrap-generators', '~> 2.1', :git => 'git://github.com/decioferreira/bootstrap-generators.git'
gem 'simple_form'
gem 'devise', '~> 3.0.1'
gem 'rack-cors', :require => 'rack/cors'
gem 'cancan'

gem 'rails-backbone', '~> 1.2.0'

gem 'daemons'
gem 'sidekiq', '~> 4.0.1'

gem 'rvm-capistrano'
gem 'rabl'
gem 'httparty', '~> 0.13.7'

gem 'activerecord-postgis-adapter', '0.4.1'

gem 'paperclip', '~> 4.2.2'

group :assets do
  gem 'sass-rails',   '3.2.5'
  gem 'coffee-rails', '~> 3.2.1'

  gem 'uglifier', '~> 2.7.2'

  gem 'sass', '3.3.0.alpha.149'
  gem 'compass', '0.12.2'

  gem 'compass-rails', '>= 1.0.3'
  gem 'sassy-buttons'
end

gem "susy"

gem 'jquery-rails', '~> 3.1.3'

gem 'libv8', '~> 3.11.8'

# Deploy with Capistrano
gem 'capistrano', '~> 3.4', require: false
gem 'capistrano-rails',   '~> 1.1', require: false
gem 'capistrano-bundler', '~> 1.1', require: false
gem 'capistrano-rvm',   '~> 0.1', require: false
gem 'capistrano-sidekiq'
gem 'capistrano-passenger', '~> 0.1.1', require: false

gem 'dotenv-rails'

gem 'rspec-rails', '~> 2.0', :group => [:test, :development]
gem 'database_cleaner', :group => :test
gem 'test-unit', '~> 3.0'
gem 'byebug', '~> 8.2.1', group: [:test, :development]

group :development do
  gem 'rb-inotify', '~> 0.8.8', :require => RUBY_PLATFORM.include?('linux') && 'rb-inotify'
  gem 'rb-fsevent', '~> 0.9.1', :require => RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'
end

group :production, :staging do
  gem 'exception_notification', '~> 4.1.1'
  gem 'slack-notifier', '~> 1.4.0'
end
