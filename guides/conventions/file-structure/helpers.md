[Conventions](/guides/conventions.md) / [File Structure](/guides/conventions/file-structure.md) /

# View Helpers

View helpers are used to define presentational helpers, especially those that contain HTML. Many times, you'll find yourself needing to manipulate primitive data from models, in this case, put the presentational methods on the models themselves.

```
.
└ app
  └─ helpers
      ├─ [namespace] (Namespace-specific forms)
      │   └─ [helper_name]_helper.rb
      └─ application_helper.rb
```

There is no inheritance between helpers, so you can define a helper method in any helper file and use it in any view.

A helper file should be a collection of related helper methods. A helper file is structured around either a behavioural context or a resourceful context.

Below is an example of a behavioural helper file:

```ruby
module LinkHelper
  def active_link_to(text, href)
    link_to text, user_path(user), class: class_names("active", current_page?(href))
  end
end
```

Below is an example of a resourceful helper file, these helpers should be nested within the namespace of the resource:

```ruby
module CourseHelper
  def course_status_tag(course)
    govuk_tag(course.status, color: "green")
  end
end
```

All resourceful helpers should be prefixed with the resource name.
