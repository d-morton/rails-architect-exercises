# Ruby version

Ruby `2.3.*` recommended (2.2.2+)

# System dependencies

* sqlite

# Get your project up and running in a quick manner

```
make init
```

# Get your setup up to date with the latest changes

```
make dev
```

# Gems

```
gem install bundler
bundle install
```

# Database creation & initialization

```
bundle exec rake db:create:all
bundle exec rake db:reset
RAILS_ENV=test bundle exec rake db:environment:set db:schema:load
```

# How to run the test suite

## Full

```
bundle exec rspec spec/
```

## Payments BC

```
bundle exec rspec payments/spec/
```

## Orders BC

```
bundle exec rspec orders/spec/
```

# Services (job queues, cache servers, search engines, etc.)
