# Allocations

## What is Allocations?

Each year, around the same time as [Rollover](./rollover.md), providers request
places for some over-supplied courses. This is to limit the number of applicants 
for these courses. This process is called 'Allocations'.

Providers request places for courses one academic year in advance. For example,
when allocations opened in 2021, providers requested places for courses for the
academic year 2022/23.

## How does it work?

### When allocations are open

Accredited bodies should be able to request allocations.

They should see:

1. A button to request allocations for a new provider.
2. A table of previously-requested providers with the tag 'Yet to request' and a link to re-request for this current cycle. They can then choose to either:

    a) re-request for this cycle, or

    b) request no allocations

These two forms do the following:

| Action | Allocation enum | Data changes |
|--------|-----------------|--------------|
| 1. Requesting for a new provider | `"initial"` | A new allocation is created for the current cycle with a `"initial" request_type` with their requested `number_of_places`. |
| 2a. Re-requesting for a provider | `"repeat"` | A new allocation is created for the current cycle with a `"repeat" request_type`. The `number_of_places` is set to the `confirmed_number_of_places` for the previous recruitment cycle's allocation. |
| 2b. Requesting no allocations for a provider | `"declined"` | A new allocation is created for the current cycle with a `"declined" request_type`. The `number_of_places` is set to `0` |

_There is no need to manually copy allocations from the previous year to the_
_current cycle. The allocations are created and pre-populated for the current_
_cycle via the above forms._

### When allocations are closed

Accredited bodies should be able to see what providers they have
requested allocations for, but not the numbers requested.

During this time allocations are internally decided upon and providers may or
may not receive the numbers they requested. Once finalised, these numbers are
inserted into the `confirmed_number_of_places` column of the `allocation` table.

### When allocations are confirmed

Accredited bodies should be able to view the confirmed number of places for each
provider they requested.

## What do we need to do?

This document lists the changes needed to be made to the Publish codebase and
the timings for these changes.

### Before (or on) Allocations open date

- Update the setting `allocations_close_date` to reflect the date on which
  Allocations are closed.

### On Allocations open date

- Set feature flag `allocations: state: open`.
- Set feature flag `show_next_cycle_allocation_recruitment_page: true` so that
  users are shown the interrupt screen when they first sign in.
- Increment the setting `allocation_cycle_year`.
- Increment the setting `allocation_cycle_year` in the Teacher Training API.
  This should match what you've set here in Publish.

### On Allocations close date

- Set feature flag `allocations: state: closed`
- Set feature flag `show_next_cycle_allocation_recruitment_page: false` to turn
  off the interrupt page.

### On Allocations confirmed date

- Set feature flag `allocations: state: confirmed`
