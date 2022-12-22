# API

Our API is documented using [OpenAPI](https://swagger.io/specification/). You can view the documentation at [https://api.publish-teacher-training-courses.service.gov.uk/api-docs](https://api.publish-teacher-training-courses.service.gov.uk/api-docs). We use a few gems to write specs for the API which are then used to generate the documentation. The specs can be found in `/spec/docs`.

## Documentation

We use [Tech Docs](https://github.com/alphagov/tech-docs-gem) to build documentation. To update documentation, run the command below which will generate an open api specification file. The docker build will then take these files to generate the static site.


Use the following command to generate OpenAPI specification:

```sh
bundle exec rake rswag:specs:swaggerize
```


To develop and preview the tech docs you can start and run with [Middleman](https://github.com/middleman/middleman)

```sh
cd docs && bundle install && bundle exec middleman
```
