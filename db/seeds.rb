require "faker"
Faker::Config.locale = 'en-GB'

Subject.destroy_all
Course.destroy_all
Site.destroy_all
SiteStatus.destroy_all
Provider.destroy_all
User.destroy_all
AccessRequest.destroy_all

accrediting_provider = Provider.create!(provider_name: 'Acme SCITT', provider_code: 'A01')

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

Site.create!(
  provider: accrediting_provider,
  code: Faker::Number.unique.number(1),
  location_name: Faker::Company.name,
  address1: Faker::Address.building_number,
  address2: Faker::Address.street_name,
  address3: Faker::Address.city,
  address4: Faker::Address.state,
  postcode: Faker::Address.postcode,
)

course1 = Course.create!(
  name: "Mathematics",
  course_code: Faker::Number.unique.hexadecimal(3).upcase,
  provider: accrediting_provider,
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
  course_code: Faker::Number.unique.hexadecimal(3).upcase,
  provider: accrediting_provider,
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

PGDECourse.create!(
  provider_code: course2.provider.provider_code,
  course_code: course2.course_code,
)

SiteStatus.create!(
  site: Site.last,
  vac_status: "B",
  publish: "Y",
  course: course2,
  status: "N",
  applications_accepted_from: Date.new(2018, 10, 2)
)

provider2 = Provider.create!(provider_name: "Acme Alliance", provider_code: "A02")

Course.create!(
  name: Faker::ProgrammingLanguage.name,
  course_code: "5W2A",
  provider: provider2,
  accrediting_provider: accrediting_provider,
  qualification: :pgce_with_qts,
  subjects: [
    Subject.last
  ]
)

Course.create!(
  name: Faker::ProgrammingLanguage.name,
  course_code: "9A5Y",
  provider: Provider.create!(provider_name: 'Big Uni', provider_code: 'B01'),
  qualification: :pgce_with_qts
)

User.create!(
  first_name: 'Super',
  last_name: 'Admin',
  accept_terms_date_utc: Time.now.utc,
  email: 'super.admin@education.gov.uk', # matches authentication.rb
  state: 'transitioned'
)

10.times do |i|
  provider = Provider.create!(
    provider_name: "ACME SCITT #{i}",
    provider_code: "A#{i}"
  )

  organisation = Organisation.create!(name: "ACME#{i}")
  organisation.providers << provider

  user = User.create!(
    email: Faker::Internet.unique.email,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name
  )

  user.organisations << organisation
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
