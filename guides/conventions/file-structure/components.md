[Conventions](/guides/conventions.md) / [File Structure](/guides/conventions/file-structure.md) /

# View Components

We use [View Components](https://viewcomponent.org/) to create reusable components in our Rails applications.

```
.
└ app
  └─ components
      ├─ [namespace] (Namespace-specific components)
      │   ├─ [component_name].rb
      │   └─ [component_name].html.erb
      ├─ [model_name] (Model-specific components)
      │   ├─ [component_name].rb
      │   └─ [component_name].html.erb
      ├─ [component_name].rb
      └─ [component_name].html.erb
```
