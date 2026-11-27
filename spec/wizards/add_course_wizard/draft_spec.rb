# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Draft, type: :wizard do
  subject(:draft) { described_class.new(wizard:) }

  include_context "add_course_wizard"

  let(:current_step) { :check_answers }

  describe "records" do
    it "returns ordered subject records" do
      first = find_or_create(:secondary_subject, :physics)
      second = find_or_create(:secondary_subject, :business_studies)
      state_store.write(level: "secondary", secondary_master_subject_id: first.id.to_s, subordinate_subject_id: second.id.to_s)

      expect(draft.subjects.map(&:id)).to eq([first.id, second.id])
    end

    it "keeps every stored uuid but resolves only the provider's own schools" do
      school_one = create(:site, :with_provider_school, provider:)
      school_two = create(:site, :with_provider_school, provider:)
      other_providers_school = create(:site, :with_provider_school, provider: create(:provider))
      state_store.write(school_uuids: [school_two.uuid, school_one.uuid, other_providers_school.uuid])

      expect(draft.selected_school_uuids).to eq([school_two.uuid, school_one.uuid, other_providers_school.uuid])
      expect(draft.schools.map(&:uuid)).to eq([school_two.uuid, school_one.uuid])
    end

    it "returns ordered school records" do
      school_one = create(:site, :with_provider_school, provider:)
      school_two = create(:site, :with_provider_school, provider:)
      state_store.write(school_uuids: [school_two.uuid, school_one.uuid])

      expect(draft.selected_school_uuids).to eq([school_two.uuid, school_one.uuid])
      expect(draft.schools.map(&:uuid)).to eq([school_two.uuid, school_one.uuid])
    end

    it "logs the unrecognised uuids rather than dropping them silently" do
      school = create(:site, :with_provider_school, provider:)
      unrecognised_uuid = SecureRandom.uuid
      state_store.write(school_uuids: [school.uuid, unrecognised_uuid])

      expect(Rails.logger).to receive(:warn).with(/#{unrecognised_uuid}/)

      expect(draft.schools.map(&:uuid)).to eq([school.uuid])
    end

    # The review page reads both, so they can disagree: state still holds the
    # selection while nothing resolves behind it.
    it "still reports the stored uuid when no school resolves behind it" do
      allow(Rails.logger).to receive(:warn)
      unrecognised_uuid = SecureRandom.uuid
      state_store.write(school_uuids: [unrecognised_uuid])

      expect(draft.selected_school_uuids).to eq([unrecognised_uuid])
      expect(draft.schools).to eq([])
    end

    # Removing a school destroys its Provider::School rather than discarding it,
    # so that is what the draft has to survive between choosing and reviewing.
    it "drops a school removed after it was chosen" do
      allow(Rails.logger).to receive(:warn)
      school = create(:site, :with_provider_school, provider:)
      state_store.write(school_uuids: [school.uuid])

      provider.schools.find_by(uuid: school.uuid).destroy!

      expect(draft.selected_school_uuids).to eq([school.uuid])
      expect(draft.schools).to eq([])
    end

    it "returns ordered study sites" do
      first = provider.study_sites.first || create(:site, :study_site, provider:)
      second = create(:site, :study_site, provider:)
      state_store.write(study_sites_ids: [second.id.to_s, first.id.to_s])

      expect(draft.study_sites.map(&:id)).to eq([second.id, first.id])
    end

    it "returns no study sites when the question was not answered" do
      state_store.write(study_sites_ids: nil)

      expect(draft.study_sites).to eq([])
    end

    it "delegates accrediting_provider and resolves accreditation provider name" do
      accrediting_provider = instance_double(Provider)
      allow(wizard).to receive(:accrediting_provider).and_return(accrediting_provider)
      state_store.write(accredited_provider_code: provider.provider_code)

      expect(draft.accrediting_provider).to eq(accrediting_provider)
      expect(draft.accreditation_provider_name).to eq(provider.provider_name)
    end
  end
end
