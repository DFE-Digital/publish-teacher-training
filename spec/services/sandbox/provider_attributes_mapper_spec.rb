# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sandbox::ProviderAttributesMapper do
  subject(:attributes) { described_class.new(production).attributes }

  let(:production) { JSON.parse(file_fixture("publish_public_api/provider.json").read)["attributes"] }

  it "maps the production provider onto provider columns" do
    expect(attributes).to eq(
      "provider_code" => "1KQ",
      "provider_name" => "Wade Deacon Trust",
      "provider_type" => "lead_school",
      "ukprn" => "10007848",
      "urn" => "111435",
      "address1" => "Wade Deacon Trust ",
      "address2" => "Wade Deacon High School, Birchfield Road",
      "address3" => "",
      "town" => "Widnes",
      "address4" => "Cheshire",
      "postcode" => "WA8 7TD",
      "region_code" => "north_west",
      "latitude" => 53.3764973,
      "longitude" => -2.7351048,
      "website" => "https://www.wadedeacontrust.com/teaching-school/teacher-training-programme/",
      "telephone" => "01234 567890",
      "email" => "teacher.training@example.com",
      "can_sponsor_skilled_worker_visa" => false,
      "can_sponsor_student_visa" => false,
      "selectable_school" => true,
      "accredited" => false,
    )
  end

  # The API doesn't give the accredited provider number an accredited provider needs.
  it "is never accredited" do
    production["accredited_body"] = true

    expect(attributes["accredited"]).to be(false)
  end

  it "builds a valid provider" do
    provider = Provider.new(attributes.merge(recruitment_cycle: find_or_create(:recruitment_cycle)))

    expect(provider).to be_valid
  end
end
