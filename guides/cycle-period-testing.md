# Cycle period testing

Find and Publish behave differently at different points in the recruitment year.
The application works out where it is in that year by reading the clock, so a
test that does not control the clock asserts something different depending on
the date it runs.

The suite therefore pins the clock for every example. Specs that care about a
period say so with `travel:`; everything else runs at a fixed default. Nothing
is left to the calendar.

This guide explains how the periods work, what the default is and when to
override it, and which failures the default cannot protect you from.

For the operational process of moving data into a new cycle, see
[Rollover](rollover.md). This guide is only about time in tests.

## Contents

- [The cycle timetable](#the-cycle-timetable), the dates and which cycle an
  instant belongs to
- [The periods](#the-periods), the five predicates and how they overlap
- [Two clocks](#two-clocks), the real one and the cycle switcher
- [What changes when the period changes](#what-changes-when-the-period-changes)
- [Latent test failures, and what the default does about
  them](#latent-test-failures-and-what-the-default-does-about-them)
- [Pinning the clock in specs](#pinning-the-clock-in-specs), `travel:` metadata,
  the hooks, precedence, recruitment cycle records
- [Traps](#traps)
- [Choosing an instant](#choosing-an-instant), and when to name a year
- [Testing the closed period](#testing-the-closed-period)
- [Open questions](#open-questions), work still to do:
  - [You cannot run the whole suite at a different
    time](#you-cannot-run-the-whole-suite-at-a-different-time)
  - [Audit how the specs control the
    cycle](#audit-how-the-specs-control-the-cycle)
  - [When to build data in a named cycle
    year](#when-to-build-data-in-a-named-cycle-year)
  - [A scheduled run for the next cycle](#a-scheduled-run-for-the-next-cycle)
- [Maintenance](#maintenance), adding next cycle's dates
- [Checklist](#checklist)

If you are here because a spec broke and you do not know why, start with
[Traps](#traps).

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
cycle's Find opens, so roughly nine hours a year.

> [!WARNING]
> Its brevity is what makes it dangerous. A spec that breaks in the closed
> period passes every time you run it locally and fails once, in CI, on a date
> nobody associates with the change they just made.

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

## Latent test failures, and what the default does about them

A spec running at an uncontrolled clock is not asserting "this behaviour". It is
asserting "this behaviour, given whatever period the machine happened to be in".

That is a latent failure, not a passing test. When it eventually fails, nothing
has regressed. The spec was never testing what it claimed, and it happened to be
run in the period where the claim held.

**The default removes the period as a variable.** Any example that sets no
`travel:` runs at `CycleTimetableHelpers.default_travel`, which is
`Find::CycleTimetable.mid_cycle`: the ordinary state, with Find open, Apply
open, no banners and the deadline not passed. Holding an irrelevant variable
constant is what a test should do, and most specs have no business caring which
cycle period it is.

### It moves the signal to the author

The default does not throw that information away. It moves it to the moment it
is cheapest to act on.

Write a spec during a period that is not mid-cycle, asserting on what you can
see the app doing today, and it fails immediately: on your branch, seconds after
you wrote it, with the context still in your head. You add `travel:`, it passes,
and the period dependence is now stated in the spec instead of implied by the
calendar. Without the default the same spec passes today and fails eleven months
later on somebody else's unrelated branch.

That prompt fires in one direction only. It catches a spec written in a period
that needs pinning. It says nothing to somebody working mid-cycle, which is most
of the year, who writes period-dependent production code: their spec passes, and
the other branch is simply untested. Covering the other periods is a deliberate
act. Nothing will remind you.

### The default pins the period, not the year

`mid_cycle` resolves through `current_year`, which reads the real clock. So the
default holds the period constant and lets the cycle year float:

```
real 2026-09-14   current_year 2026   default 2025-11-30 09:00   cycle 2026
real 2026-09-28   current_year 2026   default 2025-11-30 09:00   cycle 2026
real 2026-09-29   current_year 2027   default 2026-11-29 09:00   cycle 2027
```

The clock still moves once a year, in a single jump, on the day Find opens for
the next cycle. On that morning every unpinned spec that assumed the old year
fails at once, on whichever branch happens to be running. The usual causes are a
bare `create(:course)` landing in a year the spec did not expect, an assertion
naming a literal year, and behaviour gated on a year such as a route constraint.

This is a real annual event with a known date, so pre-empt it rather than
discover it. Ahead of the rollover, pin the specs that name a year and check the
code paths gated on one.

Keeping the default relative is deliberate. A fixed instant would never move,
but it would need updating every year, it would eventually fall off the end of
`CYCLE_DATES`, and no spec would ever exercise a rollover at all.

> [!IMPORTANT]
> The table still runs out. `cycle_year_for_time` raises
> `NoRecruitmentCycleExists` for any instant outside every entry in
> `CYCLE_DATES`. After the last entry's `find_closes`, `current_year` raises and
> effectively the whole suite fails until the next year is added. See
> [Maintenance](#maintenance).

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

The helpers are:

| Helper | Takes a year |
| --- | --- |
| `find_opens` | yes |
| `apply_opens` | yes |
| `mid_cycle` | yes |
| `apply_deadline` | yes |
| `find_closes` | yes |
| `find_reopens` | no |
| `first_deadline_banner` | no |

`find_reopens` is `find_opens(next_year)`, so it already resolves against the
travelled clock and takes no year of its own.

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
  time = example.metadata[:travel] || CycleTimetableHelpers.default_travel

  Timecop.travel(time) do
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

> [!IMPORTANT]
> Use `find_or_create(:recruitment_cycle)`, never `create(:recruitment_cycle)`.
> Two records for the same year cause confusing 404s, because lookups find the
> wrong one.

The `:provider` factory already uses
`association :recruitment_cycle, strategy: :find_or_create` for this reason.

The factory's default year is `Find::CycleTimetable.current_year`, so under a
pinned clock it builds a cycle for the pinned year without you saying so.

Traits `:previous` and `:next` give you the neighbouring cycles.

A cycle is created for every example anyway: `spec/support/reference_data.rb`
runs `find_or_create :recruitment_cycle` in a `before`, which is inside the
travelled clock, so it lands in the year the example is pinned to. Disable it
with the `no_default_recycle: true` tag.

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

**Timetable instants are Europe/London, not UTC.** `CYCLE_DATES` is built with
`Time.zone.local`, so for most of the cycle the instants are BST, an hour ahead
of UTC. `find_opens` for the 2026 cycle is `09:00` local but prints as `08:00`
under `to_fs(:db)`, which formats UTC. A spec that asserts on a formatted
timestamp, or compares against a UTC literal, can pass in midwinter and fail in
June. Assert against the helper rather than a literal.

**`mid_cycle?` does not mean mid cycle.** `Find::CycleTimetable.mid_cycle?` maps
to `today_is_after_find_opens`, which spans almost the entire cycle.

**`find_reopens(2027)` raises.** The helper module generates the same
signature for every name, so it passes the year through, but
`Find::CycleTimetable.find_reopens` takes no argument. The call raises
`ArgumentError`. `first_deadline_banner` behaves the same way.

**`apply_closes` does not exist.** `CycleTimetableHelpers` generates a helper
for it, but `Find::CycleTimetable` has no such method, so calling it raises
`NoMethodError`. Nothing uses it.

**`preview_mode?` is defined but unused.** It is `apply_deadline` to
`find_closes`. Do not assume it drives behaviour.

**`travel: find_closes` puts you in the next cycle, not at the end of the
current one**, and a bare `create(:course)` during the closed period builds data
in the cycle that has not opened yet. Both are covered in
[Testing the closed period](#testing-the-closed-period).

**`before(:all)` runs outside the travelled clock.** The travel is an
`around(:each)` hook, so it wraps `before(:each)`, `let!` and the example body,
but `before(:all)` has already run by then:

```
before(:all)                    sees the real date
before(:each), let!, example    sees the pinned date
```

Records built in `before(:all)` are therefore stamped months away from
everything else in the example. No spec file in this repo uses it, and the only
`before(:all)` is the subjects hook in `spec/support/reference_data.rb`, which
has no cycle dependency. Build cycle-dependent data in `before`, `let` or `let!`
instead.

## Choosing an instant

- Set nothing when the spec just needs the service open and ordinary. The
  `mid_cycle` default already gives you that, so an explicit `travel: mid_cycle`
  adds noise without changing behaviour.
- Pin to a boundary only when the boundary is the behaviour under test.

### Leave the year off

Write `travel: mid_cycle`, not `travel: mid_cycle(2026)`. A helper with no year
resolves through `Find::CycleTimetable.current_year`, so the spec moves to the
new cycle on its own and nobody has to edit it later.

A year in the metadata has two costs. The spec keeps testing a cycle that
candidates and providers have left, so it stops describing what the service does
now. And a person must revisit it when that cycle is too old to be worth
testing.

Give a year only in these cases:

- The spec is about a cycle in the past.
- The spec is about the next cycle, before that cycle starts.
- The spec asserts a literal year or a literal date.

Do not mix the two. A spec that pins no year but asserts a literal year passes
today and fails at the next rollover. If an expected value contains a date,
derive it from the same helper the spec travels to.

## Testing the closed period

The closed period belongs to the **next** cycle, not the one that just ended.
That has a consequence for data setup which is easy to miss.

`current_year` rolls at midnight, but Find does not open until 09:00, so for
those nine hours the new cycle is already current while Find is still down:

| Instant | Wall clock | `current_year` | `previous_year` | `find_down?` |
| --- | --- | --- | --- | --- |
| `find_closes - 1.hour` | 2026-09-28 23:00 | 2026 | 2025 | false |
| midnight | 2026-09-29 00:00 | 2027 | 2026 | true |
| `find_reopens - 1.hour` | 2026-09-29 08:00 | 2027 | 2026 | true |
| `find_reopens` | 2026-09-29 09:00 | 2027 | 2026 | false |

The `:recruitment_cycle` factory defaults its year to
`Find::CycleTimetable.current_year`, and the `:provider` factory associates a
cycle with `find_or_create`. So inside the closed window a bare
`create(:course)` builds a provider and a course in the cycle that **has not
opened yet**.

> [!WARNING]
> That is almost never what the spec means. A closed-period spec is about the
> courses candidates could see until yesterday, and those belong to the cycle
> that just ended.

### Do not build the data first and then travel

One instinct is to create the courses at the current time and then move the
clock forward. That does not work with `travel:` metadata, because the around
hook wraps the whole example including `before` blocks and `let!`, so the data
is built under the travelled clock regardless.

It also reintroduces the problem this guide exists to solve. "Create at the real
time, then travel" only lands the data in the previous cycle if the real clock
happens to sit in that cycle, which is exactly the calendar dependency you are
removing.

### Travel, then create in the previous cycle explicitly

Pin the clock, then say which cycle the data belongs to. `previous_year`
resolves against the travelled clock, so it names the cycle that just closed
without hardcoding a year:

```ruby
RSpec.describe "Find during the closed period", travel: find_reopens - 1.hour do
  let(:provider) { create(:provider, :previous_recruitment_cycle) }
  let(:course) { create(:course, provider:) }
  # ...
end
```

The `:previous_recruitment_cycle` trait on the provider factory already does
`find_or_create :recruitment_cycle, :previous`, which resolves to
`Find::CycleTimetable.previous_year`. There is no need to build the cycle by
hand, and no year is hardcoded.

### `travel: find_closes` does not mean the end of the cycle

`find_closes` is built with `end_of_day`, so it is one nanosecond before
midnight, and the hooks use `Timecop.travel` rather than `Timecop.freeze`. Time
starts flowing from that instant, so within microseconds the example is past
midnight and into the next cycle:

```
find_closes raw:   2026-09-28 23:59:59.999999999
Timecop.freeze     2026-09-28 23:59:59.999999999   current_year=2026  find_down?=false
Timecop.travel     2026-09-29 00:00:00.010179423   current_year=2027  find_down?=true
```

So `travel: find_closes` is in practice `travel: find_down`. To test the last
moments of a cycle, give yourself real headroom with an offset such as
`travel: 1.hour.before(find_closes)`. The same applies to any `end_of_day`
boundary.

## Open questions

The sections below are not settled practice. They record work that is still to
do, and the reasoning behind it, so the next person does not have to derive it
again.

### You cannot run the whole suite at a different time

We want to run the suite as if the date were in the next cycle. That finds the
specs the next rollover will break, weeks before the rollover, on a normal
working day.

There is no way to do this now.

One option we explored was to make the default instant configurable per run, so
a single command could move every unpinned example to another point in the
cycle. We chose the fixed `mid_cycle` default instead. It gives every example a
known period without anybody having to set anything, which is what makes an
unpinned spec trustworthy on a laptop and in CI alike. A configurable default
does not replace that, and it is only worth adding on top of it.

If somebody does add one, it must hold to these rules:

- It changes the default instant only. An example with `travel:` keeps its own.
- It takes a position in the cycle and a year, for example the mid cycle of the
  next year. A position alone is the half that matters least, because the
  rollover failures are year failures.
- Unset, the suite runs at the ordinary `mid_cycle` default.
- Every parallel worker uses the same instant.

> [!NOTE]
> Nobody has built it. Do not write a spec that depends on it.

### Audit how the specs control the cycle

Two faults are spread through the suite. Both are worth correcting.

**Fault 1: a spec names a year it does not need.** The counts on the day this
was written:

| Condition | Count |
| --- | --- |
| Lines with `travel:` | 156 |
| Of those, lines naming a year | 85 |
| Spec files with `travel:` | 83 |

Counting each year where it appears: 2025 thirty times, 2026 twenty-seven times,
2027 twenty-six times, 2024 three times and 2022 once.

This command lists them:

```
grep -rn "travel: " spec/ --include=*.rb | grep -E "\(20[0-9]{2}\)"
```

For each one, ask a single question. Does the spec fail if the cycle year
changes? If it does not, take the year out. Keep it only for the cases in
[Leave the year off](#leave-the-year-off).

Look for the opposite fault too. A spec can pin no year and still assert a
literal one. It passes today and fails at the next rollover. To find one, look
for a four-digit year in the expected values of a spec that pins nothing.

**Fault 2: a spec stubs a timetable method instead of moving the clock.**

```ruby
allow(Find::CycleTimetable).to receive(:current_year).and_return(2026)
allow(Time.zone).to receive(:now).and_return(Time.zone.local(2026, 6, 15))
allow(RecruitmentCycle).to receive(:current).and_return(cycle)
```

A stub is worse than `travel:` for three reasons:

- It changes one method. Everything else still reads the real clock, so the spec
  can build a state that cannot occur in production. A stub on `Time.zone.today`
  leaves `Time.zone.now` alone.
- The `before` hook creates no recruitment cycle record for it. The hook reads
  `travel:` metadata and nothing else.
- It hides the period. `mid_cycle` names a position in the cycle. `2026` names
  nothing.

The counts on the day this was written, 18 lines across 9 spec files:

| Stub | Lines |
| --- | --- |
| `allow(Find::CycleTimetable)` | 10 |
| `allow(RecruitmentCycle)` | 6 |
| `allow(Time.zone)` | 2 |

The methods are `current_year` seven times, then `now`, `mid_cycle?` and
`find_by` twice each, and `current`, `current_recruitment_cycle`,
`previous_year`, `create` and `upcoming_cycles_open_to_publish?` once each.

This command lists them:

```
grep -rnE "allow\(Find::CycleTimetable\)|allow\(Time\.zone\)|allow\(RecruitmentCycle\)" spec/ --include=*.rb
```

Replace a stub with `travel:` where the spec only needs a different instant.
Keep it where the spec needs a state the timetable cannot produce.

### When to build data in a named cycle year

A spec can control the cycle in two ways, and they do different jobs:

1. Move the clock with `travel:`. The factories then build data in the cycle the
   clock is in.
2. Create a recruitment cycle for a named year, and hang a provider and a course
   off that record.

The clock controls the date the application believes. `current_year`,
`find_down?`, the banners and the Apply button all read it, and way 2 changes
none of them. The records control what is in the database, and way 1 gives you
one cycle where way 2 gives you as many as you need.

So a spec that uses way 2 alone can build a state that cannot occur. The
database holds a course in cycle 2027 while the application believes the year is
2026, `RecruitmentCycle.current` returns a different record from the one the
spec created, and the failure names none of that.

Way 2 is still necessary for some specs. A rollover spec needs two cycles at
once, and one clock cannot be in two cycles. The `:previous` and `:next` traits
exist for that.

This rule is a proposal, not yet agreed:

- Use `travel:` when the behaviour under test reads the clock.
- Use a named year when the spec needs more than one cycle, or when it touches
  the records only.
- Do not name a year for the single cycle the spec is about. Let the clock and
  the factory defaults agree.

Note one limit either way. `find_or_create(:recruitment_cycle, year: X)` fails
if X is not in `CYCLE_DATES`. The factory calls
`Find::CycleTimetable.apply_opens(X)`, `real_schedule_for` returns nil, and
`fetch` on nil raises `NoMethodError`.

### A scheduled run for the next cycle

Add a scheduled workflow that runs the suite at the next cycle, once there is a
way to move the default instant for a whole run.

The cycle rolls on one morning a year, and every spec that assumed the old year
fails together, on the branch of somebody who did not cause it. A scheduled run
moves that discovery to a normal working day some weeks earlier.

`.github/workflows/build-nocache.yml` is the pattern to copy. It already uses
`schedule: cron`.

The new workflow should:

- Run weekly. This information changes slowly, so do not run it per pull
  request.
- Move the default instant to the mid cycle of the next year.
- Report a failure to the team without blocking a deployment. A failure here
  warns about the future. It is not a fault in the code being merged.

Leave the `rails-tests` job in `.github/workflows/build-and-deploy.yml` alone.
It must run at the default instant, the same as a local run, so that a green
build means the same thing in both places. Surveying the suite at another
instant belongs in the scheduled workflow, not in a temporary override of the
job every pull request depends on.

## Maintenance

When the policy team confirms next cycle's dates, add an entry to `CYCLE_DATES`.
Until you do, the suite has a hard expiry: `cycle_year_for_time` raises for any
instant past the last entry's `find_closes`.

After adding a year, check specs that pin a literal year. They keep testing the
year they name, which may be correct or may now be stale.

Separately, the day Find opens for a new cycle moves the default's year for
every unpinned spec, so it is a scheduled suite-wide event rather than a
surprise. See
[The default pins the period, not the year](#the-default-pins-the-period-not-the-year),
and [A scheduled run for the next cycle](#a-scheduled-run-for-the-next-cycle)
for the proposal to find those failures in advance.

## Checklist

Before merging a spec:

- Does it render a Find page, assert on Apply, show a banner, or name a cycle
  year? If so it must pin the clock.
- Is it using `travel:` metadata rather than `Timecop` in a `before` block or a
  stub on a timetable method?
- Is it using a relative helper rather than a literal date?
- Does the metadata name a year? Take the year out, unless the spec must use
  that one cycle.
- Does an expected value contain a literal year or date? Derive it from the same
  helper.
- Is it using `find_or_create(:recruitment_cycle)` rather than `create`?
