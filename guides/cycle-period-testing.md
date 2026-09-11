# Cycle period testing

Find and Publish behave differently at different points in the recruitment year.
The application works out where it is in that year by reading the clock. A test
that does not control the clock therefore inherits whatever period the machine
was in when the suite ran, and asserts something different depending on the
date.

This guide explains how the periods work, why an unpinned spec is a latent
failure rather than a passing test, and every mechanism the suite gives you to
control the period.

For the operational process of moving data into a new cycle, see
[Rollover](rollover.md). This guide is only about time in tests.

## The cycle timetable

### The table

`Find::CycleTimetable::CYCLE_DATES` (`app/services/find/cycle_timetable.rb`) is a
hardcoded table with one entry per recruitment cycle year. Each entry holds
named instants:

| Key | Meaning |
| --- | --- |
| `find_opens` | Find starts serving the new cycle's courses |
| `apply_opens` | Candidates can submit applications |
| `first_deadline_banner` | The apply deadline banner starts showing |
| `apply_deadline` | Last moment to apply in this cycle |
| `find_closes` | End of the cycle, the evening before Find reopens |
| `apply_1_deadline` | Historic, present only for 2021 to 2023 |

The dates are real and confirmed with the policy team, so they are not evenly
spaced and they are not derivable. They have to be added by hand each year.

Each key has a reader on `Find::CycleTimetable` that takes an optional year and
defaults to the current one, for example `find_opens(2026)` or `apply_deadline`.

`first_deadline_banner` is the exception: it takes no year argument and always
resolves against the current cycle. `apply_1_deadline` has no reader at all.

### Which cycle a moment belongs to

`cycle_year_for_time` maps an instant to a cycle year. A cycle runs from
`find_opens.beginning_of_day` up to the next cycle's `find_opens.beginning_of_day`.

Note the `beginning_of_day`. The cycle year rolls over at midnight, but Find
does not open until 09:00. That gap is the closed period, described below.

`current_year` is `cycle_year_for_time(Time.zone.now)`, adjusted by the cycle
switcher. `next_year` and `previous_year` are derived from it.

## The periods

### The five predicates

`phases_in_time` returns five booleans, each computed from `Time.zone.now`:

| Predicate | Window |
| --- | --- |
| `now_is_before_find_opens` | `find_opens.beginning_of_day` to `find_opens` |
| `today_is_after_find_opens` | `find_opens` to `apply_deadline` |
| `today_is_between_find_opening_and_apply_opening` | `find_opens` to `apply_opens` |
| `today_is_mid_cycle` | `first_deadline_banner` to `apply_deadline` |
| `today_is_after_apply_deadline_passed` | `apply_deadline` to `find_closes` |

The public predicates on `Find::CycleTimetable` read these:

| Method | Predicate |
| --- | --- |
| `find_down?` | `now_is_before_find_opens` |
| `find_open?` | the negation of `now_is_before_find_opens` |
| `mid_cycle?` | `today_is_after_find_opens` |
| `show_apply_deadline_banner?` | `today_is_mid_cycle` |
| `apply_deadline_passed` | `today_is_after_apply_deadline_passed` |
| `show_cycle_closed_banner?` | `today_is_after_apply_deadline_passed` and not `today_is_between_find_opening_and_apply_opening` |
| `show_apply_opens_soon_banner?` | `today_is_between_find_opening_and_apply_opening` |

### They overlap

This is the part that catches people out. The five predicates are not mutually
exclusive states in a state machine. They are five independent range checks over
the same timeline, and several are true at once.

`today_is_between_find_opening_and_apply_opening` is entirely contained within
`today_is_after_find_opens`. So is `today_is_mid_cycle`.

Do not ask "which period am I in". Ask "which of these predicates is true at
this instant".

### Worked example: the 2026 cycle

| Instant | Date |
| --- | --- |
| `find_opens` | 2025-09-30 09:00 |
| `apply_opens` | 2025-10-07 09:00 |
| `first_deadline_banner` | 2026-07-12 09:00 |
| `apply_deadline` | 2026-09-15 18:00 |
| `find_closes` | 2026-09-28 end of day |
| `find_opens` for 2027 | 2026-09-29 09:00 |

Which gives these windows:

```
2025-09-30 00:00  ─┐
                   │  Find closed (now_is_before_find_opens), 9 hours
2025-09-30 09:00  ─┤
                   │  Find open, Apply not yet open
2025-10-07 09:00  ─┤
                   │  Find open, Apply open, no banner
2026-07-12 09:00  ─┤
                   │  Apply deadline banner showing
2026-09-15 18:00  ─┤
                   │  Apply deadline passed, cycle closed banner
2026-09-28 23:59  ─┤
                   │  Find closed for the 2027 cycle, 9 hours
2026-09-29 09:00  ─┘  2027 cycle opens
```

