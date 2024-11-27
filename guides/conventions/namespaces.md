[Conventions](/guides/conventions.md) /

# Namespaces

We use namespaces to organise our code into service-specific modules. This provides us with visibility of separation of concerns.

We benefit from this separtation in the following ways:

- Code under a namespace is intended to be used only by the service it belongs to.

  We can easily detect when code is used incorrectly outside of its namespace.

  This limits the blast radius of changes to a single service. For example, we can confidently make changes to a `Find` component and expect that it will only effect the "Find" service.

- Explicit shared code.

  If code is shared, it is in the top-level namespace.

  We can visually determine how much code is shared between services by looking at the non-namespaced files.

## Our namespaces

- `Find`
- `Publish`
- `Support`
- `API`
