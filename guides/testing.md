# Testing & Linting

## Running specs

```
bundle exec rspec
```

### Running specs in parallel

When running specs in parallel for the first time you will first need to set up
your test databases.

`bundle exec rails parallel:setup`

To run the specs in parallel:
`bundle exec rails parallel:spec`

To drop the test databases:
`bundle exec rails parallel:drop`

## Linting

### Ruby

It's best to lint just your app directories and not those belonging to the framework:

```bash
bundle exec rubocop app config db lib spec --format clang
```
or

```
docker-compose exec web /bin/sh -c "bundle exec rubocop app config db lib spec Gemfile --format clang"
```

To fix Rubocop issues:

```
bundle exec rubocop -a app config db lib spec --format clang
```

### JavaScript

To lint the JavaScript files:

```
yarn standard
```

To fix JavaScript lint issues:

```
yarn run standard:fix
```

## Running all pre-build checks

```
bundle exec rake
```
