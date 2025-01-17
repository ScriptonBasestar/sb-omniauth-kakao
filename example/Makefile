setup:
	cp .env.sample .env
	ruby -e "require 'securerandom'; puts SecureRandom.hex(32)"

start:
	ruby app.rb
	# rackup config.ru
	bundle exec rackup -p 3000

dev:
	# https://github.com/alexch/rerun
	rerun -- rackup --port 3000 config.ru
