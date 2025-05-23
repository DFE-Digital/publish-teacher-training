# 12. Database backed sessions with polymophism

Date: 16 May 2025

## Status

**Proposal**

## Context

Find Teacher Training is currently working towards developing an accounts feature for users searching for teacher training courses. This means we need to authenticate and authorize users in Find, something that we have not needed to do before.

The application already has a `User` model. These users are authenticated via DfE SignIn, and OAuth provider (or MagicLinks) and authorized in the Provider and Support interfaces. The session cookie is still available in the Find interface.

The new `Candidate` model will be authenticated via One Login, a different OAuth authentication provider, so the models are separate and distinct in the areas of the application they access and the method of authentication.

We have decided it is better now to implement database backed sessions now before creating `Candidate` sessions in production. There are a number of ways to implement database backed sessions. We will choose the approach most pertinent to our current needs. The most implementation of database backed sessions will allow us to have better control over users sessions and authorization within our system.


## Alternatives

### ActiveRecord SessionStore

We first tested implementing this feature using the ActiveRecord SessionStore. We found that this approach is not as flexible as we would like. It involves monkey patching the gem that implements the session store and we believed this would be a brittle approach.


### Rails authentication
Recently rails has provided and authentication generator. This is available in the latest major release of Rails though it seems a little half baked and it doesn't get mentioned in the documentation yet. We must consider this carefully.


## Prerequisits

1. We want to have separate models for candidate users and admin users.
2. We want separate cookies managing each of their sessions.
3. We want the sessions to be terminable from the server.


The issue motivating this decision, and any context that influences or constrains the decision.

Remember this repo is PUBLIC, do not include sensitive information here.

## Options

### 1. Single table, with polymorphic sessionable association between users

Single `session` table will store the sessions for all `sessionable` models.

Each model will have a different session key. The session key is the cookie key that is stored in the users browser. This will allow developers to be logged out as Publish/Support and as a Candidate independently by deleting the cookie in the browser.

Since Candidates will only be authorized in Find and User will be authorized in Publish/Support, there is a clear distinction between the two models and where we authorize requests.

We can look into unauthenticated sessions and the use of Guests fi the need arises


| Stage | Model     | Authentication  | Session key                                   | Session table |
| ----  | --------- | --------------  | --------------------------------------------- | ------------- |
| 1     | Candidate | One Login       | `_candidate_teacher_training_courses_session` | `session`     |
| 2     | User      | DfESignIn       | `_teacher_training_courses_session`           | `session`     |
| 3     | Guest     | unauthenticated | `_candidate_teacher_training_courses_session` | `session`     |


### Timeline

First we will focus on the Candidate model and implement the Datbase sessions for that model.
There is not immediate requirement for User models to be handled in this way but it will be desireable to harmonise our authentication system across the service
The Guest will use the same cookie as the Candidate but there is no requirement to save unauthenticated user behaviour just yet.

### Migration

```ruby
create_table :session do |t|
  t.string :id_token
  t.string :ip_address
  t.string :user_agent

  t.string :sessionable_id
  t.string :sessionable_type

  t.timestamps

  add_index :session, %i[sessionable_id sessionable_type], if_not_exists: true
  add_index :session, :updated_at, if_not_exists: true
end

create_table :authentication do |t|
  t.string :uid
  t.string :provider

  t.string :authenticable_id
  t.string :authenticable_type

  t.timestamps

  add_index :session, %i[sessionable_id sessionable_type], if_not_exists: true
  add_index :session, :updated_at, if_not_exists: true
end
```

### Models

```ruby
class Candidate
    has_many :sessions
...

class User
    has_many :sessions
...

class Session
    belongs_to :sessionable, polymorphic: true

# Matches the identity to a candidate in our system
class Authentication
    belongs_to :authenticable, polymorphic: true
    before_create :verify

    def verify
    # validate the ID Token signature using the IdP’s public keys.
    # Check important claims:
    # iss matches your expected issuer
    # 
    # aud matches your client ID
    # 
    # exp (token expiry) is valid (not expired)
    # 
    # nonce if you use it (to prevent replay attacks)
    # 
    # This protects against forged tokens.


```

<h2>Candidates</h2>

```ruby
module Find::ApplicationController
  include Authentication

  def current_candidate
    Current.candidate
  end

...

class Find::SessionsController
  # /auth/one-login/callback
  def create
    Authentication.new(provider: omniauth.provider, uid: omniauth.credentials.uid)
    Session.new
    
  def logout
end
```

```ruby
class Find::ResultsController
 if current_user.candidate?
   # load some account stuff

...

module Find
  module Authentication
    # Is the current request authenticated?
    # Helper method for views
    def authenticated?

    # Use in before_action to protect endpoints
    def require_authentication

    # Check for current session and resume from cookie if possible
    def resume_session

    # Log the user out
    def terminate_session
```

#### Pros

- Separate session management for Providers and Candidates
- Ability to delete sessions and logout specific users
- Increased safety from CookieOverflow errors
- Ability to use the session for more than just authentication (e.g., form stores)

#### Cons

- Every authorization request will hit the database

## Decision

The change option that we're proposing or have agreed to implement.

## Consequences

- Separate session management for Providers and Candidates
- Ability to delete sessions and logout specific users
- Increased safety from CookieOverflow errors

