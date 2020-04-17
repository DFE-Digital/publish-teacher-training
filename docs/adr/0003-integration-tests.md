# 3. Integration Tests

Date: 2020-04-08

## Status

Accepted

## Context

Our deploys to production are currently not very well tested beyond the built-in
feature tests, which while providing good feature coverage, do not test how the
service works as a whole in the production environment.

## Options

### 1. Do Nothing

We currently have a simple smoke-test that tests that the organisations page
loads, but nothing more. This is a kind of smoke-test.

### 2. Separate Out Integration Tests and Add More

Our proposal is to separate out the smoke tests from the integration tests.

#### Smoke Tests

These are light-touch tests that check that the stack is working in a minimally
invasive, or resource-demanding. They must be able to run in any environment, be
independant of specific data existing in the database, and they will run after
deploys and on a regular basis (daily, or more). They also must not change data
on the system in any meaningful way.

#### Integration Tests

These test select user journeys to check that the system as a whole is
functioning. These tests will exercise many parts of the system, including for
example writing to the database, backgrount tasks and inter-system dependencies.

Because these tests will change data, some data will have to be pre-seeded,
specifically data that cannot be created through publish system. For example, at
this time users, organisations and providers will have to already exist in order
to test the creation of sites and courses.

This testing data will be added to the sanitized version of the production db
dump, before it is loaded into staging and other environments.

## Decision

We've decided on option 2 above.

## Consequences

Our test coverage will improve, our confidence in deploys will improve.
