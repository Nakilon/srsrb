source "https://rubygems.org/"
ruby '1.9.3' unless ENV.has_key? 'RUBY_VERSION'

gem 'sinatra'
gem 'hamster'
gem 'hamsterdam'
gem 'haml'
gem 'lexical_uuid'

group :production do
    gem 'puma'
end

group :test do
    gem 'capybara'
    gem 'rake'
    gem 'rspec'
end

group :development do
    gem 'guard'
    gem 'guard-rspec'
    gem 'guard-bundler'
    gem 'rb-fsevent', '~> 0.9'
    gem 'launchy'
    gem 'mutant'
end
