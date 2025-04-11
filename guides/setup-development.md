# Installation

Clone the repo:

    git clone git@github.com:DFE-Digital/publish-teacher-training.git

## Setup the application libraries and dependencies

Run setup:

```bash
./bin/setup
```

## Start the server

To start all the processes run:

```bash
./bin/dev
```

## Using Docker

Run this in a shell and leave it running after cloning the repo:

```
docker compose up --build --detach
```

You can then follow the log output with

```
docker compose logs --follow
```

The first time you run the app, you need to set up the databases. With the above command running separately, do:

```
docker compose exec web /bin/sh -c "bundle exec rails db:setup"
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

> _Choose **either** the download script (1) or the manual download (2) instructions below_

The commands from the previous section will seed the database with some test data, but you must seed the database with a sanitised production dump to run the application locally using the personas.

To seed the database with a sanitised production dump:

- Request a PIM approval for the production environment.

### Option 1) Use the script to reset your local development db directly

Make sure there are no connections to your database

```shell
az login # select the production subscription
bin/restore-backup
```

### Option 2) Download the sanitised production dump from the Azure Storage Account.
- In the Azure portal, go to 'Storage Accounts' -> 's189p01pttdbbkpsanpdsa' -> 'Containers' -> 'database-backup'
- Download the latest sanitised backup.
- Unzip the file and you should see a file called `publish_sanitised_YYYY-MM-DD.sql`.

Then run the following command to populate the database:

```bash
psql manage_courses_backend_development < ~/Downloads/publish_sanitised_YYYY-MM-DD.sql
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

Then make sure to run `caddy start` in the root of the project. You should now be able to access the app at `http://publish.localhost` and `http://find.localhost`.

> If using `bin/dev` then the URL is `http://find.localhost:3001` and `http://publish.localhost:3001`

If you're getting an error message, try `caddy stop` then try stopping the rails server `control C`. Then run `yarn build` followed by `yarn build:css`. Now restart the rails server `rails s` and then try `caddy start`.
