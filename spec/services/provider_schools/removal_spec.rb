# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProviderSchools::Removal do
  let(:gias_school) { create(:gias_school, urn: "123456") }
  let(:site_uuid) { Faker::Internet.uuid }

  describe "#call" do
    let(:provider) { create(:provider) }
    let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: site_uuid) }
    let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site_uuid) }

    it "removes both the legacy site and provider school" do
      expect(described_class.new(provider:, uuid: site_uuid).call).to be(true)

      expect(Site.where(id: site.id)).to be_empty
      expect(Provider::School.where(id: provider_school.id)).to be_empty
    end

    it "does not remove either record when the provider school is attached to a course school" do
      create(:course_school, course: create(:course, provider:), provider_school:, gias_school:)

      expect(described_class.new(provider:, uuid: site_uuid).call).to be(false)

      expect(Site.where(id: site.id)).to contain_exactly(site)
      expect(Provider::School.where(id: provider_school.id)).to contain_exactly(provider_school)
    end

    it "does not remove a legacy site that has no provider school" do
      provider_school.destroy!

      expect {
        described_class.new(provider:, uuid: site_uuid).call
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect(Site.where(id: site.id)).to contain_exactly(site)
    end

    it "removes a provider school without requiring a legacy site" do
      provider_school_without_site = create(:provider_school, provider:)

      expect(described_class.new(provider:, uuid: provider_school_without_site.uuid).call).to be(true)

      expect(Provider::School.where(id: provider_school_without_site.id)).to be_empty
    end

    it "does not remove a provider school belonging to another provider" do
      other_provider_school = create(:provider_school, uuid: Faker::Internet.uuid)

      expect {
        described_class.new(provider:, uuid: other_provider_school.uuid).call
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect(Provider::School.where(id: other_provider_school.id)).to contain_exactly(other_provider_school)
    end

    # Removal deliberately does not branch on the recruitment cycle: the same
    # records are deleted in every cycle.
    context "when the provider is in a later recruitment cycle" do
      let(:provider) { create(:provider, :next_recruitment_cycle) }

      it "removes both the legacy site and provider school" do
        expect(described_class.new(provider:, uuid: site_uuid).call).to be(true)

        expect(Site.where(id: site.id)).to be_empty
        expect(Provider::School.where(id: provider_school.id)).to be_empty
      end
    end
  end
end
