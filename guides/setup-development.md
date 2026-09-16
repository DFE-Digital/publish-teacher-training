# Installation

Clone the repo:

    git clone git@github.com:DFE-Digital/publish-teacher-training.git

## Prerequisites

Two commands from a fresh clone:

```bash
asdf install
./bin/setup
```

`asdf install` reads `.tool-versions` and gets you Ruby 3.4.10, Node 24.13.0 and
Caddy 2.9.1. Add the plugins first if you have not already (`asdf plugin add
ruby`, and the same for `nodejs` and `caddy`). The file also pins deployment
tooling — kubectl, terraform, azure-cli and others — that local development does
not need.

`./bin/setup` checks everything else before it starts, and offers to install what
is missing: a running Postgres server, the PostGIS extension, and Caddy's local
certificate authority. It stops with the exact command to run if it cannot fix
something itself.

### Postgres and PostGIS

`asdf` does not provide a database server, so this is the one prerequisite that
needs a package manager. `config/database.yml` uses `adapter: postgis` and
`db/schema.rb` enables the `postgis` extension, so both the server and the
extension have to be there or `db:prepare` fails:

```bash
brew install postgresql@17 postgis
brew services start postgresql@17
```

`./bin/setup` detects both and offers to run this for you. Connection settings
come from `DB_USERNAME`, `DB_PASSWORD`, `DB_HOSTNAME` and `DB_PORT`, all of which
fall back to the libpq defaults — a local socket as your own user — so a stock
Homebrew install needs no configuration.

Versions drift across environments and nothing pins them: CI runs Postgres 14,
`docker-compose.yml` uses 17, and local machines vary.

### Ruby and Node

Only one of these two pins is actually enforced, which is worth knowing before
you spend an afternoon on it:

- **Ruby** is pinned in `.ruby-version`, which the `Gemfile` reads, and Bundler
  enforces it — every `bundle` command fails on a different version.
- **Node** is pinned in `.tool-versions`, and `package.json` carries
  `engines: { node: "24.x" }`. **Nothing enforces it.** Yarn 4 ignores `engines`
  for the project it is installing, so `yarn install` succeeds on any version and
  the assets simply build against whatever runtime you have. `./bin/setup` warns
  on a mismatch because nothing else will.

There is no `.node-version` or `.nvmrc`, so `.tool-versions` is the only place the
Node version is written down for a person to read — CI does not use it either, it
pins `node-version: '24.x'` in the workflow directly.

### Yarn 4 (Corepack) troubleshooting

This repo uses Yarn 4 via Corepack (`packageManager: "yarn@4.18.0"`). `./bin/setup`
activates it for you and checks it is there first — Corepack shipped with Node
16.9 to 24 and was **removed in Node 25**, so on a newer runtime you need
`npm install -g corepack` before setup will get past its first step.

If `yarn -v` still shows Yarn 1 — usually a separately installed yarn shadowing
the Corepack shim — run:

```bash
corepack enable
corepack prepare yarn@4.18.0 --activate
yarn -v
yarn install --immutable
```

You generally do not need to delete `node_modules`; only do that if you're trying
to recover from a broken install.

### Caddy

`asdf install` provides the binary. `./bin/dev` starts it from `Procfile.dev`, and
foreman takes the whole stack down if it is missing. The config is tracked as
`Caddyfile.dev` and used directly, so there is nothing to copy.

Caddy also needs its local certificate authority in your OS keychain, which
`./bin/setup` runs for you the first time (`caddy trust`, which will ask for your
password). It matters more than it sounds: `Settings.publish_url` and its siblings
are port-less HTTPS URLs, so anything that follows a redirect — persona sign-in,
for one — lands on `publish.localhost` at 443, and without the certificate the app
looks broken rather than misconfigured.

See [Configuring local domains](#configuring-local-domains) for running without
Caddy.

## Setup the application libraries and dependencies

Run setup:

```bash
./bin/setup
```

It checks the prerequisites above, activates Corepack, installs the Yarn and
Bundler dependencies, prepares the database, and then hands straight over to
`./bin/dev` — so a successful run leaves the server up. Pass `--skip-server` if
you only want the dependencies, or `--skip-checks` to bypass the preflight.

## Install Playwright (for system tests)

```bash
yarn run playwright install --with-deps
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

The compose file maps the app to port 3001, but the router matches on host, so
bare `http://localhost:3001` matches no service and 404s — use
<http://publish.localhost:3001> (or `find.`/`api.`). Note also that the `web`
service runs with `RAILS_ENV=test`, so this is the container setup CI uses rather
than a full local development environment.

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

The personas page at `/personas` renders whether or not you have the dump, but
three of its four users — Anne, Susy and Mary — only exist in it. Until you have
loaded a dump those buttons fail, which reads as broken authentication rather
than as missing data.

The fourth, Colin, is the DfE support agent, and `bin/rails db:seed:integration`
creates him locally. Plain `./bin/setup` seeds neither — it creates a single super
admin user instead, whose sign-in address is in `db/seeds.rb`.

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

The app serves three hosts from one Rails process — `publish.localhost`,
`find.localhost` and `api.localhost` — and routes by host rather than by path
(`config/routes.rb`). Bare `localhost` matches no service and 404s.

macOS resolves `*.localhost` to 127.0.0.1 on its own, so nothing needs to be
added to `/etc/hosts`. On Linux, most resolvers do the same; add entries if yours
does not.

**With Caddy** (what `./bin/dev` runs) you get the port-less HTTPS URLs the app's
own settings use:

- <https://publish.localhost>
- <https://find.localhost>
- <https://api.localhost>

To serve them without `./bin/dev`, run Caddy on its own from the root of the
project:

```bash
caddy start --config Caddyfile.dev --adapter caddyfile
```

**Without Caddy**, run the server directly and add the port. The host constraint
does not care about the port, so this works fine:

```bash
bin/rails server -p 3001
```

- <http://publish.localhost:3001>
- <http://find.localhost:3001>
- <http://api.localhost:3001>

The catch is redirects. `Settings.publish_url` and its siblings have no port, so
anything that follows one — persona sign-in, for one — sends you to port 443 and
you land nowhere unless Caddy is running. Fine for browsing, awkward for
sign-in.

If you're getting an error message, try `caddy stop` then try stopping the rails server `control C`. Then run `yarn build` followed by `yarn build:css`. Now restart the rails server `rails s` and then start Caddy again with the command above.
