[Conventions](/guides/conventions.md) /

# Testing

We ensure the stability of our service and changes to the service by writing and running automated tests. We use [RSpec](https://rspec.info) for our tests.

## What should we test?

We have made the decision to test our codebase with the following types of tests:

- Unit Tests

  We write unit tests to ensure that the individually defined methods of each class function as expected.

  The following kinds of classes should have unit tests, in alphabetical order:

  - `components` (View components)
  - `forms` (Form objects)
  - `helpers` (View helpers)
  - `jobs`
  - `lib` (PORO classes)
  - `mailers`
  - `models`
  - `policies`
  - `services` (Service objects)
  - `validators`

- System Tests

  We write system tests to enact out user behaviour on our services. System tests should act out each expected use case a user will perform, including potential "unhappy" paths.

  System tests should not reference non-visible identifiers, such as CSS classes and IDs, to target DOM elements, as users are not expected to be able to find DOM elements in such matters. Use text to reference elements. If there are duplicates, this is a potential design interation consideration. In some cases where repeated text is part of a design pattern, such as "Change" links, use visually hidden text. This helps with tests, but also with screen readers and accessibility.

  To optimise the readability of system specs, we follow cucumber-style test definitions - _Given-When-Then_.

  ```ruby
  scenario "User wants to do something" do
    given_i_am_signed_in
    when_i_navigate_to_the_do_something_page
    then_i_should_see_a_list_of_somethings

    when_i_click_on_the_do_something_button
    then_something_happens
  end
  ```

  It is encouraged to write a single `scenario` block for each system test file.

- Request Tests

  We should only add request tests for API endpoints. As each endpoint is used in isolation, we do not need to simulate user behaviour at the level of system tests.

## Automated testing

Each push to a Pull Request will run the entire test suite in a parallel fashion. We use [this GitHub Actions workflow](/.github/workflows/build-and-deploy.yml) to define how we test our code before deployments.

## Test Coverage

As of 16 May 2025, test coverage is 93.4% at 167.42 hits/line.

Test coverage is important to ensuring that the code is appropriately tested. We currently do not have any processes in place to ensure good test coverage, although we do have the [simplecov](https://github.com/simplecov-ruby/simplecov) gem installed.

The [undercover](https://github.com/grodowski/undercover) gem is useful for ensuring that test coverage does not drop as new code is added.

## Running the tests locally

You can run the entire Ruby test suite with the following command:

```sh
bundle exec rspec
```

You can run the entire JavaScript test suite with the following command:

```sh
yarn test
```
