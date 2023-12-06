# Support Playbook

## Removing an organisation

To remove an organisation, you can `discard` it:

```ruby
RecruitmentCycle.current.providers.find_by(provider_code: "1JJ").discard
```

If the organisation has running courses, you will get a validation error. In this scenario you just need to make sure there aren't any users attached to it.

## Unpublishing a published course

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

## Changing accredited provider of courses

To change the accrediting provider of a course, you can do the following:

```ruby
# Grab the courses for a provider and update the courses' accredited provider
p = RecruitmentCycle.current.providers.find_by(provider_code: "1YP")
p.courses.update(accredited_provider_code: "1YK")
```

## Transfer courses to another provider

```ruby
# This can be run and tested in QA before actioning in production

# Find the provider
provider = RecruitmentCycle.current.providers.find_by(provider_code: "XXX")

# Find the target provider to receive the above providers courses
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

```bash
$ /usr/local/bin/bundle exec rails rollover:provider[provider_code,'course_code1 course_code2',true]
```

## Copying courses from one provider to another

### Copying a single course

```ruby
# Find provider to copy courses from
provider_to_copy_to = RecruitmentCycle.current.providers.find_by(provider_code: "7K9")


# Initialize the CopyToProviderService and assign to a variable
copier = Courses::CopyToProviderService.new(sites_copy_to_course: Sites::CopyToCourseService.new, enrichments_copy_to_course: Enrichments::CopyToCourseService.new, force: true)

# Assign the course you want to copy to a variable
course = RecruitmentCycle.current.providers.find_by(provider_code: "1TZ").courses.find_by(course_code: "2KG4")

# Execute the service with the correct course and provider
copier.execute(course:, new_provider: provider_to_copy_to)
````

### Copy some courses

```ruby
# Fill in these variables with appropriate information

# Provider from which the courses will be copied
provider_code = <put source provider code here>

# Provider to whom the course will be copied
provider_codes = %w[<put provider codes here>]

# The courses to be copied
course_codes = %w[<put course codes here]

# Uncomment if it is different from the original course
# accrediting_provider = <put accrediting provider code here>

# Should the course sites be copied over too?
copy_sites_too = <true | false>

## ---- END OF INPUT ---- ##

# Then paste this into the console

sites_copy_to_course = copy_sites_too ? proc {} : Sites::CopyToCourseService.new
defined?(accrediting_provider) || accrediting_provider = nil

source_provider = RecruitmentCycle.current.providers.find_by(provider_code:)
courses = source_provider.courses.where(course_code: course_codes)
target_providers = RecruitmentCycle.current.providers.where(provider_code: provider_codes)

copier = Courses::CopyToProviderService.new(sites_copy_to_course: , enrichments_copy_to_course: Enrichments::CopyToCourseService.new, force: true)

courses.each do |course|
  target_providers.each do |new_provider|
    copier.execute(course:, new_provider:).tap |course|
      course.update(accrediting_provider:) if accrediting_provider
    end
  end
end
````


### Copying all courses

The example below copies scheduled courses during rollover from one provider to another. It may need tweaking depending on the scenario but the structure and format of what to run should help.

```ruby
# Find provider to copy courses from
provider = RecruitmentCycle.current.next.providers.find_by(provider_code: "1TZ")

# Find the target provider to copy courses to
provider_to_copy_to = RecruitmentCycle.current.next.providers.find_by(provider_code: "2A6")

copier = Courses::CopyToProviderService.new(sites_copy_to_course: Sites::CopyToCourseService.new, enrichments_copy_to_course: Enrichments::CopyToCourseService.new, force: true)

# Handles edge case where .published returns withdrawn
provider.courses.published.filter { |c| c.content_status != :withdrawn }.each do |course|
  new_course = copier.execute(course:, new_provider: provider_to_copy_to)

  # Set the accredited provider if needed
  new_course.update(accredited_provider_code: "2N2")
end
```

## Visa sponsorship issue

If providers encounter an error message 'Select if visas can be sponsored' when publishing a course after correctly filling the visa option on basic details page, they need to have the provider sponsorship attributes updated from nil, as we are validating on the provider rather than the course at present.

```ruby
# Find provider to update
provider = RecruitmentCycle.current.providers.find_by(provider_code: "1TZ")

provider.update(can_sponsor_skilled_worker_visa: true, can_sponsor_student_visa: true)
```
