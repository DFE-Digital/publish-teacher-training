# frozen_string_literal: true

FactoryBot.define do
  factory :course_enrichment do
    course
    status { :draft }
    about_course { Faker::Lorem.sentence }
    course_length do
      # samples taken from real data
      [
        "OneYear",  # These are actual keys used on the fe
        "TwoYears", # These are actual keys used on the fe
        "36 weeks",
        "38 weeks",
        "1 year Full-time or 2 years Part-time",
        "Sept  - End July",
        "4 school terms",
        "9 months",
        "1 Year for Full Time / Up to 2 Years",
        "4 academic terms",
        "9 Months",
        "1 year plus ",
        "Other",
        "10 Months",
        "This programme is offered as a one year full-time programme or as a two year part-time programme.  The P/T programme is typically 3 days a week.",
        "September 2019- December 2020",
        "September to June",
        "Approximately 15 months",
        "1 year and 1 day minimum",
        "Academic Year"
      ].sample
    end
    fee_details do
      [
        "This apprenticeship programme is funded via the apprentice levy from eligible schools.",
        "You will not have to pay these fees upfront. Eligible UK and EU students can apply for a tuition fee loan to cover the cost of tuition fees from the government.",
        "Student grants are available to eligible applicants.",
        "Fees are made payable to the University."
      ].sample
    end
    fee_uk_eu         { Faker::Number.within(range: 0..100_000).to_i }
    fee_international { Faker::Number.within(range: 0..100_000).to_i }
    financial_support do
      [
        "Please get in contact with the school for any further details.",
        "The course is Non-Salaried only.",
        "Find out more about the financial support available within our [financial information section](http://localhost:5000/about/financial_support)",
        "Bursaries and scholarships are available to trainees",
        "You may be eligible for a government bursary if you are applying to teach one of our secondary subjects",
        "DfE bursaries are available for select trainees",
        "You can find information about tuition fee loans and other financial help on the Gov.uk website - (https://www.gov.uk/student-finance)"
      ].sample
    end
    how_school_placements_work { Faker::Lorem.sentence }
    interview_process { Faker::Lorem.sentence }
    other_requirements { Faker::Lorem.sentence }
    personal_qualities { Faker::Lorem.sentence }
    required_qualifications { Faker::Educator.degree }
    # Technically, salary_details should align with whether the course is
    # salaried or not. Maybe worth implementing this somehow at some point.
    salary_details do
      [
        "Trainees should expcet to be paid as an Unqualified Teacher.",
        "For more information on salary please contact us",
        "Salary negotiable.",
        "Applicants will be paid as an unqualified teacher.",
        "The trainee will be paid and taxed as an unqualified teacher.",
        "Using the unqualified teachers scale"
      ].sample
    end

    trait :rolled_over do
      status { :rolled_over }
    end

    trait :initial_draft do
      last_published_timestamp_utc { nil }
    end

    trait :published do
      status { :published }
      last_published_timestamp_utc { 5.days.ago }
    end

    trait :withdrawn do
      status { :withdrawn }
      last_published_timestamp_utc { 5.days.ago }
    end

    trait :subsequent_draft do
      status { :draft }
      last_published_timestamp_utc { 5.days.ago }
    end

    trait :without_content do
      fee_uk_eu { nil }
      about_course { nil }
      required_qualifications { nil }
      how_school_placements_work { nil }
      salary_details { nil }
      course_length { nil }
    end

    trait :with_fee_based_course do
      course { create(:course, :fee_type_based) }
    end

    trait :with_salary_based_course do
      course { create(:course, :salary_type_based) }
    end
  end
end
