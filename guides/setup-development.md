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

## Seeding GiasSchool Data

The `rails gias_update` command takes an optional filename, the default is set in lib/tasks/gias_update.rake.

1. With existing csv file e.g 'csv/edubasealldata20230306.csv'. Check the default `CSV_PATH` in lib/tasks/gias_update.rake matches the name of the csv file.

You can then run `rails gias_update` or `rails 'gias_update[csv/<file_name>]'` where <file_name> is the csv filename.

2. You can obtain an updated csv from https://www.get-information-schools.service.gov.uk/Downloads the `establishment fields CSV` checkbox. This can be uploaded to the `csv` directory as a local commit and pushed to main.

Ensure the default `CSV_PATH` in lib/tasks/gias_update.rake matches the name of the new csv file if required.

Test the import function locally with `rails 'gias_update[csv/<file_name>]'`
You should see console output on completion similar to:

```
I, [2023-03-10T13:35:43.050939 #7966]  INFO -- : Done! 22843 schools upserted
I, [2023-03-10T13:35:43.051021 #7966]  INFO -- : Failures 483
I, [2023-03-10T13:35:43.052223 #7966]  INFO -- : Errors - [{:town=>["can't be blank"]} ...
```

You can check the `GiasSchool.count` in the database is correct.

Once the file is merged to main, you can run the process in the required environment.
Use the following sequence to allow the above console output to display, chaining the commands does update the database but does not display the console ouptut.

```
cf target -s ${space}
cf ssh publish-teacher-training-${paas_env}
cd /app
/usr/local/bin/bundle exec rails 'gias_update[csv/<file_name>]'
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

If you're getting an error message, try `caddy stop` then try stopping the rails server `control C`. Then run `yarn build` followed by `yarn build:css`. Now restart the rails server `rails s` and then try `caddy start`. 