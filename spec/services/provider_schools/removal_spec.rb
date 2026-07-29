# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProviderSchools::Removal do
  let(:remodel_cycle_year) { 2026 }
  let(:gias_school) { create(:gias_school, urn: "123456") }
  let(:site_uuid) { Faker::Internet.uuid }
  let(:provider_school_uuid) { Faker::Internet.uuid }

  before do
    allow(Settings).to receive(:schools_remodel_cycle_year).and_return(remodel_cycle_year)
  end

  describe "#call" do
    context "when the provider is before the schools remodel cycle" do
      let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year - 1) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:site) { create(:site, provider:, uuid: site_uuid) }

      it "removes the legacy site" do
        expect(described_class.new(provider:, uuid: site.uuid).call).to be(true)

        expect(Site.where(id: site.id)).to be_empty
      end
    end

    context "when the provider is in the schools remodel cycle" do
      let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: site_uuid) }
      let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site_uuid) }

      it "removes both the legacy site and provider school" do
        expect(described_class.new(provider:, uuid: site.uuid).call).to be(true)

        expect(Site.where(id: site.id)).to be_empty
        expect(Provider::School.where(id: provider_school.id)).to be_empty
      end

      it "does not remove either record when the provider school is attached to a course school" do
        create(:course_school, course: create(:course, provider:), provider_school:, gias_school:)

        expect(described_class.new(provider:, uuid: site.uuid).call).to be(false)

        expect(Site.where(id: site.id)).to contain_exactly(site)
        expect(Provider::School.where(id: provider_school.id)).to contain_exactly(provider_school)
      end

      it "removes the legacy site when a matching provider school does not exist" do
        provider_school.destroy!

        expect(described_class.new(provider:, uuid: site.uuid).call).to be(true)

        expect(Site.where(id: site.id)).to be_empty
      end
    end

    context "when the provider is after the schools remodel cycle" do
      let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year + 1) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: site_uuid) }
      let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: provider_school_uuid) }

      it "removes only the provider school" do
        expect(described_class.new(provider:, uuid: provider_school.uuid).call).to be(true)

        expect(Site.where(id: site.id)).to contain_exactly(site)
        expect(Provider::School.where(id: provider_school.id)).to be_empty
      end

      it "removes a provider school without requiring a legacy site" do
        provider_school_without_site = create(:provider_school, provider:)

        expect(described_class.new(provider:, uuid: provider_school_without_site.uuid).call).to be(true)

        expect(Provider::School.where(id: provider_school_without_site.id)).to be_empty
      end

      it "does not remove provider schools that are attached to courses" do
        create(:course_school, course: create(:course, provider:), provider_school:, gias_school:)

        expect(described_class.new(provider:, uuid: provider_school.uuid).call).to be(false)

        expect(Site.where(id: site.id)).to contain_exactly(site)
        expect(Provider::School.where(id: provider_school.id)).to contain_exactly(provider_school)
      end

      it "does not remove a provider school belonging to another provider" do
        other_provider_school = create(:provider_school, uuid: Faker::Internet.uuid)

        expect {
          described_class.new(provider:, uuid: other_provider_school.uuid).call
        }.to raise_error(ActiveRecord::RecordNotFound)

        expect(Provider::School.where(id: other_provider_school.id)).to contain_exactly(other_provider_school)
      end
    end
  end
end
