source 'https://rubygems.org'

ruby '2.5.9'

gem 'rails', '~> 4.2.10'

gem 'devise', '~> 4.4.0'
gem 'devise-i18n'

gem 'uglifier', '>= 1.3.0'

gem 'jquery-rails'
gem 'twitter-bootstrap-rails'
gem 'font-awesome-rails'
gem 'russian'

group :development, :test do
  gem 'sqlite3', '~> 1.3.13'
  gem 'byebug'

  gem 'rspec-rails', '~> 3.4'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'launchy'
end

group :production do
  # гем, улучшающий вывод логов на Heroku
  # https://devcenter.heroku.com/articles/getting-started-with-rails4#heroku-gems
  gem 'pg', '~> 0.18'
  gem 'rails_12factor'
end
