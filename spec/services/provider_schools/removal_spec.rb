# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProviderSchools::Removal do
  let(:remodel_cycle_year) { 2026 }
  let(:gias_school) { create(:gias_school, urn: "123456") }
  let(:site_uuid) { "11111111-1111-4111-8111-111111111111" }
  let(:provider_school_uuid) { "22222222-2222-4222-8222-222222222222" }

  before do
    allow(Settings).to receive(:schools_remodel_cycle_year).and_return(remodel_cycle_year)
  end

  describe "#call" do
    context "when the provider is in the schools remodel cycle" do
      let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: site_uuid) }
      let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: site.code) }

      it "removes both the legacy site and provider school" do
        described_class.new(provider:, uuid: site.uuid).call

        expect(Site.where(id: site.id)).to be_empty
        expect(Provider::School.where(id: provider_school.id)).to be_empty
      end
    end

    context "when the provider is after the schools remodel cycle" do
      let(:recruitment_cycle) { create(:recruitment_cycle, year: remodel_cycle_year + 1) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: site_uuid) }
      let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: provider_school_uuid) }

      it "removes only the provider school" do
        described_class.new(provider:, uuid: provider_school.uuid).call

        expect(Site.where(id: site.id)).to contain_exactly(site)
        expect(Provider::School.where(id: provider_school.id)).to be_empty
      end

      it "does not remove provider schools that are attached to courses" do
        create(:course_school, course: create(:course, provider:), provider_school:, gias_school:)

        expect {
          described_class.new(provider:, uuid: provider_school.uuid).call
        }.to raise_error(described_class::CannotRemoveSchoolError)

        expect(Site.where(id: site.id)).to contain_exactly(site)
        expect(Provider::School.where(id: provider_school.id)).to contain_exactly(provider_school)
      end
    end
  end
end
