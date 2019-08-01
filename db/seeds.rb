require "faker"
Faker::Config.locale = 'en-GB'

Subject.destroy_all
Course.destroy_all
Site.destroy_all
SiteStatus.destroy_all
Provider.destroy_all
Organisation.destroy_all
User.destroy_all
AccessRequest.destroy_all
RecruitmentCycle.destroy_all

current_recruitment_cycle = RecruitmentCycle.create(year: '2019', application_start_date: Date.new(2018, 10, 9))
next_recruitment_cycle = RecruitmentCycle.create(year: '2020')

{
  "Primary" => "00",
  "Secondary" => "05",
  "Chinese" => "T1",
  "English" => "Q3",
  "Mathematics" => "G1",
  "Biology" => "C1",
  "Further Education" => "41",
}.each do |name, code|
  Subject.create!(
    subject_name: name,
    subject_code: code
  )
end

superuser = User.create!(
  first_name: 'Super',
  last_name: 'Admin',
  accept_terms_date_utc: Time.now.utc,
  email: 'super.admin@education.gov.uk', # matches authentication.rb
  state: 'rolled_over'
)


def create_standard_provider_and_courses_for_cycle(recruitment_cycle, superuser)
  provider = Provider.create!(
    provider_name: 'Acme SCITT',
    provider_code: 'A01',
    recruitment_cycle: recruitment_cycle
  )
  organisation = Organisation.create!(name: "ACME SCITT Org")
  organisation.providers << provider
  superuser.organisations << organisation

  Site.create!(
    provider: provider,
    code: Faker::Number.number(digits: 1),
    location_name: Faker::Company.name,
    address1: Faker::Address.building_number,
    address2: Faker::Address.street_name,
    address3: Faker::Address.city,
    address4: Faker::Address.state,
    postcode: Faker::Address.postcode,
  )

  course1 = Course.create!(
    name: "Mathematics",
    course_code: "MAT2",
    provider: provider,
    start_date: Date.new(2019, 9, 1),
    profpost_flag: "PG",
    program_type: "SD",
    maths: 1,
    english: 9,
    science: nil,
    modular: "M",
    qualification: :pgce_with_qts,
    subjects: [
      Subject.find_by(subject_name: "Secondary"),
      Subject.find_by(subject_name: "Mathematics")
    ],
    study_mode: "F",
  )

  SiteStatus.create!(
    site: Site.last,
    vac_status: "F",
    publish: "Y",
    course: course1,
    status: "R",
    applications_accepted_from: Date.new(2018, 10, 23)
  )

  course2 = Course.create!(
    name: "Biology",
    course_code: "BIO3",
    provider: provider,
    start_date: Date.new(2019, 9, 1),
    profpost_flag: "BO",
    program_type: "HE",
    maths: 3,
    english: 9,
    science: nil,
    modular: "",
    qualification: :pgce_with_qts,
    subjects: [
      Subject.find_by(subject_name: "Secondary"),
      Subject.find_by(subject_name: "Biology"),
      Subject.find_by(subject_name: "Further Education"),
    ],
    study_mode: "B",
  )


  SiteStatus.create!(
    site: Site.last,
    vac_status: "B",
    publish: "Y",
    course: course2,
    status: "N",
    applications_accepted_from: Date.new(2018, 10, 2)
  )
end

create_standard_provider_and_courses_for_cycle(current_recruitment_cycle, superuser)
create_standard_provider_and_courses_for_cycle(next_recruitment_cycle, superuser)

10.times do |i|
  provider = Provider.create!(
    provider_name: "ACME SCITT #{i}",
    provider_code: "A#{i}",
    recruitment_cycle: current_recruitment_cycle
  )

  organisation = Organisation.create!(name: "ACME#{i}")
  organisation.providers << provider

  user = User.create!(
    email: Faker::Internet.unique.email,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name
  )

  user.organisations << organisation
  superuser.organisations << organisation
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
    status: %i[requested completed].sample
  )
end
