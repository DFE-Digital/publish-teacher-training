# User Access and Permissions

This guide describes the user types, authentication methods, and permission model for the Publish and Find teacher
training services.

## User types

The service has four levels of access.

### Public (anonymous)

Anyone can browse and search courses on Find without an account. The public API is also unauthenticated.

### Candidates

Candidates use the Find service to save courses and set up email alerts. They sign up
via [GOV.UK One Login](https://www.sign-in.service.gov.uk) (OAuth 2.0 / OIDC). No approval is needed. Candidates are
stored in the `candidate` table and modelled by `Candidate` (`app/models/candidate.rb`).

Candidates cannot access Publish or the Support Console.

### Provider users

Provider users manage courses on Publish. They authenticate via [DfE Sign-in](https://services.signin.education.gov.uk).

Access is controlled by the `user_permission` table (`app/models/user_permission.rb`). This is a join between `user` and
`provider`. A user can have `UserPermission` records for multiple providers. There are no granular permission flags. If
a
`UserPermission` record exists for a provider, the user has full access to that provider's resources.

A provider user can:

- View, create, edit, publish, and withdraw courses for each of their associated providers
- Manage schools and training sites for each of their associated providers
- Add and remove other users for each of their associated providers

A provider user cannot access providers they are not associated with, or the Support Console.

### Support users (DfE staff)

Support users are `User` records with the `admin` column set to `true`. They must have an `@education.gov.uk` or
`@digital.education.gov.uk` email address. This is validated in `app/models/user.rb`.

The `/support` namespace is gated by `check_user_is_admin` in `app/controllers/support/application_controller.rb`.
Non-admin users receive a 403.

A support user can:

- View and manage all providers and courses
- Create new providers and onboard organisations
- Create the first user for a new provider
- Manage subjects and financial incentives
- Control feature flags and recruitment cycle rollover
- Revert course withdrawals
- Delete candidates
- Access the Sidekiq dashboard
- Access Blazer analytics (requires the additional `blazer_access` flag on the `User` record)

## Permission matrix

| Action                                   | Candidate | Provider user        | Support (admin)            |
|------------------------------------------|-----------|----------------------|----------------------------|
| Browse and search courses (Find)         | Yes       | —                    | —                          |
| Save courses and email alerts            | Yes       | —                    | —                          |
| View courses for associated providers    | —         | Yes                  | Yes (all)                  |
| Create, edit, publish, withdraw courses  | —         | Associated providers | All providers              |
| Manage schools and training sites        | —         | Associated providers | All providers              |
| Add and remove users for a provider      | —         | Associated providers | All providers              |
| Create new providers                     | —         | No                   | Yes                        |
| Manage subjects and financial incentives | —         | No                   | Yes                        |
| Feature flags and rollover               | —         | No                   | Yes                        |
| Revert course withdrawals                | —         | No                   | Yes                        |
| Delete candidates                        | —         | No                   | Yes                        |
| Sidekiq dashboard                        | —         | No                   | Yes                        |
| Blazer analytics                         | —         | No                   | Yes (with `blazer_access`) |

## Authentication methods

| User type     | Method           | Provider         |
|---------------|------------------|------------------|
| Candidate     | OAuth 2.0 / OIDC | GOV.UK One Login |
| Provider user | OIDC             | DfE Sign-in      |
| Support user  | OIDC             | DfE Sign-in      |

In the event that DfE Sign-in is unavailable, Publish can fall back to magic link authentication.
See [authentication.md](authentication.md) for the fallback procedure.

QA and Review environments use basic auth. Credentials are available from the team.

## How to grant access

### Candidates

Self-service. No action required.

### Provider users

An existing provider user can add new users through the Publish UI. Navigate to the provider's user management page and
add the new user's email address.

Alternatively, a support user can add a user to a provider through the Support Console or via Rails console:

```ruby
user = User.find_by(email: "name@example.com")
provider = RecruitmentCycle.current.providers.find_by(provider_code: "2E1")
UserAssociationsService::Create.call(user: user, provider: provider)
```

### Support users

1. Navigate to the add user page in the Support Console:

   `https://www.publish-teacher-training-courses.service.gov.uk/support/{recruitment_cycle_year}/users/new`

2. Fill in the user's details and submit the form.
3. Search for the user, click on their record, tick the "Admin" checkbox, and click update.

See the [Support Playbook](support-playbook.md) for more detail.

### Infrastructure access

Azure and AKS access requires
a [PIM request](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management). See
the [AKS cheatsheet](aks-cheatsheet.md) for cluster details and commands.

## Key files

- `app/models/user.rb` — User model with `admin` and `blazer_access` flags
- `app/models/candidate.rb` — Candidate model
- `app/models/user_permission.rb` — Provider-user join table
- `app/policies/` — Pundit authorisation policies
- `app/controllers/support/application_controller.rb` — Admin gate for the Support Console
- `config/settings.yml` — Authentication mode configuration
