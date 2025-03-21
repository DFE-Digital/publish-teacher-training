[Conventions](/guides/conventions.md) / [File Structure](/guides/conventions/file-structure.md) /

# Assets

Images, videos, and stylesheets are stored in the `assets` directory.

```
.
└ app
  └─ assets
      ├─ images
      └─ stylesheets
          ├─ [namespace]
          │   └─ application.scss
          └─ application.scss
```

The top-level `application.scss` is the shared stylesheet for all namespaces.

The `find/application.scss` stylesheet should be included into the `layouts/find/application.html.erb` layout alongside the top-level `application.scss` stylesheet.
