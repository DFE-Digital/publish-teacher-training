require "faker"
Faker::Config.locale = "en-GB"

CourseSubject.destroy_all
Course.destroy_all
FinancialIncentive.destroy_all
Subject.destroy_all
SubjectArea.destroy_all
Site.destroy_all
SiteStatus.destroy_all
Provider.destroy_all
User.destroy_all
AccessRequest.destroy_all
RecruitmentCycle.destroy_all

current_recruitment_year = Settings.current_recruitment_cycle_year
current_recruitment_cycle = RecruitmentCycle.create(year: current_recruitment_year, application_start_date: Date.new(current_recruitment_year.to_i - 1, 10, 9), application_end_date: Date.new(current_recruitment_year.to_i, 9, 30))
next_recruitment_cycle = RecruitmentCycle.create(year: (current_recruitment_year.to_i + 1).to_s, application_start_date: Date.new(current_recruitment_year.to_i, 10, 8), application_end_date: Date.new(current_recruitment_year.to_i + 1, 9, 30))

Subjects::SubjectAreaCreatorService.new.execute
Subjects::CreatorService.new.execute

year = 2023
Subjects::FinancialIncentiveCreatorService.new(year:).execute
Subjects::FinancialIncentiveSetSubjectKnowledgeEnhancementCourseAvailableService.new(year:).execute

superuser = User.create!(
  first_name: "Super",
  last_name: "Admin",
  accept_terms_date_utc: Time.now.utc,
  email: "super.admin@education.gov.uk", # matches authentication.rb
  state: "rolled_over",
  admin: true,
)

