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

This app is setup to serve two domains for two live services. In order to develop locally you will need to configure your local machine to resolve these domains to `localhost`. You can use [Caddy](https://caddyserver.com/) to do this.

[Caddy](https://caddyserver.com/) is a web server that can be used to proxy requests to the local server. It can be configured to resolve the domains to `localhost`. You can install it with homebrew and setup a Caddyfile in the root of the project with the following content:

```
publish.localhost {
  reverse_proxy localhost:3001
}

find.localhost {
  reverse_proxy localhost:3001
}
```

Then make sure to run `caddy start` in the root of the project. You should now be able to access the app at `https://publish.localhost` and `https://find.localhost`.

