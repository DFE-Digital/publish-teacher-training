# frozen_string_literal: true

class EmailAlertMailerPreview < ActionMailer::Preview
  def weekly_digest_few_courses
    EmailAlertMailer.weekly_digest(email_alert, build_courses(3))
  end

  def weekly_digest_many_courses
    EmailAlertMailer.weekly_digest(email_alert, build_courses(15))
  end

private

  def email_alert
    alert = Candidate::EmailAlert.instantiate(
      "id" => 0,
      "candidate_id" => 0,
      "subjects" => %w[G1 F3],
      "location_name" => "Manchester",
      "latitude" => nil,
      "longitude" => nil,
      "radius" => 50,
      "search_attributes" => { "funding" => "salary" },
      "unsubscribed_at" => nil,
      "last_sent_at" => nil,
      "filter_key_digest" => nil,
    )
    alert.association(:candidate).target = Candidate.new(email_address: "preview@example.com")
    alert
  end

  def build_courses(count)
    providers = [
      Provider.new(provider_name: "Tes Institute", provider_code: "TES1"),
      Provider.new(provider_name: "University of Manchester", provider_code: "MAN1"),
      Provider.new(provider_name: "United Teaching National SCITT", provider_code: "UTN1"),
      Provider.new(provider_name: "University of Birmingham", provider_code: "BIR1"),
      Provider.new(provider_name: "University of Leeds", provider_code: "LEE1"),
    ]

    course_names = [
      ["Mathematics", "D228"],
      ["Mathematics", "3CGN"],
      ["Physics", "F3X1"],
      ["Chemistry", "C101"],
      ["Biology", "B202"],
      ["Computer Science", "CS01"],
      ["English", "E301"],
      ["History", "H401"],
      ["Geography", "G501"],
      ["Design and Technology", "DT01"],
      ["Music", "MU01"],
      ["Art and Design", "AD01"],
      ["Physical Education", "PE01"],
      ["Religious Education", "RE01"],
      ["Modern Languages", "ML01"],
    ]

    count.times.map do |index|
      name, code = course_names[index % course_names.size]
      provider = providers[index % providers.size]

      Course.new(name:, course_code: code, provider:)
    end
  end
end
