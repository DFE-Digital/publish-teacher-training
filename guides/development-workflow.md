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

- Use the following format so Trello tickets can be synced automatically: `<prefix>(<topic>)[<Trello ticket ID>]: <short description>`.
- Supported prefixes describe the type of change and should match the list below:
  - `feat`: new feature for users (not tooling-only changes).
  - `fix`: bug fixes visible to users (not build script tweaks).
  - `docs`: documentation-only changes.
  - `style`: formatting / linting adjustments without production behaviour changes.
  - `refactor`: production refactors such as renaming variables or restructuring code.
  - `test`: adding or refactoring tests only.
  - `chore`: maintenance tasks such as build or tooling updates.
  - `deps`: dependency updates (gems, npm packages, GitHub Actions etc). Dependabot PRs continue to use their default titles; the workflow skips enforcement for them.
- Keep the short description concise (<= 72 characters when possible) and ensure the topic reflects the area touched, e.g. `feat(Topic)[TRELLO-123]: allow providers to filter results`.
- The value inside `[...]` must match a Trello reference that appears in the card title (e.g. `[TRELLO-123]` or the card shortlink). A GitHub Action uses this reference to automatically attach the PR URL to the card for human-authored PRs. Dependabot PRs are excluded from this automation. If the reference cannot be resolved, the workflow fails and you will need to fix the title or the Trello card name before merging.
- For the Trello automation to work, repo/environment secrets `TRELLO_KEY`, `TRELLO_TOKEN`, and `TRELLO_BOARD_IDS` must be configured. `TRELLO_BOARD_IDS` accepts a comma-separated list of board IDs that contain the relevant cards.

### PR Description

- The PR description should provide the motivation and context behind the changes made.

- The PR description should detail considerations made during development - Which alternatives were considered (if any) and why did you decide to go with the current approach?

- The PR description should include screenshots or videos for visual changes.

- The PR description should call out any areas that you would like specific feedback on.

- If there is an accompanying Trello card, ensure that it is linked in the PR description or comments.

### General guidance

- Developers should attempt to create small iterative PRs.
  - Features may be broken down into smaller PRs to assist with PR reviews and encourage iterative development.
  - If a feature is not ready for usage, it should be hidden behind a `Settings.features.x` configuration.
  - If a feature needs to be turned on or off, it should be hidden behind a feature flag.

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