def create_standard_provider_and_courses_for_cycle(recruitment_cycle, superuser)
  provider = Provider.new(
    provider_name: "Acme SCITT",
    provider_code: "A01",
    provider_type: "B",
    recruitment_cycle:,
    email: Faker::Internet.email,
    telephone: Faker::PhoneNumber.phone_number,
  )
  provider.skip_geocoding = true
  provider.save!
  superuser.providers << provider

  site = Site.new(
    provider:,
    code: Faker::Number.number(digits: 1),
    location_name: Faker::Company.name,
    address1: Faker::Address.building_number,
    address2: Faker::Address.street_name,
    address3: Faker::Address.city,
    address4: Faker::Address.state,
    postcode: Faker::Address.postcode,
    urn: Faker::Number.number(digits: [5, 6].sample),
  )

  site.skip_geocoding = true
  site.save!

  primary_course = Course.create!(
    name: "Mathematics",
    course_code: "MAT2",
    provider:,
    start_date: Date.new(2019, 9, 1),
    profpost_flag: "PG",
    program_type: "SD",
    maths: 1,
    english: 9,
    science: 9,
    modular: "M",
    qualification: :pgce_with_qts,
    level: "primary",
    subjects: [
      PrimarySubject.find_by(subject_name: "Primary with mathematics"),
    ],
    study_mode: "F",
    age_range_in_years: "3_to_7",
  )

  SiteStatus.create!(
    site: Site.last,
    vac_status: "F",
    publish: "Y",
    course: primary_course,
    status: "R",
  )

  secondary_course1 = Course.create!(
    name: "Biology",
    course_code: "BIO3",
    provider:,
    start_date: Date.new(2019, 9, 1),
    profpost_flag: "BO",
    program_type: "HE",
    maths: 3,
    english: 9,
    science: nil,
    modular: "",
    qualification: :pgce,
    level: "secondary",
    subjects: [
      SecondarySubject.find_by(subject_name: "Biology"),
    ],
    study_mode: "B",
    age_range_in_years: "7_to_14",
  )

  SiteStatus.create!(
    site: Site.last,
    vac_status: "B",
    publish: "Y",
    course: secondary_course1,
    status: "N",
  )

  secondary_course2 = Course.create!(
    name: "Arts",
    course_code: "AT05",
    provider:,
    start_date: Date.new(2019, 9, 1),
    profpost_flag: "BO",
    program_type: "HE",
    maths: 3,
    english: 9,
    science: nil,
    modular: "",
    qualification: :pgce,
    level: "secondary",
    subjects: [
      SecondarySubject.find_by(subject_name: "Art and design"),
      SecondarySubject.find_by(subject_name: "Music"),
    ],
    study_mode: "B",
    age_range_in_years: "7_to_14",
  )

  SiteStatus.create!(
    site: Site.last,
    vac_status: "B",
    publish: "Y",
    course: secondary_course2,
    status: "N",
  )

  further_education_course = Course.create!(
    name: "Further Education",
    course_code: "FE11",
    provider:,
    start_date: Date.new(2019, 9, 1),
    profpost_flag: "BO",
    program_type: "HE",
    maths: 3,
    english: 9,
    science: nil,
    modular: "",
    qualification: :pgce,
    level: "Further education",
    subjects: [
      FurtherEducationSubject.find_by(subject_name: "Further education"),
    ],
    study_mode: "B",
    age_range_in_years: "7_to_14",
  )

  SiteStatus.create!(
    site: Site.last,
    vac_status: "B",
    publish: "Y",
    course: further_education_course,
    status: "N",
  )

  modern_language_course1 = Course.create!(
    name: "Other Languages",
    course_code: "OML9",
    provider:,
    start_date: Date.new(2019, 9, 1),
    profpost_flag: "BO",
    program_type: "HE",
    maths: 3,
    english: 9,
    science: nil,
    modular: "",
    qualification: :pgce,
    level: "secondary",
    subjects: [
      SecondarySubject.find_by(subject_name: "Modern Languages"),
      ModernLanguagesSubject.find_by(subject_name: "Modern languages (other)"),
    ],
    study_mode: "B",
    age_range_in_years: "7_to_14",
  )

  SiteStatus.create!(
    site: Site.last,
    vac_status: "B",
    publish: "Y",
    course: modern_language_course1,
    status: "N",
  )

  modern_language_course2 = Course.create!(
    name: "Japanese",
    course_code: "N7",
    provider:,
    start_date: Date.new(2019, 9, 1),
    profpost_flag: "BO",
    program_type: "HE",
    maths: 3,
    english: 9,
    science: nil,
    modular: "",
    qualification: :pgce,
    level: "secondary",
    subjects: [
      SecondarySubject.find_by(subject_name: "Modern Languages"),
      ModernLanguagesSubject.find_by(subject_name: "Japanese"),
    ],
    study_mode: "B",
    age_range_in_years: "7_to_14",
  )

  SiteStatus.create!(
    site: Site.last,
    vac_status: "B",
    publish: "Y",
    course: modern_language_course2,
    status: "N",
  )

  modern_language_course3 = Course.create!(
    name: "Modern Languages",
    course_code: "ML1",
    provider:,
    start_date: Date.new(2019, 9, 1),
    profpost_flag: "BO",
    program_type: "HE",
    maths: 3,
    english: 9,
    science: nil,
    modular: "",
    qualification: :pgce,
    level: "secondary",
    subjects: [
      SecondarySubject.find_by(subject_name: "Modern Languages"),
      ModernLanguagesSubject.find_by(subject_name: "Japanese"),
      ModernLanguagesSubject.find_by(subject_name: "French"),
      ModernLanguagesSubject.find_by(subject_name: "Russian"),
      ModernLanguagesSubject.find_by(subject_name: "German"),
    ],
    study_mode: "B",
    age_range_in_years: "7_to_14",
  )

  SiteStatus.create!(
    site: Site.last,
    vac_status: "B",
    publish: "Y",
    course: modern_language_course3,
    status: "N",
  )
end

create_standard_provider_and_courses_for_cycle(current_recruitment_cycle, superuser)
create_standard_provider_and_courses_for_cycle(next_recruitment_cycle, superuser)

10.times do |i|
  provider = Provider.new(
    provider_name: "ACME SCITT #{i}",
    provider_code: "A#{i}",
    provider_type: "B",
    recruitment_cycle: current_recruitment_cycle,
    email: Faker::Internet.email,
    telephone: Faker::PhoneNumber.phone_number,
  )

  provider.skip_geocoding = true
  provider.save!

  user = User.create!(
    email: Faker::Internet.unique.email,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
  )

  user.providers << provider
  superuser.providers << provider
end

access_requester_user = User.all.reject(&:admin?).sample

10.times do
  AccessRequest.create!(
    email_address: Faker::Internet.unique.email,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    requester: access_requester_user,
    requester_email: access_requester_user.email,
    request_date_utc: rand(1..20).days.ago,
    status: %i[requested completed].sample,
    reason: "No reason",
    organisation: Provider.first.provider_name,
  )
end
