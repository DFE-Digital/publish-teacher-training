# 15. Store financial incentives by year with display control

Date: 11 May 2026

## Status

Accepted

## Context

Financial incentives are shown to candidates in Find and exposed through the public API as part of subject and course information.

Previously, each subject had one `FinancialIncentive` record. This matched the way the data was used once published, but it made annual incentive changes harder to manage. New incentive values need to be loaded before they are visible to candidates, then released at a specific date and time. Replacing the existing records directly would either publish the new values too early or require a tightly timed data change.

We need to support multiple financial incentive records for the same subject, with one record representing the incentive that should currently be displayed. The Find service and public API should continue to read only the displayed incentive unless a code path explicitly needs access to all incentive records.

## Options

### 1. Continue replacing the existing incentive for each subject

Keep a single financial incentive record per subject and overwrite it each year when new incentive values are ready.

#### Pros

- Minimal data model change.
- Existing associations and API behaviour stay unchanged.
- No additional release-state field to maintain.

#### Cons

- Future incentive values cannot be loaded without making them visible.
- The release depends on a tightly timed data update.
- We lose the ability to keep current and future incentive values side by side.
- Rollback requires reconstructing the previous values.

### 2. Store one incentive per subject and year, with a displayed flag

Add a `year` integer and `displayed` boolean to `FinancialIncentive`. Each subject can have one incentive per year, and only one incentive per subject can be marked as displayed.

#### Pros

- Future incentive values can be loaded while hidden from Find and the public API.
- The current published incentive remains available until the team deliberately changes the displayed record.
- Database constraints can enforce one incentive per subject/year and one displayed incentive per subject.
- Existing public read paths can continue to use `subject.financial_incentive` for the displayed record.
- Historical and future incentive records remain available to internal code when needed.

#### Cons

- Release of new incentive values becomes a data-management process: old displayed records must be hidden and new records must be shown.
- Application code must be clear about whether it needs the displayed incentive or all incentive records.
- Import code needs to target a specific year rather than assuming the subject has only one incentive.

### 3. Store release dates and automatically display incentives by time

Add release scheduling fields and have the application automatically choose which incentive is displayed based on the current time.

#### Pros

- Removes the need for a manual release-time data change.
- Represents the release schedule directly in the data model.

#### Cons

- More complex than the current operational need.
- Incorrect dates or timezone handling could publish incentives at the wrong time.
- Harder to pause or delay a release once future records are loaded.
- Does not match the requirement for the team to manually flip which incentives are displayed.

## Decision

Store financial incentives as one record per subject and year, with an explicit `displayed` boolean to control which record is visible in Find and the public API.

The `financial_incentive` table will store:

- `year`, an integer for the recruitment year the incentive belongs to.
- `displayed`, a boolean that defaults to `false` for new records.

The year is stored as a plain integer rather than as a recruitment cycle foreign key or recruitment cycle-derived identifier. Financial incentive settings are annual policy values, but they should not be more tightly coupled to recruitment cycle rollover logic than necessary. This keeps future work, such as a UI for creating or updating current-year incentives, focused on incentive management rather than depending on recruitment cycle rollover behaviour.

Existing incentive rows are backfilled to the current recruitment year and marked as displayed so there is no candidate-facing change when the migration runs.

The database enforces:

- one financial incentive per subject and year; and
- no more than one displayed financial incentive per subject.

The application keeps `Subject#financial_incentive` as the displayed incentive association, and adds an association for all incentive records where code needs to work across years. Course and API read paths continue to use the displayed incentive, so hidden future incentives are not shown to candidates.

The financial incentive import service creates or updates incentives for a specific year and defaults new imported incentives to hidden. A later operational step can flip the displayed flag when the new incentives should be released.

## Consequences

Future financial incentives can be imported, validated, and tested before they are visible to candidates. This reduces the risk of timed annual updates and keeps the published values stable until the team chooses to release the new records.

The release process now needs to update display state correctly: each subject should have the previous displayed incentive hidden and the new incentive shown. The database partial unique index prevents two displayed incentives for the same subject, but it does not decide which incentive should be displayed.

Code that previously assumed one incentive per subject must now choose between the displayed association and the full incentive history. This is intentional: public candidate-facing paths should use the displayed incentive, while import and maintenance code can work with year-specific records.

Using an integer year means the database does not enforce a direct relationship between a financial incentive and a recruitment cycle record. Any requirement for incentive years to align with active recruitment cycles should be enforced in the import or management workflow rather than by coupling the data model to recruitment cycle rollover.

Automating the release process, adding admin controls, or recording scheduled release dates can be considered later if the manual flip becomes difficult to operate.
