Support Playbook
================

## Removing an organisation

To remove an organisation, you can `discard` it:

```ruby
RecruitmentCycle.current.providers.find_by(provider_code: "1JJ").discard
```

If the org has running courses, you will get a validation error. In this scenario you just need to make sure there aren't any users attached to it.

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

## Changing course to a different type (eg to salaried)

Change `program_type` to the preferred value on the course record.

## Changing provider to a different type (eg scitt to sd)

Change `provider_type` to the preferred value on the provider record.


## Changing accredited body of courses

To change the accrediting body of a course, you can do the following:

```ruby
# Grab the courses for a provider and update the courses' accredited body
p = RecruitmentCycle.current.providers.find_by(provider_code: "1YP")
p.courses.update(accredited_body_code: "1YK")
```

## Adding a user to a provider

When doing this, you should check if the user already exists in prod. When testing locally, you'll likely be working with a sanitised database dump.

```ruby
user = User.find(email: "jon@email.com")

# Find the provider
provider = RecruitmentCycle.current.providers.find_by(provider_code: "2E1")

user.providers << provider
```
