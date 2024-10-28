# Development Workflow

## Pull Request conventions

### Branch naming

- Branch names should be descriptive and follow the format `<author initials>/<change summary>`.

  e.g.

  ```
  dd/update-readme
  gs/fix-broken-link
  im/add-search-filters
  td/create-reports
  ```

  The prefixes are to prevent conflicts between developers working on the same feature and developers forking off from each other's branches.

### PR Title

- The PR title should describe the change in a single line.

- The PR title should be less than or equal to 72 characters long, if possible. This is a guideline, not a strict rule.

### PR Description

- The PR description should provide the motivation and context behind the changes made.

- The PR description should detail considerations made during development - Which alternatives were considered (if any) and why did you decide to go with the current approach?

- The PR description should include screenshots or videos for visual changes.

- The PR description should call out any areas that you would like specific feedback on.

- If there is an accompanying Trello card, ensure that it is linked in the PR description or comments.

### General guidance

- Developers should attempt to create small iterative PRs.
  - Features may be broken down into smaller PRs to assist with PR reviews and encourage iterative development.
  - If a feature is not ready for usage, it should be hidden behind a environment variable.
    - TODO: We need to update terraform to allow developers to set environment variables in config.
  - If a feautre needs to be turned on or off, it should be hidden behind a feature flag.

### Things to check before marking a PR as ready for review

- Renaming and removing database columns requires multi-step PRs:

  As requests may come in while a database migration is happening, we need to ensure database changes and code changes are de-coupled.

  **Removing columns**

  1. Update the code to stop using the column. Add the attributes to the model's `ignored_columns` array.
  2. Remove the column from the database.
  3. Remove the attributes from the model's `ignored_columns` array.

- Renaming tables requires a data-migration to update polymorhic association `_type` columns.

- If the API is being change, ensure that the changelog is updated alongside.

- If you are making any database changes, check in with the Data & Insights team to ensure that you are not breaking anything on the analytics side.
