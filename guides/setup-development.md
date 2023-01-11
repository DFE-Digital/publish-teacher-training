# Installation

Clone the repo:

    git clone git@github.com:DFE-Digital/publish-teacher-training.git


## Setup the application

Run the following commands:

```bash
yarn
bundle
bundle exec rails db:setup
```

## Start the server


You can use [Foreman](https://github.com/ddollar/foreman) or [Overmind](https://github.com/DarthSim/overmind) to run all the processes needed for local dev. Once you have either of the two, you can run:

```bash
./bin/dev
```

Which will fire off the Rails server, watchers for JS/CSS changes and Sidekiq. You can also run them individually:

```bash
./bin/dev web
```

You don't have to use either of those tools. The script just wraps up the following commands:

```bash
yarn build --watch
yarn build:css --watch
bin/rails server -p 3001
bundle exec sidekiq -t 25 -C config/sidekiq.yml
```

## Using Docker

Run this in a shell and leave it running after cloning the repo:

```
docker-compose up --build --detach
```

You can then follow the log output with

```
docker-compose logs --follow
```

The first time you run the app, you need to set up the databases. With the above command running separately, do:

```
docker-compose exec web /bin/sh -c "bundle exec rails db:setup"
```

Then open http://localhost:3001 to see the app.

## Run The Server in SSL Mode

By default the server does not run in SSL mode. If you want to run the local
server in SSL mode, you can do so by setting the environment variable
`SETTINGS__USE_SSL`, for example, use this command to run the server:

```bash
SETTINGS__USE_SSL=1 rails s
```

### Trust the TLS certificate

Depending on your browser you may need to add the automatically generated SSL
certificate to your OS keychain to make the browser trust the local site.

On macOS:

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain config/localhost/https/localhost.crt
```

## Seeding Data

The commands from the previous section will seed the database with some test data. If you want to seed the database with a sanitised production dump, follow the steps below:

- Download the sanitised production dump from the [Github Actions page](https://github.com/DFE-Digital/publish-teacher-training/actions/workflows/database-restore.yml) and download the latest successful run.
- Unzip the file and you should see a file called `backup_sanitised.sql`.

Then run the following command to populate the database:

```bash
psql manage_courses_backend_development < ~/Downloads/backup_sanitised.sql
```

## Configuring local domains

This app is setup to serve two domains for two live services. In order to develop locally you will need to configure your local machine to resolve these domains to `localhost`. There are two approaches you can use to do this:

### Setup your hosts file

Add the following to your hosts file:

```
127.0.0.1 publish.test
127.0.0.1 find.test
```

And make sure to set the following settings in `config/settings/development.local.yml`:

```ruby
# Settings.base_url to http://publish.test:3001
# Settings.find_temp_url to http://find.test:3001
```

You should be able to access the service you need to work via those urls.

### Using Caddy

[Caddy](https://caddyserver.com/) is a web server that can be used to proxy requests to the local server. It can be configured to resolve the domains to `localhost`. You can install it with homebrew and setup a Caddyfile in the root of the project with the following content:

```
publish.test {
  reverse_proxy localhost:3001
}

find.test {
  reverse_proxy localhost:3001
}
```

And make sure to set the following settings in `config/settings/development.local.yml`:

```ruby
# Settings.base_url to https://publish.test
# Settings.find_temp_url to https://find.test
# Settings.use_ssl to true
```

Then run `caddy start` and you should be able to access those urls locally without modifying your hosts file.
