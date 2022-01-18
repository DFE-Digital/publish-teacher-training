# 10. Merge Publish service into TTAPI

Date: 2022-01-17

## Status

Accepted

## Context

The Publish service allows providers to add courses to the TTAPI database and
keep various bits of related information up to date. It reads/writes via the V2
API endpoints, and has no datastore of its own.

There's a fairly tight coupling between the two, and adding new functionality
to Publish often involves a coordinated set of changes on the API.

We want to merge Publish with TTAPI. The aim is to simplify the architecture of
these apps, making it easier to iterate on new functionality for Publish.

This ADR records how we intend to go about merging the two services. During the
course of the migration, they'll be referred to as Old Publish and New Publish.

## Options

### 1. Gradual redirects

Outline of the approach:

- Set up a CNAME that points www2.publish-teacher-training-courses.service.gov.uk/ to the existing TTAPI app.
- Migrate Old Publish over to TTAPI in sections, rather than doing everything and then switching once. The provider show page gives an overview of each discrete section.
- As we migrate, we keep route structures the same to make redirects simpler.
- As sections are migrated, we redirect users from Old Publish to New Publish in the controller actions. We also update the section link on the provider show page to go to New Publish.
- New Publish will typically only need to link back to Old Publish in the breadcrumbs. This will be handled via a custom helper method, along the lines of https://github.com/DFE-Digital/publish-teacher-training/pull/528/files#diff-20b0835bb2cec2d019f0fc54cbaa1457a740c573dba553c3333d7521de832092L10.
- Once the sections are migrated, we implement both the organisations index page and the provider show page in New Publish.
- When all pages are migrated, point www to New Publish
- Finally, redirect any www2 requests to www

#### Pros

- Conceptually straightforward, and members of the team have experience with this approach from previous projects
- Allows for the gradual migration of Publish functionality, rather than switching everything over all at once

#### Cons

- We'll need to be organised when adding/changing functionality in Old Publish
  to a section that's in the process of being migrated, to ensure the changes
  make it across to New Publish.
- The use of two subdomains means users will have to authenticate with both Old and New Publish

### 2. Gradual proxying of requests

Outline of the approach:

- Migrate parts of Old Publish over section by section, reimplementing them in the TTAPI codebase
- When the user accesses the URL of a migrated section, proxy the request to New Publish and serve up
  the page and assets that are returned. The user will remain on the Old Publish URL the entire time
  but will be seeing responses from New Publish.
- As discrete sections are migrated, add regex matchers for each section URL to the proxying middleware so
  that Old Publish knows which requests to proxy and which to handle itself.
- When everything has been migrated, updated DNS records so that the www domain points to New Publish directly.

#### Pros

- We're dealing with a single domain, so there's no double-authentication when navigating between unmigrated and migrated content
- Allows for the gradual migration of Publish functionality, rather than switching everything over all at once

#### Cons

- As with Option 1, we'll need to be diligent about changes made to a section that's in the process of being migrated.

## Decision

We've agreed to implement Option 1 - gradual redirects.

Following spikes for both approaches, the Publish dev team agreed that Option 1
had the benefit of being conceptually simpler than Option 2, and therefore
likely to be easier to debug in the event of any issues.

Its main downside is the double-authentication required as the user moves
between domains. We've identified some mitigations for this:

- Increase the user session timeout from 6 hours to several days
- Add copy to the New Publish sign-in page explaining the occasional need to authenticate twice

We've agreed with the wider team that this user experience is acceptable for the length of the migration.

## Consequences

What becomes easier or more difficult to do and any risks introduced by the change that will need to be mitigated.

- Publish will be easier to develop and maintain, as it will essentially become a monolith with various API interfaces built against it
- The authentication user experience will be slightly jarring for the length of the migration, but will revert back to normal once it's complete
- The V2 API is only used by Old Publish. We can start thinking about its removal once Old Publish is no longer used.
- We'll need to remember to correctly authorize controller actions as we migrate code over, as this responsibility is handled solely in the V2 API rather
  than in Old Publish's code.
