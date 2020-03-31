#Performance Testing

We run a performance regression test on the following endpoints in the Azure staging deploy pipeline.

```
/api/v3/recruitment_cycles/2020/providers/U80 (threshold 300ms)
/api/v3/recruitment_cycles/2020/providers/U80/courses/2P3K (threshold 300ms)
/api/v3/courses (threshold 4750ms)
```

These tests will warn if performance drops below the preset threshold. This should be reduced as we improve performance.

NB They are not run as part of the normal `rspec` test run and must be run separately.

The tests can also be run locally against a local or deployed environment. By default the tests run against localhost:3001.

```
bundle exec rspec spec/performance/pre_deploy_spec.rb
```

To specify an environment set the `CUSTOM_HOST_NAME` environment variable.

```
CUSTOM_HOST_NAME=https://api2.publish-teacher-training-courses.service.gov.uk bundle exec rspec spec/performance/pre_deploy_spec.rb
```

## Configuration ENV vars

RECRUITMENT_CYCLE - set to 2020 by default
PROVIDER_CODE - set to U80 by default
COURSE_CODE - set to 2P3K by default

