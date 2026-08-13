# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProviderSchools::Removal do
  subject(:removal) { described_class.new(provider:, uuid: provider_school.uuid) }

  let(:provider) { create(:provider) }

  # The pair written together when a school is added: the provider school and
  # the legacy site it shares a uuid, site code and urn with.
  let!(:site) { create(:site, provider:) }
  let!(:provider_school) { create(:provider_school, :for_site, site:) }

  # A second school, so removal is never blocked by the last-school guard. It
  # needs no legacy site of its own: the guard only counts provider schools.
  let!(:other_provider_school) { create(:provider_school, provider:) }

  describe "#call" do
    it "removes both the legacy site and provider school" do
      expect(removal.call).to be(true)

      expect(Site.where(id: site.id)).to be_empty
      expect(Provider::School.where(id: provider_school.id)).to be_empty
    end

    it "does not remove either record when the provider school is attached to a course school" do
      create(:course_school, course: create(:course, provider:), provider_school:, gias_school: provider_school.gias_school)

      expect(removal.call).to be(false)

      expect(Site.where(id: site.id)).to contain_exactly(site)
      expect(Provider::School.where(id: provider_school.id)).to contain_exactly(provider_school)
    end

    it "does not remove a legacy site that has no provider school" do
      provider_school.destroy!

      expect { described_class.new(provider:, uuid: site.uuid).call }.to raise_error(ActiveRecord::RecordNotFound)

      expect(Site.where(id: site.id)).to contain_exactly(site)
    end

    it "removes a provider school without requiring a legacy site" do
      expect(described_class.new(provider:, uuid: other_provider_school.uuid).call).to be(true)

      expect(Provider::School.where(id: other_provider_school.id)).to be_empty
    end

    it "does not remove a provider school belonging to another provider" do
      someone_elses_school = create(:provider_school)

      expect { described_class.new(provider:, uuid: someone_elses_school.uuid).call }.to raise_error(ActiveRecord::RecordNotFound)

      expect(Provider::School.where(id: someone_elses_school.id)).to contain_exactly(someone_elses_school)
    end

    context "when it is the provider's only school" do
      let!(:other_provider_school) { nil }

      it "does not remove either record" do
        expect(removal.call).to be(false)

        expect(Site.where(id: site.id)).to contain_exactly(site)
        expect(Provider::School.where(id: provider_school.id)).to contain_exactly(provider_school)
      end
    end

    # Removal deliberately does not branch on the recruitment cycle: the same
    # records are deleted in every cycle.
    context "when the provider is in a later recruitment cycle" do
      let(:provider) { create(:provider, :next_recruitment_cycle) }

      it "removes both the legacy site and provider school" do
        expect(removal.call).to be(true)

        expect(Site.where(id: site.id)).to be_empty
        expect(Provider::School.where(id: provider_school.id)).to be_empty
      end
    end
  end
end
