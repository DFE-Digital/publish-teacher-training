# 6. Controller Structure

Date: 2020-08-18

## Status

Accepted

## Context

We cannot design endpoints in a flat structure due to existing requirements around the Find service. By flat structure, we're referring to just having endpoints like:

- `/providers`
- `/courses`

Instead, we have to design endpoints in a nested structure scoped to their parent resources, ie:

- `/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code`
- `/recruitment_cycles/:recruitment_cycle_year/providers/:provider_code/courses/:course_code`.

If we rely on having single controllers to deal with resources which may be nested under other resources, we'll end up mixing concerns/responsibilities of different contraints into one class which will make it difficult to maintain over the long term and less flexible to change. It also violates the single responsibility principle as we end up bloating the class.

## Options

### 1. Single controllers (Default)

The first option is to do nothing and continue to use single controllers.

As an example, given the following routes:

```ruby
    namespace :public do
      namespace :v1 do
        resources :recruitment_cycles, param: :year, only: [:show] do
          resources :courses, only: %i[index]

          resources :providers, only: %i[index show], param: :code do
            resources :courses, only: %i[index show]
          end
        end
      end
    end
  end
```

The controllers would match the following structure:

```
controllers/
|- api/public/v1/
|  |- recruitment_cycles_controller.rb
|  |- courses_controller.rb
|  |- providers_controller.rb
|  +- ...
```

#### Pros

- Simple to grok at first glance without delving into the class

#### Cons

- Could end up with bloated classes which are difficult to maintain and change
- Mix concerns and responsbilities based on the routing contraint

### 2. Use modules to organise controllers

An alternative is to use modules to organise controller classes based on their concerns.

As an example, given the following routes:

```ruby
  namespace :public do
    namespace :v1 do
      resources :recruitment_cycles, param: :year, only: [:show] do
        resources :courses, only: %i[index]
        resources :providers, only: %i[index show], param: :code do

          # Scope will setup the controller hierarchy to match the directory structure below.
          scope module: :providers do
            resources :courses, only: %i[index show], param: :code
          end
        end
      end
    end
  end
```

The controller hierarchy would be setup like:

```
controllers/
|- api/public/v1/
|  |- providers/ 
|  |  |- courses_controller.rb
|  |- recruitment_cycles_controller.rb
|  |- courses_controller.rb
|  |- providers_controller.rb
|  +- ...
```

#### Pros

- Helps to keep classes lightweight, small and focused
- Controllers are left to focus on handling routing constraints
- Logic for fetching records becomes easier to design based on requirements around the route

#### Cons

- Multiple controllers for a resource

## Decision

We have decided to go with option 2 based on the number of benefits we will gain given our current requirements.

## Consequences

- Improved maintainability of the project's source code over a long term period
- Potentially helps with keeping controller actions RESTful by leveraging modules to communicate behaviour

Given the number of options Rails provides for structuring routes, the use of multiple controllers for a given resource is not an uncommon pattern in the wild. See the links below for further reading and examples.

## References

- http://jeromedalbert.com/how-dhh-organizes-his-rails-controllers/
- https://gist.github.com/dhh/10022098
