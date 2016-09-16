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

# How to run the test suite

## Full

```
make spec
```

## Payments BC

```
make payments-spec
```
OR
```
bundle exec rspec payments/spec/
```

## Orders BC
```
make orders-spec
```
OR
```
bundle exec rspec orders/spec/
```

# Services (job queues, cache servers, search engines, etc.)
