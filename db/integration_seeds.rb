require_relative "../spec/strategies/find_or_create_strategy"
Faker::Config.locale = "en-GB"

module IntegrationSeeds
  class << self
    def call
      organisation_id = "000"
      organisation = FactoryBot.find_or_create(
        :organisation,
        name: "Test Organisation",
        org_id: organisation_id,
      )

      test_user = create_user(
        email: "becomingateacher+integration-tests@digital.education.gov.uk",
        first_name: "integration",
        last_name: "tests",
        state: "transitioned",
      )
      add_user_to_organisation test_user, organisation

      admin_user = create_user(
        email: "becomingateacher+admin-integration-tests@digital.education.gov.uk",
        first_name: "admin",
        last_name: "admin",
        state: "transitioned",
        admin: true,
      )
      add_user_to_organisation admin_user, organisation

      provider_code = "0AA"
      provider = current_recruitment_cycle.providers.find_by(provider_code: provider_code)
      if provider.blank?
        provider = FactoryBot.find_or_create(
          :provider,
          :accredited_body,
          recruitment_cycle: current_recruitment_cycle,
          organisations: [organisation],
          provider_code: provider_code,
          provider_name: "Integrated Testing School #{provider_code}",

          # We don't need the address, yet, but this may be the right pattern to
          # follow. If you search for this address in Google Maps it seems to locate
          # the DfE building, which would be nice and predictable.
          # address1: "#{provider_code} DfE",
          # address2: "#{provider_code} Great Smith St",
          # address3: "#{provider_code} Westminster",
          # address4: "#{provider_code} London",
          # postcode: "SW1 #{provider_code}",
          # region_code: "london",

          # Not needed, but good to bear in mind that we have the email address
          # becomingateacher+integration-tests@digital.education.gov.uk so the
          # following pattern shoud work:
          # email: "becomingateacher+integration-tests+#{provider_code}@digital.education.gov.uk",

          train_with_us: "Train With Us #{provider_code}",
          train_with_disability: "Train With Disability #{provider_code}",
         )
      end

      location_code = "-"
      site = provider.sites.find_by(code: "-")
      if site.nil?
        site = FactoryBot.find_or_create(
          :site,
          provider: provider,
          code: location_code,
          location_name: "Main Site",
          address1: "#{provider_code} DfE",
          address2: "#{provider_code} Great Smith St",
          address3: "#{provider_code} Westminster",
          address4: "#{provider_code} London",
          postcode: "SW1 #{provider_code}",
          region_code: "london",
        )
      end

      course_code = "0AAA"
      course = provider.courses.find_by(course_code: course_code)
      if course.blank?
        subject_computing = Subject::SecondarySubject.find_by(subject_code: "11")
        course = FactoryBot.find_or_create(
          :course,
          :secondary,
          course_code: course_code,
          provider: provider,
          name: "Integrated Testing Course #{course_code}",
          age_range_in_years: "7_to_11",
          level: :secondary,
          subjects: [subject_computing],
        )
      end

      course.sites << site unless site.in? course.sites
    end

  private

    def add_user_to_organisation(user, organisation)
      organisation.users << user unless user.in? organisation.users
    end

    def current_recruitment_cycle
      RecruitmentCycle.current_recruitment_cycle
    end

    def create_user(attributes)
      User.find_by(attributes) || FactoryBot.create(:user, attributes)
    end
  end
end
