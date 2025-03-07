[Conventions](/guides/conventions.md) / [File Structure](/guides/conventions/file-structure.md) /

# Models

We follow standard Rails conventions for models. Models are stored in the `app/models` directory.

The `app/models` directory should contain only ActiveRecord models. Non-ActiveRecord PORO classes should be in the `app/lib` directory.

```
.
└ app
  └─ models
      ├─ [namespace] (Namespace-specific models)
      │   └─ [model_name].rb
      └─ application_record.rb
```

Models should contain the following logic:

- Associations
- Validations
- Scopes
- Computed getter methods (Presentational methods)

We should refrain from adding business logic to models. Business logic belongs in service objects classes.

We should also refrain from adding callbacks to models. Callbacks are traditionally used to trigger side-effects and that logic belongs in service objects.

Additionally, we should be aware of all mutation points of models. By calculating computed values within service objects, we can test side-effects and coupled attributes in isolation.

We should limit scopes and define complex queries in query objects.
