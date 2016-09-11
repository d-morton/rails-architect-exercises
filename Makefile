init: bundler db-init ## runs make bundler and make db-init

dev: bundler db-migrate ## runs make bundler and make db-migrate

spec: payments-spec orders-spec ## runs all tests
	@echo "Running specs from spec/"
	@bundle exec rspec spec/

payments-spec: ## runs rspec for Payments BC
	@echo "Running tests for Payments BC"
	@bundle exec rspec payments/spec/

orders-spec: ## runs rspec for Orders BC
	@echo "Running tests for Orders BC"
	@bundle exec rspec orders/spec/

bundler: ## runs bundle install
	@echo "Installing gem dependencies"
	@bundle install

db-migrate: ## runs rails db:migrate db:test:prepare
	@echo "Migrating development database"
	@bundle exec rails db:migrate db:test:prepare

db-init: ## runs rails db:setup
	@echo "Setting up the database"
	@bundle exec rails db:setup

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
