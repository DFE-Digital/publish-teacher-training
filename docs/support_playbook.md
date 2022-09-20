Support Playbook
================

## Removing an organisation

To remove an organisation, you can `discard` it:

```ruby
RecruitmentCycle.current.providers.find_by(provider_code: "1JJ").discard
```

If the organisation has running courses, you will get a validation error. In this scenario you just need to make sure there aren't any users attached to it.

## Republishing a withdrawn course

To republish a course which has been withdrawn:

```ruby
# Find the course by code or urn
course = RecruitmentCycle.current.providers.find_by(provider_code: "138459").courses.find_by(course_code: "3C2F")

course.enrichments.max_by(&:created_at).update(status: "published", last_published_timestamp_utc: Time.now.utc)

course.site_statuses.each do |site_status|
  site_status.update(vac_status: :no_vacancies, status: :running)
end
```

## Unpubblishing a published course

Sometimes providers will accidentally publish a course and would like to unpublish it.

```ruby
course = RecruitmentCycle.current.providers.find_by(provider_code: "B72").courses.find_by(course_code: "V1X1")
course.enrichments.max_by(&:created_at).update(status: "draft", last_published_timestamp_utc: nil)

course.site_statuses.each do |site_status|
  site_status.update(vac_status: :full_time_vacancies, status: :new_status, publish: :unpublished)
end
```

## Changing course to a different type (eg to salaried)

Change `program_type` to the preferred value on the course record.

```ruby
course = RecruitmentCycle.current.providers.find_by(provider_code: "2A5").courses.find_by(course_code: "P843")
course.update(program_type: :school_direct_salaried_training_programme)
# Don't forget to clear out values for other fields
course.enrichments.max_by(&:created_at).update(fee_details: nil, fee_uk_eu: nil, fee_international: nil, financial_support: nil)
```

## Changing provider to a different type (eg scitt to sd)

Change `provider_type` to the preferred value on the provider record.

## Changing accredited body of courses

To change the accrediting body of a course, you can do the following:

```ruby
# Grab the courses for a provider and update the courses' accredited body
p = RecruitmentCycle.current.providers.find_by(provider_code: "1YP")
p.courses.update(accredited_body_code: "1YK")
```
## Transfer courses to another provider

```ruby
# This can be run and tested in QA before actioning in production

# Find the provider
provider = RecruitmentCycle.current.providers.find_by(provider_code: "XXX")

# Find the target provider to recieve the above providers courses
transfer_to_provider = RecruitmentCycle.current.providers.find_by(provider_code: "YYY")

# Move the courses to the target provider, after this action provider.courses.count = 0
transfer_to_provider.courses << provider.courses
```

## Adding a user to a provider

When doing this, you should check if the user already exists in prod. When testing locally, you'll likely be working with a sanitised database dump.

```ruby
user = User.find_by(email: "jon@email.com")

# Find the provider
provider = RecruitmentCycle.current.providers.find_by(provider_code: "2E1")

# Use the user association service to link the two as it also deals with notifications
UserAssociationsService::Create.call(user: user, provider: provider)
```

## Manually rolling over courses

Sometimes a provider will need specific courses to be rolled over by support e.g. when they've not run courses in the current cycle, but want to use courses that did get rolled over from the previous cycle.

You'll need to run the `rollover:provider` rake task, and to do this you need the provider code and the course codes for the rolling-over courses.

When in the appropriate environment, run the following from the command line in the `app` directory:

```
$ /usr/local/bin/bundle exec rails rollover:provider[provider_code,'course_code1 course_code2',true]