The closed period is short. It runs from midnight to 09:00 on the day the new
cycle's Find opens, so roughly nine hours a year. That is what makes it
dangerous: a spec that breaks in it will pass every time you run it locally and
fail once, in CI, on a date nobody associates with the change they just made.

## Two clocks

`phase_in_time?` does not always read the clock:

```ruby
def self.phase_in_time?(time_period)
  if current_cycle_schedule == :real
    phases_in_time[time_period]
  else
    current_cycle_schedule == time_period
  end
end
```

`current_cycle_schedule` returns `:real` in production. Everywhere else it
returns `SiteSetting.cycle_schedule`, which support users can set through the
cycle switcher at `/cycles` on the Find host to force a period regardless of the
date.

In the test environment `SiteSetting.cycle_schedule` returns `:real` unless
`ENABLE_SWITCHER` is set, so tests read the real (or Timecop'd) clock. Set
`ENABLE_SWITCHER` only when the switcher itself is what you are testing.

## What changes when the period changes

Ranked by how much of the application it affects.

**The whole Find service.** `Find::ApplicationController` runs
`redirect_to_cycle_has_ended_if_find_is_down`, which sends every Find page to
`/cycle-has-ended` while `find_down?` is true
(`app/controllers/find/application_controller.rb:45`). During the closed period,
no Find page renders anything a spec expects. Only
`Find::PagesController#cycle_has_ended` skips the filter.

**Applying.** The Apply button and the "not accepting applications" wording are
gated on the period in `CourseDecorator#saved_status_tag`
(`app/decorators/course_decorator.rb:47`), `Find::Courses::ApplyComponent`,
`app/views/find/courses/show.html.erb` and
`app/views/publish/courses/preview.html.erb`.

**Banners.** `Find::DeadlineBannerComponent` picks between the apply deadline
banner, the cycle closed banner and nothing at all.

**Which data is current.** `current_year` moves, so `RecruitmentCycle.current`,
`RecruitmentCycle#current_and_open?` and the `:recruitment_cycle` factory
default all resolve to a different year.

## Latent test failures

A spec that does not pin the clock is not asserting "this behaviour". It is
asserting "this behaviour, given whatever period the machine happened to be in".

That is a latent failure, not a passing test. When it eventually fails, nothing
has regressed. The spec was never testing what it claimed, and it happened to
run in the period where the claim held.

Two things follow.

**Green on main is not evidence.** The suite passing today tells you nothing
about whether it passes on 29 September.

**The table runs out.** `cycle_year_for_time` raises
`NoRecruitmentCycleExists` for any instant outside every entry in `CYCLE_DATES`.
The last entry is 2027, whose `find_closes` is 2027-10-04. After that date,
`current_year` raises and effectively the entire suite fails until a 2028 entry
is added.

## Pinning the clock in specs

### `travel:` metadata

The house style. Put `travel:` on a `describe`, `context`, `it` or `scenario`,
and use the readers from `CycleTimetableHelpers`
(`spec/support/cycle_timetable_helpers.rb`), which are available both inside
examples and in metadata position:

```ruby
RSpec.describe "Publishing courses", travel: mid_cycle(2026) do
  scenario "a provider publishes a course" do
    # ...
  end
end
```

The helpers are `find_opens`, `apply_opens`, `mid_cycle`, `apply_deadline`,
`find_closes`, `find_reopens` and `first_deadline_banner`. All except
`first_deadline_banner` take an optional year.

Offsets work, and are the right tool for boundary behaviour:

```ruby
context "when the cycle has ended", travel: 1.day.before(find_closes) do
it "shows the banner", travel: apply_deadline(2025) + 1.hour do
```

### How the hooks work

Two hooks in `spec/rails_helper.rb` implement it:

```ruby
config.before do |example|
  if (time = example.metadata[:travel])
    year = Find::CycleTimetable.cycle_year_for_time(time)
    find_or_create(:recruitment_cycle, year:)
  end
end

config.around do |example|
  if (time = example.metadata[:travel] || CycleTimetableHelpers.env_cycle_period)
    Timecop.travel(time) do
      example.run
    end
  else
    example.run
  end
ensure
  Timecop.return
end
```

The `around` hook moves the clock. The `before` hook makes sure a
`RecruitmentCycle` record exists for the year that instant falls in, so you do
not have to create one by hand.

### Precedence

`example.metadata` already contains the group's metadata, merged down through
every enclosing group, with the example's own value winning. So a single read of
`example.metadata[:travel]` gives you:

- an `it`-level `travel:` wins over its group's
- a group's `travel:` applies to every example in it that sets none
- an inner group's wins over an outer group's

Do not reach for `self.class.metadata[:travel]`. That holds group metadata only,
so combining the two inverts the precedence and silently discards `it`-level
values.

### Timecop directly

`Timecop.travel` and `Timecop.freeze` are still available and are the right
choice when you need to move time *within* an example, or freeze it so a
timestamp assertion is stable:

```ruby
it "records when the school was removed" do
  Timecop.freeze do
    service.call
    expect(course.reload.updated_at).to eq(Time.zone.now)
  end
end
```

Prefer `travel:` metadata when you are pinning the whole example. It is
declarative, it creates the recruitment cycle for you, and `Timecop.return` is
handled by the hook rather than being your responsibility.

### Recruitment cycle records

Use `find_or_create(:recruitment_cycle)`, never `create(:recruitment_cycle)`.
Two records for the same year cause confusing 404s, because lookups find the
wrong one. The `:provider` factory already uses
`association :recruitment_cycle, strategy: :find_or_create` for this reason.

The factory's default year is `Find::CycleTimetable.current_year`, so under a
pinned clock it builds a cycle for the pinned year without you saying so.

Traits `:previous` and `:next` give you the neighbouring cycles.

## Traps

**`mid_cycle` is not `today_is_mid_cycle`.** The helper `mid_cycle` is
`find_opens + 2.months`. The predicate `today_is_mid_cycle` runs from
`first_deadline_banner` to `apply_deadline`, which is the end of the cycle, not
the middle. At the instant `mid_cycle` returns, `today_is_mid_cycle` is false.

What `mid_cycle` actually gives you is the ordinary state: Find open, Apply
open, no banners, deadline not passed. That is why most specs use it, and it is
usually the right default. Just do not read the name as naming the predicate.

**`travel:` values are evaluated at file load, under the real clock.** A bare
`travel: mid_cycle` means "mid cycle of whichever year the suite booted in", not
of a fixed year. That is normally what you want, because it keeps working next
cycle. It does mean that a spec combining a bare helper with a hardcoded year in
its assertions will break when the cycle rolls.

**`mid_cycle?` does not mean mid cycle.** `Find::CycleTimetable.mid_cycle?` maps
to `today_is_after_find_opens`, which spans almost the entire cycle.

**`apply_closes` does not exist.** `CycleTimetableHelpers` generates a helper
for it, but `Find::CycleTimetable` has no such method, so calling it raises
`NoMethodError`. Nothing uses it.

**`preview_mode?` is defined but unused.** It is `apply_deadline` to
`find_closes`. Do not assume it drives behaviour.

## Choosing an instant

- Default to `mid_cycle` when the spec just needs the service open and ordinary.
- Pin to a boundary only when the boundary is the behaviour under test.
- Leave the year off unless the spec genuinely depends on that cycle, so it
  keeps working next year.
- Add a year when the spec's data or assertions name one, for example a course
  in the 2026 cycle or a feature gated to a specific year.

## Auditing the suite with `CYCLE_PERIOD`

`CYCLE_PERIOD` forces every example that sets no `travel:` of its own into one
period. Specs that set `travel:` keep their own instant, because they test a
period deliberately and moving them would corrupt the result.

```bash
CYCLE_PERIOD=find_closed bundle exec parallel_rspec -n 8
```

Anything that fails is a spec that silently depends on the period. Fix it by
pinning it with `travel:`, or, if the closed-period behaviour is worth covering,
by writing a spec for it.

The available periods are defined in `CycleTimetableHelpers::CYCLE_PERIODS`:

| Value | Instant |
| --- | --- |
| `find_closed` | one hour before Find reopens, so `find_down?` is true |
| `mid_cycle` | the ordinary middle of the cycle |
| `find_opens` | one hour after Find opens |
| `apply_opens` | one hour after Apply opens |
| `apply_deadline_passed` | one hour after the apply deadline |
| `find_closes` | one hour before the cycle ends |

They are relative to the current cycle rather than hardcoded dates, so they stay
correct as cycles roll over. An unknown value raises and lists the valid ones.
With `CYCLE_PERIOD` unset, the suite behaves exactly as it always has.

Note that the hook only moves the clock. It does not create a `RecruitmentCycle`
for the period, deliberately, so that a failure is attributable to the clock
alone rather than to the clock plus an injected record.

Run this against the periods the suite does not otherwise exercise, rather than
waiting for the calendar to find them for you.

## Maintenance

When the policy team confirms next cycle's dates, add an entry to `CYCLE_DATES`.
Until you do, the suite has a hard expiry: `cycle_year_for_time` raises for any
instant past the last entry's `find_closes`.

After adding a year, check specs that pin a literal year. They keep testing the
year they name, which may be correct or may now be stale.

## Checklist

Before merging a spec:

- Does it render a Find page, assert on Apply, show a banner, or name a cycle
  year? If so it must pin the clock.
- Is it using `travel:` metadata rather than `Timecop` in a `before` block?
- Is it using a relative helper rather than a literal date?
- Is it using `find_or_create(:recruitment_cycle)` rather than `create`?
- If it pins a literal year, does it actually depend on that year?
