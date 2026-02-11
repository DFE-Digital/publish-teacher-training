# API

Our API is documented using [OpenAPI](https://swagger.io/specification/). You can view the documentation at [https://api.publish-teacher-training-courses.service.gov.uk/api-docs](https://api.publish-teacher-training-courses.service.gov.uk/api-docs). We use a few gems to write specs for the API which are then used to generate the documentation. The specs can be found in `/spec/docs`.

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
