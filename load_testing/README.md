# Find & Publish Teacher Training - Load Testing

Comprehensive and scalable load testing suite for **Find** & (future) Publish Teacher Training services using [k6](https://grafana.com/products/k6/).

## Setup

**Install k6:**

*macOS*
```
  brew install k6
```

*Linux (Debian/Ubuntu)*

```
  sudo apt install k6
```

No other setup is necessary. Each run takes its target and its scenario from the
command line.

## Environments

Set with `--env ENVIRONMENT=`:

| Name | Target |
| --- | --- |
| `local` | `http://find.localhost` |
| `qa` | `https://qa.find-teacher-training-courses.service.gov.uk` |
| `staging` | `https://staging.find-teacher-training-courses.service.gov.uk` |

`staging` is the default.

***

## The recruitment cycle and the course data

Find shows different pages in each part of the recruitment cycle. It also shows
a different set of courses. Both change what a load test measures, so set them
before you run one.

### Why the real clock is a problem

A cycle ends after the apply deadline. Find then closes applications and shows a
closed cycle notice on every course page. Find also closes for about nine hours
before it opens for the next cycle, and the moment it opens is the busiest
moment of the year.

Providers publish most of their courses in the weeks before Find opens. A
database restore from that period holds very few published courses for the next
cycle. A load test against those courses measures a small catalogue, and the
result does not tell you how the service behaves at the busy moment.

### Set the cycle phase

A Redis key named `cycle_schedule` holds the phase. Set it to
`today_is_after_find_opens`. In that phase Find is open, applications are open
and Find serves the next cycle.

```
redis-cli set cycle_schedule today_is_after_find_opens
redis-cli get cycle_schedule
```

These are the values the switcher accepts:

- `real`, which uses the true dates
- `today_is_after_find_opens`, where Find and apply are both open
- `today_is_mid_cycle`
- `today_is_between_find_opening_and_apply_opening`, where apply is not yet open
- `today_is_after_apply_deadline_passed`, where the cycle is closed

**The key is shared.** One value applies to everything on that environment.
Write down the old value before you change it, and put it back when you finish.

### Publish enough courses

Rollover copies courses into the next cycle, but it leaves them unpublished.
Find does not show an unpublished course. Use the rake task to publish them:

```
rake 'load_test:publish_cycle[2027,10000]'
```

The first argument is the cycle year. The second is the number of published
courses you want. The task stops when the cycle reaches that number, so you can
run it again without harm. Leave the second argument out to publish every course
that is ready.

The task uses `Courses::PublishService`, which is the same code a provider uses.
It stops the emails that a publish normally sends. It counts the courses that
fail validation and prints the total at the end.

The task does not run in production.

***

## Services

### Find Service

Every npm script runs `k6 run`, which generates the load from the machine you
run it on. There is no hosted runner and no CI job, so a test needs a machine
with a route to the target.

#### Local runs against a development machine

A local run needs three things: the application on port 3001, a cycle phase
where Find serves courses, and enough published courses. The section above
covers the phase and the courses. This section covers the application.

`./bin/dev` uses `Procfile.dev` by default, which starts the Rails server on
port 3001 and also starts Caddy. If you keep your own `Procfile.local`, then
`bin/dev` uses that file instead, so check that something in it serves port
3001.

The load test does not go through Caddy, and does not need its certificate.
Find only answers on the host `find.localhost`, so k6 resolves that name to
`127.0.0.1:3001` itself. A Caddy that fails to start does not stop a load test.

```
npm run find:dev:quick     # 10 users, 25 seconds
npm run find:dev:baseline
npm run find:dev:peak
npm run find:dev:stress
```

#### Runs against staging

The target is staging, but the load still comes from your own machine.

```
npm run find:quick
npm run find:baseline
npm run find:peak
npm run find:stress
npm run find:all           # baseline, then peak, then stress
```

***

## Test Scenarios

### Quick Test
- **Users**: 10 concurrent
- **Duration**: 25 seconds
- **Purpose**: Confirm the suite and its content checks still work

### Baseline Test
- **Users**: 80 concurrent
- **Duration**: 14 minutes
- **Purpose**: Normal operations validation
- **Target RPS**: 5-10 sustained

### Peak Surge Test
- **Users**: 200 concurrent at peak
- **Duration**: 15 minutes
- **Purpose**: "Find opens" event (45k requests in 5 minutes)
- **Target RPS**: 150 sustained

### Stress Test
- **Users**: 400 concurrent
- **Duration**: 25 minutes
- **Purpose**: Breaking point identification
- **Target RPS**: 200+ sustained

***

## User Journeys

Every iteration picks one of three branches at random. A branch runs one or more
journeys, and each journey makes one or more requests. The chances come from
production analytics.

| Branch | Chance | Journeys it runs | Requests |
| --- | --- | --- | --- |
| Search | 51% | Search and Filter, then Pagination | 13 |
| Course | 42% | Course Detail | 4 |
| Full | 7% | Homepage, Search and Filter, Course Detail | 8 |

The chance column shows how often the test picks a branch. It does not show the
share of the load, because each branch makes a different number of requests. An
average iteration makes about 8.9 requests:

- about 7.8 results pages, which is 88% of the load
- about 1.0 course pages
- about 0.07 homepages

The suite loads no apply page. Find sends `/course/:provider_code/:course_code/apply`
to the Apply service, so a candidate leaves Find at that point.

### What each journey requests

Every search adds `utm_source=load_test` and `utm_medium=k6_testing`. Every
search also takes a random subject from a list of 16, and a random place from a
list of 10, so two iterations rarely ask for the same thing.

**Homepage** makes one request:

- `GET /`, and checks for "Find teacher training courses" and "Search"

**Search and Filter** makes three searches:

- Basic: `/results?subjects[]=<subject>&location=<place>&radius=50`. It checks
  the result count, the panel heading "Filter results", and the words "Age
  group".
- Multi-Filter: the same as Basic, plus `study_types[]=full_time` and
  `order=course_name_ascending`. It checks the result count and "Remove filter".
- Advanced: the same as Basic, plus `qualifications[]=pgce`,
  `qualifications[]=pgde`, `funding_types[]=salary` and
  `funding_types[]=bursary`. It checks the result count and "Remove filter".

**Course Detail** makes four requests:

- `GET /results?subjects[]=13`. It then reads the `/course/` links from that page
  and loads one of the first three at random. It checks "Course summary" and
  "Entry requirements".
- `GET /results?subjects[]=G1`. It then loads the first course link. It records
  the time under the name Apply Journey, but the page it loads is a course page.

**Pagination** makes ten requests:

- `GET /results?page=1` through to `/results?page=10`, and checks the result
  count on each one

### Think time

Each journey sleeps between requests, for 1 to 3 seconds. Each iteration ends
with a sleep of 2 to 5 seconds. This time counts towards the iteration duration,
so an iteration lasts much longer than the requests inside it.

***

## Key Metrics

- **Response Time**: <3s for 95% of requests
- **Error Rate**: <1% during normal load
- **Throughput**: 150 RPS during peaks
- **Availability**: 99.9% uptime target
- **Empty searches**: <25% for each search

`find_empty_results` counts the searches that return no courses. A single empty
search is normal, because a subject and a place do not always have a course. A
search that is almost always empty means the journey measures an empty page, and
that breaks the threshold for the search which caused it.

***

## Output

k6 prints the results in the terminal. Each run also writes
`find-load-test-summary.json` and `find-load-test-report.html` to the directory
you started it from. Both files are ignored by git.

Keep the files if you want to compare two runs. A run does not keep a history,
because nothing collects the results after the run stops.

***

## How to report a run

### Choose the scenario to report

The four scenarios answer four different questions:

- `quick` tests the suite. It is not a result. Do not report it.
- `baseline` shows the health of the service at a normal load.
- `peak` shows the behaviour at the busy moment. Report this one first.
- `stress` shows the point where the service breaks. Report it on its own,
  because a failed threshold is the expected result.

Start `quick` first, then `baseline`, then `peak`. Start `stress` only when a
person asks for the limit of the service.

### Keep the files from each run

Each run writes the same two file names:

- `find-load-test-summary.json`
- `find-load-test-report.html`

A second run replaces the files from the first run. `npm run find:all` starts
three runs, so only the files from the stress run stay. Give the files a new
name after each run:

```
npm run find:baseline && mv find-load-test-report.html baseline-$(date +%F).html
npm run find:peak     && mv find-load-test-report.html peak-$(date +%F).html
```

### Write down the state of the environment

The same code gives very different results in different parts of the cycle.
Record three things before each run:

- the target environment
- the value of `cycle_schedule`
- the number of findable courses in the cycle that Find serves

Tell the other people who use the environment before you start a peak run or a
stress run.

### Say where the load came from

k6 makes the load on the machine you start it from. A laptop and a home network
reach their limit before the service does.

Each request receives about 135 kB, because a results page is large. A peak run
makes 110 to 190 requests each second, so it needs 120 to 200 Mbit/s.

If your line is slower than that, the run measures your laptop. Report the
numbers as a minimum for the service, not as a measurement of it.

To find out which side reached its limit, compare the parts of
`http_req_duration`:

- `http_req_waiting` is the time the server needs to answer. A high value is a
  result about the service.
- `http_req_blocked`, `http_req_connecting` and `http_req_tls_handshaking` are
  times on your own machine. A high value is a limit of your laptop.

### Send this

Attach the HTML report. Put a short summary in the message:

```
Find load test: <scenario>
Run:        <date and time>, from <a laptop / a pod in the cluster>
Target:     <environment>
Phase:      cycle_schedule = <value>
Catalogue:  <count> findable courses in cycle <year>

Thresholds: <n> of 6 passed
  http_req_failed          <rate>   < 1%
  find_error_rate          <rate>   < 1%
  http_req_duration p(95)  <ms>     < 3000ms
  find_empty_results       <three rates>   < 25% each

Load made:  <requests/s>, <requests>, <iterations>
Checks:     <passed> of <total> passed

Caveat: one laptop made the load, so this is a minimum for the
service, not a measurement of it.
```

The threshold list is the decision. k6 gives an error code when a threshold
fails, so a reader does not need to judge the other numbers.

Report the load you made as well as the response times. If you ask for 200
users and the run makes only 60 requests each second, the report must say
whether the service was slow or the laptop was full.
