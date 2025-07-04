# Rollover Process Guide

Each year, we close the current cycle's courses and open the new cycle in a process called **Rollover**.
This guide explains the full process in simple steps, with images to help you understand each stage.

## What is Rollover?

Rollover is the process of copying existing providers and courses to new records for the upcoming year.
This allows providers to update their details and prepares the system for the next **recruitment cycle**.
Once rollover is complete, new courses appear on **Find** & **Apply**.

## Rollover Overview

![Screenshot of the whole rollover phases](/guides/images/00-rollover-automation.png)

With the new changes, rollover happens in four main phases:

### 1. **Testing (QA) phase**

- We run rollover in a test environment first.
- This lets us check that everything copies over correctly before making the changes.

### 2. **Production rollover**

- We run rollover in our live system.
- All current provider and course data is copied to the new cycle.

### 3. **Support team review**

- After rollover, the Support team can review and make important updates (like accreditation).
- This is our chance to fix any issues before providers see the new cycle.

### 4. **Publish users (Providers)**

- The new cycle and courses become visible to providers in the Publish system.
- Providers can log in, see their courses in the new cycle, and make any updates they need.

## Running rollover

### 1. Create a New Recruitment Cycle

First you need to create a new cycle.

- Go to the **Support interface**.
- Navigate to:
  `Settings > Recruitment cycles > Add new recruitment cycle`
- Add:
  - Year of the cycle
  - Start and end dates
  - When support users can edit next cycle data
  - When providers can edit data (for both current and next cycle)

![Recruitment cycle list page](/guides/images/1-recruitment-cycle-list.png)

### 2. Start the Rollover

- Click on the new cycle to open its details page.
- Click **'Review rollover'**.

  ![Review rollover](/guides/images/3-review-rollover.png)

- Review the summary (number of providers, courses, accreditations to be copied).
- Click **'Confirm'** to start the rollover.

  ![Confirm rollover](/guides/images/3-confirm-rollover.png)

### 3. Monitor Progress

- Many jobs will run in the background (using **Sidekiq**).
- To check progress, visit `/sidekiq` on Publish.

### 4. Verify Data and System Status

- Check for any data issues or errors.
- Test:
  - **Publish** (admin interface)
  - **Publish public v1 endpoints**
  - **Publish support console**

#### Eligibility: Who and What Gets Rolled Over?

- **Providers:**
  Only providers with **published** or **withdrawn** courses are eligible for rollover.
- **Courses:**
  Only courses that are **published** or **withdrawn** will be rolled over.

#### Checking the Numbers

- The **cycle page** clearly shows:
  - Number of eligible providers
  - Number of eligible courses
  - Number of partnerships
  - Number of items actually rolled over

- **After rollover automation finishes:**
  - These numbers should match exactly.
  - If there is a difference, you need to check the database to find out why.

#### What to Do If Numbers Don't Match

- Investigate in the database:
  - Look for providers/courses that were not rolled over.
  - Check their status (published/withdrawn).
  - Compare with the eligibility criteria.
  - Compare both cycles. `RolloverProgressQuery` might help.

```ruby
  query = RolloverProgressQuery.new(target_cycle: RecruitmentCycle.next)

  # Provider from previous cycle that don't have published courses
  query.providers_without_published_courses

  query.eligible_providers
  query.eligible_courses
  query.eligible_partnerships

  query.rolled_over_providers
  query.rolled_over_courses
  query.rolled_over_partnerships
```

#### Disclaimer: Why Data Might Not Be Correct After Rollover

Here are some common reasons why rollover data might not match expectations:

1. **New Table Not Included:**
   A new table was added to the database, but the rollover script wasn't updated to handle it.

2. **New Validation Issues:**
   A new validation rule was added, but old data wasn't updated (backfilled), making some records invalid during rollover.

3. **Missing Columns:**
   A new column was added to an important table, but the rollover process doesn't copy this column.

4. **Structural Changes:**
   Important tables or columns were changed during the cycle, but the rollover script wasn't updated to match the new structure.

## Rollover Timeline

1. **Create new recruitment cycle** in Support
2. **Rollover providers**
3. **Verify data issues** (fix any errors found)
4. **Find is closed** (old cycle is no longer visible)
5. **Verify Publish and data issues**
6. **Next cycle becomes current**
7. **Verify Publish and data issues again**
8. **Find is open** (new cycle is visible)
9. **Verify Find and data issues**

## Testing the Rollover Process

- Set up **testing environments** for Publish and Find (at least 3GB RAM for Publish).
- Run a test rollover by following the steps above.
- Use the Support interface to create a new RecruitmentCycle for the next year.

## What to Do If Data Is Incomplete

If a provider or course fails during rollover:

1. **Check Sidekiq** for error messages.
2. If needed, investigate further:
    - Use the latest backup (see [seeding data guide](https://github.com/DFE-Digital/publish-teacher-training/blob/main/guides/setup-development.md#seeding-data))
    - Run rollover locally
    - Identify the problematic provider or course
    - Use the Rails console to debug

#### To Rollover a Provider

```ruby
provider_code = "CHANGE-HERE"
recruitment_cycle_id = RecruitmentCycle.next.id # or RecruitmentCycle.find_by(year: 'YEAR').id

RolloverProviderService.call(
  provider_code:,
  new_recruitment_cycle_id:,
  force: false,
)
```

#### To Rollover a Specific Course

```ruby
copy_courses_to_provider_service = Courses::CopyToProviderService.new(
  sites_copy_to_course: Sites::CopyToCourseService,
  enrichments_copy_to_course: Enrichments::CopyToCourseService.new,
  force: false,
)

# Find the course from current cycle that is raising error when rolling over
course =  RecruitmentCycle.current.courses.where(course_code: 'COURSE-CODE')

# Find the provider in the new cycle
new_provider = RecruitmentCycle.next.providers.where(provider_code: 'PROVIDER-CODE')

# Rollover the course and see the error
copy_courses_to_provider_service.execute(course:, new_provider:)
```

## Summary

- **Rollover** is an annual process to prepare for the new recruitment cycle.
- Follow the steps above to ensure a smooth transition.
- Use the images to guide you through the interface.
- If you encounter issues, use Sidekiq logs and the Rails console for troubleshooting.
