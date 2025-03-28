[Conventions](/guides/conventions.md) / [File Structure](/guides/conventions/file-structure.md) /

# Form Objects

We use form objects to encapsulate the validation and parameter handling of forms in our application.

We organise our form objects within our namespaces and shared forms at the top-level.

```
.
└ app
  └─ forms
      ├─ [namespace] (Namespace-specific forms)
      │   └─ [form_name]_form.rb
      └─ application_form.rb
```

We have a single `ApplicationForm` base Form Object class. This class is used to set the foundations of shared logic across all form objects.

```ruby
# Top-level application form.
# Shared functionality across all form objects.
class ApplicationForm
  include ActiveModel::Model
end
```
