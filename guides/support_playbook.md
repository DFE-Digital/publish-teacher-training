# Support Playbook

### Adding a new admin user (DfE colleague)

Admin users have access to all providers by default.

- Navigate to the add user page on support in the environment you want to add the user to, eg:

  `recruitment_cycle_year = RecruitmentCycle.current.year`

  https://qa.publish-teacher-training-courses.service.gov.uk/support/{recruitment_cycle_year}/users/new

- Fill in the details and submit the form.

- Use the search box on the left hand side of the page to find the user.

- Click on the user, tick the "Admin" checkbox and click update.



## Removing an organisation

To remove an organisation, you can `discard` it:

```ruby
RecruitmentCycle.current.providers.find_by(provider_code: "1JJ").discard
```

If the organisation has running courses, you will get a validation error. In this scenario you just need to make sure there aren't any users attached to it.

## Publishing a course from an old recruitment cycle


Use the Rake task for publishing courses [PublishCourse Rake Task](../lib/tasks/publish_course.rake) 

Get the uuid of the course you want to publish and choose a user (your own user ideally) to publish.


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


## Changing a Teacher Degree Apprenticeship (TDA) Course to a Non TDA Course

**If the course has had applications, policy input is required**

When a request is made to change a TDA course to a non TDA course, it's important to note that default settings are applied when TDA courses are created (see `assign_tda_attributes_service.rb`). As a result, the provider will need to select new options, as they haven't previously had the opportunity to choose these options.

### Courses in `Draft` or `Rolled Over` State
If the course is in a `draft` or `rolled_over` state, the provider can change the qualification themselves. This process will guide them through the relevant questions.

### Courses Previously Published
If the course has already been published, the provider should be asked to **withdraw the course** and create a new one. If they are dissatisfied with this solution, request the following course details:

- **Qualification:**
  - QTS with PGCE
  - PGDE with QTS
  - QTS

- **Funding Type:**
  - Fee - no salary
  - Salary
  - Teaching apprenticeship - with salary

- **Study Pattern:**
  - Full time
  - Part time

- **Visa Sponsorship:**
  - Can they sponsor Skilled Worker visas (for salaried courses)? 
  - Can they sponsor student visas (for fee-paying courses)?

  - Yes
  - No

We should then update the course details, change the `program_type` to `teacher_degree_apprenticeship`, and reset the A-level fields to `nil` (as these fields are only applicable for TDA courses).



## Changing a Non TDA Course to a Teacher Degree Apprenticeship (TDA) Course

**If the course has had applications, policy input is required**

When a request is made to change a non TDA course to a Teacher Degree Apprenticeship (TDA) course, several defaults must be applied, as TDA courses have specific requirements and attributes (see `assign_tda_attributes_service.rb`).

### Courses in Draft or Rolled Over State
If the course is in a `draft` or `rolled_over` state, the provider can change the qualification themselves. This process will set the relevant defaults for the user.

### Courses Previously Published
If the course has already been published, ask the provider to **withdraw the course** and create a new TDA course, with the correct qualification. If they are unhappy with this solution, we should change the course back to **draft** for them. This will allow the provider to update the course themselves, as they will need to input A-level information before being able to publish the course.


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
# (pass: `sites_copy_to_course: ->(a){}` if you do not want to copy the sites in the operation.)
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
provider = RecruitmentCycle.current.providers.find_by(provider_code: "1TZ")

# Find the target provider to copy courses to
provider_to_copy_to = RecruitmentCycle.current.providers.find_by(provider_code: "2A6")

copier = Courses::CopyToProviderService.new(sites_copy_to_course: Sites::CopyToCourseService.new, enrichments_copy_to_course: Enrichments::CopyToCourseService.new, force: true)

# Handles edge case where .published returns withdrawn
provider.courses.published.filter { |c| c.content_status != :withdrawn }.each do |course|
  new_course = copier.execute(course:, new_provider: provider_to_copy_to)

  # Set the accredited provider if needed
  new_course.update(accredited_provider_code: "2N2")
end
```
