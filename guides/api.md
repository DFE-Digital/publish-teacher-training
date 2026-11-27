# API

Our API is documented using [OpenAPI](https://swagger.io/specification/). You can view the documentation at [https://api.publish-teacher-training-courses.service.gov.uk/api-docs](https://api.publish-teacher-training-courses.service.gov.uk/api-docs). We use a few gems to write specs for the API which are then used to generate the documentation. The specs can be found in `/spec/docs`.

## API key authentication rollout

The database-backed `api_key_authentication` feature flag is off by default
when no state exists. While disabled, the public API still serves requests
whatever the `Authorization` header contains and does not record key use. If the
header is not an active API key, the response carries an `API-Auth-Notice` header
and a `Link` header with `rel="deprecation"` warning that such requests will be
rejected in future. This avoids unexpected 401 responses while providers and
third-party services adapt their requests.

Activate or deactivate it through the support feature flags page, or run
`FeatureFlag.activate(:api_key_authentication)` /
`FeatureFlag.deactivate(:api_key_authentication)` in the Rails console for the
relevant environment. Changes take effect on subsequent requests without an
application restart. When active, requests without a header remain anonymous;
headers without a valid active key receive a 401 response and valid keys have
their use recorded.

This is separate from the `api_keys` flag, which controls API key management in
the support interface.

The separate safeguard rejecting API keys in URLs remains active regardless of
this flag.

## Documentation

We use [Tech Docs](https://github.com/alphagov/tech-docs-gem) to build documentation. To update documentation, run the command below which will generate an open api specification file. The docker build will then take these files to generate the static site.

### Develop and test API documentation

1. If we want to change the documentation, go to `swagger/public_vx` and make changes to the yml files.

2. Run the swaggerize command to generate a new api_spec.json

Use the following command to generate OpenAPI specification:

```sh
bundle exec rake rswag:specs:swaggerize
```

3. Build the documentation locally:

```shell
cd docs
bin/build
```

This builds the static docs site into `public/docs/`. You can then visit `http://publish.localhost:3001/docs/` to see your changes.

In production, the Dockerfile builds the docs in a separate stage and copies the output into the final image.

#### Confirm the openapi specs

    http://publish.localhost:3001/api-docs/public_v1/api_spec.json
