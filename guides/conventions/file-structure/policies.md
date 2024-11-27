[Conventions](/guides/conventions.md) / [File Structure](/guides/conventions/file-structure.md) /

# Policies

We use [pundit](https://github.com/varvet/pundit) for authorization. Policies are stored in the `app/policies` directory.

```
.
└ app
  └─ policies
      ├─ [namespace] (Service namespace-specific policies)
      │   ├─ [controller_namespace] (Nested resource-specific policies)
      │   │   └─ [model_name]_policy.rb
      │   └─ [model_name]_policy.rb
      └─ application_policy.rb
```

To avoid a single policy taking on too much responsibility, we recommend creating separate policies for nested resources and service namespaces.

```ruby
# Defines the actions that can be performed on a course by the current user within the Publish service.
class Publish::CoursePolicy < ApplicationPolicy
  # GET /courses/new
  def new?
    # return a boolean
  end
end

# Defines the actions that can be performed on a course of a specific provider by the current user within the Publish service.
class Publish::Providers::CoursePolicy < ApplicationPolicy
  # GET /providers/:provider_id/courses/new
  def new?
    # return a boolean
  end
end

# Defines the actions that can be performed on a course by the current user within the Support service.
class Support::CoursePolicy < ApplicationPolicy
  # GET /courses/new
  def new?
    # return a boolean
  end
end
```
