# Installation

Clone the repo:

    git clone git@github.com:DFE-Digital/publish-teacher-training.git

## Prerequisites

`./bin/setup` installs the application's own dependencies, but it assumes a
working Ruby, Node, Caddy and PostGIS are already on your machine.

`.tool-versions` pins the first three, so a version manager that reads it gets
them in one step. [asdf](https://asdf-vm.com) is what the team recommends:

```bash
asdf install
```

That covers Ruby 3.4.10, Node 24.13.0 and Caddy 2.9.1 — add the plugins first if
you have not already (`asdf plugin add ruby`, and the same for `nodejs` and
`caddy`). The file also pins deployment tooling (kubectl, terraform, azure-cli
and others) that local development does not need.

PostGIS is the one prerequisite `asdf` cannot install — see below.

### Ruby and Node

Where each version is pinned, and what breaks on the wrong one:

- **Ruby** is pinned in `.ruby-version`, which the `Gemfile` reads. `bundle
  check` fails on any other version.
- **Node** is pinned by `package.json` (`engines: { node: "24.x" }`), so `yarn
  install` refuses to run on anything else, and the four asset watchers in
  `./bin/dev` will not start either.

Note that Node is the one prerequisite that does **not** stop `./bin/setup`:
`yarn install` is the single step there whose exit status is not checked
(`bin/setup:25`), so setup carries on to bundler and `db:prepare` and reports no
error. You get a run that looks clean with `node_modules` missing or
half-written, which surfaces later as asset and spec failures that look like
something else. If setup was not run on Node 24, check `node -v` and re-run
`yarn install` on its own.

There is no `.node-version` or `.nvmrc`, so `.tool-versions` is the only place
the Node version is written down for a person to read — CI does not use it
either, it pins `node-version: '24.x'` in the workflow directly.

### Yarn 4 (Corepack) troubleshooting

This repo uses Yarn 4 via Corepack (`packageManager: "yarn@4.18.0"`). `./bin/setup`
activates it for you, but if `yarn -v` still shows Yarn 1 — usually a separately
installed yarn shadowing the Corepack shim — run:

```bash
corepack enable
corepack prepare yarn@4.18.0 --activate
yarn -v
yarn install --immutable
```

You generally do not need to delete `node_modules`; only do that if you're trying
to recover from a broken install.

### PostGIS

The one prerequisite `asdf` cannot install, because it is a Postgres extension
rather than a language runtime. `config/database.yml` uses `adapter: postgis`, so
`./bin/setup` fails at `db:prepare` without it:

```bash
brew install postgis
```

### Caddy

Covered by `asdf install` above, or `brew install caddy`. Needed only if you run
`./bin/dev`, which starts Caddy from the `Procfile.dev` — foreman takes the whole
stack down if the binary is missing. The config is tracked as `Caddyfile.dev` and
used directly, so there is nothing to copy.

One thing `asdf` will not do for you:

```bash
caddy trust
```

That installs Caddy's local certificate authority into your OS keychain. It is
worth doing rather than skipping: `Settings.publish_url` and its siblings are
port-less HTTPS URLs, so anything that follows a redirect — persona sign-in, for
one — lands on `publish.localhost` at 443, and without the certificate the app
looks broken rather than misconfigured.

See [Configuring local domains](#configuring-local-domains) for running without
Caddy.

## Setup the application libraries and dependencies

Run setup:

```bash
./bin/setup
```

It activates Corepack, installs the Yarn and Bundler dependencies, prepares the
database, and then hands straight over to `./bin/dev` — so a successful run leaves
the server up. Pass `--skip-server` if you just want the dependencies.

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
