# Rollover

Each year we close the current cycles courses and open the new cycle in a
process we call 'Rollover'.

This involves copying existing providers and courses to new records to allow the
providers to update any details and then switching the API over to a new
'recruitment cycle' which in turn releases the new courses on Find & Apply.

This document lists the changes needed to be made to the TTAPI codebase and the
timings for these changes. There is separate documentation for Publish
[here](https://github.com/DFE-Digital/publish-teacher-training/blob/master/docs/rollover.md).

## Testing the Rollover process

This should happen every year in good time to allow for any code
updates/refactoring work.

1. Ensure that **testing environments** are set up for TTAPI and Publish.

2. Begin a test Rollover by running through the steps in
  [On Rollover launch date](#on-rollover-launch-date).
   You'll need a new `RecruitmentCycle` for the next cycle, to create this,
   run `bundle exec rake rollover:create_recruitment_cycle"[YYYY, "YYYY-MM-DD", "YYYY-MM-DD"]"`.
   This is `year`, `application_start_date` and `application_end_date` respectively.
   You might not know the `application_start_date` and `application_end_date` in time for 
   testing, so just use sensible placeholders.

3. Test v2, v3 and public v1 endpoints (v1 is the original UCAS API and soon to
  be deprecated).

4. End the test Rollover by running through the steps in
  [On Rollover end date](#on-rollover-end-date).

5. Test v2, v3 and public v1 endpoints.

6. **Reverse the Rollover** if further testing needed. It might be easiest to
  reset the testing database at this point to remove the rolled-over providers.

7. **Update this document** with any missing steps/changes identified.

## On Rollover launch date

1. Create a new `RecruitmentCycle` with the correct `year`,
  `application_start_date` and `application_end_date` by running:

    **`bundle exec rake rollover:create_recruitment_cycle"[YYYY, "YYYY-MM-DD", "YYYY-MM-DD"]"`**

    (argument order: `year`, `application_start_date`, `application_end_date`)

2. Rollover providers by running:

    **`bundle exec rake rollover:providers`**

3. Complete the steps on Publish. You'll need to have run the above rake tasks
  before making any setting changes on Publish.

## During Rollover

1. Create an **End Rollover PR** including the following code changes:
    - Increment setting `current_recruitment_cycle_year`
    - Increment the route constraint in `scope "/(:recruitment_year)"`

## On Rollover end date

1. Merge the End Rollover PR
2. Complete the steps on Publish
