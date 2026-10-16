# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProviderSchools::CheckForm do
  subject(:form) { described_class.new(provider:, gias_school:) }

  let(:provider) { create(:provider) }
  let(:gias_school) { create(:gias_school, address1: "1 School Lane", postcode: "LS1 1AA") }

  it { is_expected.to be_valid }

  it "is invalid when the provider already has the school" do
    create(:provider_school, provider:, gias_school:)

    expect(form).not_to be_valid
    expect(form.errors[:gias_school]).to include("This school has already been added")
  end

  it "is valid when another provider has the school" do
    create(:provider_school, gias_school:)

    expect(form).to be_valid
  end

  it "is invalid when the school's address is incomplete" do
    gias_school.update!(address1: "", address2: "", address3: "", town: "")

    expect(form).not_to be_valid
    expect(form.errors[:gias_school]).to include(
      "The address we hold for this school is incomplete. Ask the school to update its details on Get Information About Schools (GIAS).",
    )
  end
end
