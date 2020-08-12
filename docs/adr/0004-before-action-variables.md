# 4. Before action variables

Date: 2020-08-11

## Status

Accepted

## Context

This code base currently has a lot of `before_action` in controllers. For
example:

- https://github.com/DFE-Digital/teacher-training-api/blob/6e18d28cafe3d4595a15eb6670cc6950ddf692b8/app/controllers/api/v2/courses_controller.rb#L6

These `before_action` calls typically load data into an instance variable
which are then used later.

However this can become unwieldy when the controller has multiple actions.
Some actions require one set of variables whilst another action may not and
there are resulting overlaps between the variables in use.

Therefore to manage the actions will typically have `only` or `except` options
set to control these conditions.

Therefore this can cause confusion and cognitive overload when trying to
comprehend what variables are actually being loaded and used concerning a
specific action a developer may be working on.

Sometimes because it is not known if these varaibles are needed or not or due
to a mistake it is possible for expensive calls to made to load data that may
not even be needed for the action.

## Options

### 1. Do nothing

The first options is to simply not address this issue and carry on with the
current pattern.

#### Pros

- No work to change existing code.

#### Cons

- Persistence of overhead of understanding variables loaded in controllers.

### 2. Use lazy loaded memoised private methods

One alternative option is to remove the loading of instance variables in the
`before_actions` calls and move these to lazy loaded memoised private methods.

These can then be referenced explicitly in relevant actions which will then
load the needed data and memoise it.

Example:
```ruby
def index
  render jsonapi: courses
end

private

def courses
  @courses ||= Course.all
end
```

References

- http://jgaskins.org/blog/2014/08/25/better-alternative-to-rails-before_action-to-load-objects

#### Pros

- Fewer `before_action` calls
- Lower cognitive overhead on what instance variables are loaded

#### Cons

- Change in behaviour to use new pattern
- Both patterns will be present in the code base whilst existing areas
undergoing change to adopt the new pattern

## Decision

Option 2

## Consequences

Improved maintainability of this code base over a long term period.
