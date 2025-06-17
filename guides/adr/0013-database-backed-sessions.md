# 12. Database backed sessions with polymophism

Date: 16 May 2025

## Status

**Proposal**

## Context

Find Teacher Training is currently working towards developing an accounts feature for users searching for teacher training courses. This means we need to authenticate and authorize users in Find, something that we have not needed to do before.

The application already has a `User` model. These users are authenticated via DfE SignIn, and OAuth provider (or MagicLinks) and authorized in the Provider and Support interfaces. The RAils `CookieStore` session cookie is still available in the Find interface.

The new `Candidate` model will be authenticated via One Login, a different OAuth authentication provider, so the models are separate and distinct in the areas of the application they access and the method of authentication.

We have decided it is better now to implement database backed sessions now before creating `Candidate` sessions in production. There are a number of ways to implement database backed sessions. We will choose the approach most pertinent to our current needs. The most implementation of database backed sessions will allow us to have better control over users sessions and authorization within our system.

## What we want

1. Separate cookies for `Candidate` sessions and `User` sessions
2. Ability to terminate sessions server side
3. Store session data on the server (Nice to have)

## Alternatives

### ActiveRecord SessionStore

We first tested implementing this feature using the ActiveRecord SessionStore. We found that this approach is not as flexible as we would like. In order to have two session cookies in one Rails app it involves monkey patching the gem that implements the session store, adding custom middleware and we believed this would be a brittle approach.


### Rails authentication

Recently Rails has provided and authentication generator. This is available in the latest major release of Rails though it seems a little half baked and it doesn't get mentioned in the documentation yet. It also does not store the session data in the database. Instead it stores a signed session id that gets verified on each request. If we do not verify the session_key then the session is terminated. We must consider this carefully. Also the migration path for this approach does not involve storing session data in the database.


## Options

### 1. Single table, with polymorphic sessionable association between users

Single `session` table will store the sessions for all `sessionable` models.

The `User` model exists for authentication in Publish and Support. The `Candidate` model exists for authentication in `Find`. These models will each be associated with the `Session` model.
Each models sessions will be managed by a different cookie. This will allow developers to use separate mechanisms for managing sessions for `Candidate` and `User`.

We can look into unauthenticated sessions and the use of Guests in future if we wish.


| Stage | Model     | Authentication  | Session key                                   | Session table |
| ----  | --------- | --------------  | --------------------------------------------- | ------------- |
| 1     | Candidate | One Login       | `_candidate_teacher_training_courses_session` | `session`     |
| 2     | User      | DfESignIn       | `_teacher_training_courses_session`           | `session`     |
| 3     | Guest     | unauthenticated | `_candidate_teacher_training_courses_session` | `session`     |


#### Session expiration

Candidate sessions in Find will be session cookies. This means they expire when the browser is closed. This is the normal behaviour for a session cookie and unless we want to set another condition like a TTL, this is the proposed style of session expiration for this iteration.

In later iterations we will be integrating with an Identity Provider. The Identity Provider session lasts 1 hour. While the candidate is logged into Find, their session with the Identity Provider can expire and it will make no difference to the candidates use of Find.

### Considerations

We are rolling our own authentications system here. We need to be careful not to expose any vulnerabilities.

Threats:

1. **Cookie sniffing**
    1. All our services are on https
2. **Replay attacks**
    1. We don't store any replay values in the session
3. **Session fixation**
    1. Delete any old sessions on login, and set a new session_key
    2. Use unguessable session_key


### Cleanly separate Candidate sessions from the CookieStore

Rails CookieStore provides the `session` helper in the views and controllers. As the name suggests, it is usually used for managing the users session, including authentication.
We are now proposing to use a separate cookie for authentication (candidate_session). I don't feel we should continue to use the Rails session cookie as it can cause confusion.

If we store any session data in the database then we have no use for the Rails `session` helper.
If we have a clear way of storing session data in the sessions table then it will remove our dependence on the session helper provided by the `CookieStore`.

### Timeline

First we will focus on the `Candidate` model and implement the database sessions for that model.

There is no immediate requirement for `User` models to be handled in this way but it will be desireable to harmonise our authentication system across the service.

In future, the `Guest` may use the same cookie as the `Candidate` but there is no requirement to save unauthenticated user behaviour just yet.

### Migration

```ruby
create_table :session do |t|
  t.string :id_token
  t.string :session_key, null: false # An ungeussable value to prevent fixation attacks
  t.string :ip_address
  t.string :user_agent
  t.jsonb :data, default: {}
  t.references :sessionable, polymorphic: true # Candidate/User

  t.timestamps

  add_index :session, :updated_at, if_not_exists: true
  add_index :session, :session_key, unique: true, if_not_exists: true
end

create_table :authentication do |t|
  t.string :uid # OIDC `sub` property
  t.string :provider # OneLogin/DfESignIn
  t.references :authenticable, polymorphic: true # Candidate/User

  t.timestamps

  add_index :session, %i[sessionable_id sessionable_type], if_not_exists: true
  add_index :session, :updated_at, if_not_exists: true
end

```

### Models

```ruby
class Candidate
    has_many :sessions

# User authentication will not be migrated immediately
class User
    has_many :sessions
```

```ruby
class Session
    belongs_to :sessionable, polymorphic: true

# Matches the identity to a candidate in our system. This has a generic name
# as it will manage authentications for multiple providers in future DfE Sign
# In is another authentication provider that could use this model
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


## Manage authentication

```ruby
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

    # Create sessions
    # Destroy sessions
    # Manage cookies
```

```ruby
module Find::ApplicationController
  include Authentication

  def current_candidate
    Current.session.sessionable
  end

```

```ruby
class Find::SessionsController
    # /auth/one-login/callback

  def callback
    unless authenticated?
      Session.transaction do
        candidate = Authentication.create(provider: omniauth.provider, uid: omniauth.credentials.uid)
        # Reset the session_key cookie in the cookie
        Session.create(sessionable: candidate, session_key:)
      end
    end
    
  def destroy
    # Delete the Session
    # Reset the cookie session_key

end
```

## Showing content based on authenticated?

How we actually use the session in the application:


```ruby
# Show this text if authenticated?
class Find::ResultsController
    if authenticated?
        ...

# /app/views/find/results.html.erb
<% if authenticated? %>
    ...
```

## Protect endpoints from unauthenticated requests
```ruby
# Redirect to sign in unless authenticated
class Find::AccountController
    before_action :require_authentication
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

