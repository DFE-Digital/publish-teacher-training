[Conventions](/guides/conventions.md) / [File Structure](/guides/conventions/file-structure.md) /

# Locales

We should use local shorthands for locale keys. For example, if you call `t(".page_title")` from within a controller, `providers#show`, the key will expand to `en.providers.show.page_title`. The same occurs when calling `t(".page_title")` from within a view, `providers/show.html.erb`, the key will expand to `en.providers.show.page_title`.

This allows us to ensure the locality of locales coupled to their counterparts.

The benefits of this approach are:

- It makes it easier to find and update locale keys.
- Naming conventions are consistent across the application.

```
.
└ config
  └─ locales
      ├─ en
      │  └─ [namespace]
      │      └─ [controller_name].yml
      └─ en.yml
```

For example, we could have a `en/publish/providers/users.yml` file. This would contain the following content:

```yaml
en:
  publish:
    providers:
      users:
        index:
          page_title: "User List"
        show:
          page_title: "User Details"
```

For components and form objects, we can use a similar approach. For example, we could have a `en/components/publish/providers.yml` file for the `Publish::Providers::UserForm` form object. This would contain the following content:

```yaml
en:
  components:
    publish:
      user_form:
        name: "Name"
        email: "Email"
```
