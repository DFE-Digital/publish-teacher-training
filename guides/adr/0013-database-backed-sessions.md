# 12. Database backed sessions with polymophism

Date: 16 May 2025

## Status

**Proposal**

## Context

Find Teacher Training is currently working towards developing an accounts feature for users searching for teacher training courses. This means we need to authenticate and authorize users in Find, something that we have not needed to do before.

The application already has a `User` model. These users are authenticated via DfE SignIn and authorized in the Provider and Support interfaces.

The new `Candidate` model will be authenticated via One Login, a different OAuth authentication provider, so the models are separate and distinct in the areas of the application they access and the method of authentication.

We have decided it is better now to implement database backed sessions using `activerecord-session_store` now before creating `Candidate` sessions in production to ease the process. Database backed sessions will reduce the risk of CookieOverflow and allow us to have better control over users sessions and authorization within our system.


## Prerequisits

1. Install `activerecord-session_store`
2. Generate migration to drop existing `session` table and create suitable schema



The issue motivating this decision, and any context that influences or constrains the decision.

Remember this repo is PUBLIC, do not include sensitive information here.

## Options

### 1. Single table, with polymorphic sessionable association between users

Single `session` table will store the sessions for all `sessionable` models.

Each model will have a different session key. The session key is the cookie key that is stored in the users browser. This will allow developers to be logged into Publish/Support and as a Candidate at the same time. It will also make it cleaner to control each user type.

Since Candidates will only be authorized in Find and User will be authorized in Publish/Support, there is a clear distinction between the two models and where we authorize requests.


| Model     | Authentication  | Session key                                   | Session table |
| --------- | --------------  | --------------------------------------------- | ------------- |
| User      | DfESignIn       | `_teacher_training_courses_session`           | `session`     |
| Candidate | One Login       | `_candidate_teacher_training_courses_session` | `session`     |
| Guest     | unauthenticated | `_candidate_teacher_training_courses_session` | `session`     |

### Migration

```ruby
create_table :session do |t|
  t.string :session_id
  t.text :data
  t.string :sessionable_id
  t.string :sessionable_type

  t.timestamps

  add_index :session, :session_id, unique: true
  add_index :session, :updated_at
  add_index :session, [:sessionable_id, :sessionable_type]
end
```

### Models

```ruby
class Candidate
    has_many :sessions
  def candidate? = true
  def guest? = false
...

class Guest
  def candidate? = false
  def guest? = true
...

class User
    has_many :sessions
...

class Session
    belongs_to :sessionable, polymorphic: true

```

## Authorization

We may use Policies here too

<table>
<tr>
<td>
<h2>Candidates</h2>

```ruby
module Find::ApplicationController
  include Find::Authentication

  before_action :candidate_authorized

  def signed_in?
    CandidateSession.exists?(session)
  end

  def candidate_user
    CandidateSession.load_from_session(session)
  end

  def current_user
    @current_user ||= if signed_in?
                    candidate_user
                  else
                    guest_user
                  end
  end

  private

  def guest_user
    @guest_user ||= Guest.new(cookies.signed)
  end

...

class Find::SessionsController
  def signout
  def callback
end
```
</td>
<td>
<h2>Users</h2>

```ruby
module Publish::ApplicationController
  include Publish::Authentication

  before_action :user_authorized

...

class Publish::SessionsController
  def signout
  def callback

  # relatively unchanged from current implementation
```
</td>
</tr>
</table>

```ruby
class Find::ResultsController
 if current_user.candidate?
   # load some account stuff

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
- Ability to use the session for more than just authentication (e.g., form stores)

