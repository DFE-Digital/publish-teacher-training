[Conventions](/guides/conventions.md) / [File Structure](/guides/conventions/file-structure.md) /

# Controllers

We organise our controllers within our namespaces.

We should follow resourceful controller conventions.

```
.
└ app
  └─ controllers
      ├─ [namespace] (Namespace-specific controllers)
      │   ├─ [controller_name]_controller.rb
      │   └─ application_controller.rb
      └─ application_controller.rb
```

Each namespace has its own `ApplicationController` as a base for all controllers within that namespace.

```ruby
# Top-level application controller.
# Shared functionality across all namespaces.
class ApplicationController < ActionController::Base
  include Pundit::Authorization
end

# Find application controller.
# Base controller for all Find controllers.
class Find::ApplicationController < ApplicationController
end

# The API application controller inherits from ActionController::API.
# Base controller for all API controllers.
class API::ApplicationController < ActionController::API
end

# The base controller for all v1 API controllers.
class API::V1::ApplicationController < API::ApplicationController
end
```

This allows us to set base functionality across groups of controllers.

The pattern described in [ADR#6 Controller Structure](/guides/adr/0006-controller-structure.md) details a scalable pattern to managing nested resourceful controllers.

```ruby
class Find::RecruitmentCycles::CoursesController < Find::ApplicationController
  # GET /recruitment_cycles/:recruitment_cycle_id/courses
  def index
    @courses = recruitment_cycle.courses
  end

  # GET /recruitment_cycles/:recruitment_cycle_id/courses/:id
  def show
    @course = recruitment_cycle.courses.find(params[:id])
  end

  private

  def recruitment_cycle
    @recruitment_cycle ||= RecruitmentCycle.find(params[:recruitment_cycle_id])
  end
end
```

The `params[:id]` should always be the ID of the resource being acted upon. Parent resources should always be prefixed, e.g. `params[:recruitment_cycle_id]`.
