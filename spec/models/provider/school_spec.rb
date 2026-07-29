# frozen_string_literal: true

require "rails_helper"

describe Provider::School do
  subject(:provider_school) { build(:provider_school) }

  describe "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:gias_school) }
    it { is_expected.to have_many(:course_schools).class_name("Course::School").dependent(:destroy) }
  end

  describe ".with_available_gias_school" do
    it "excludes provider schools whose GIAS record is closed" do
      available = create(:provider_school, gias_school: create(:gias_school, :open))
      create(:provider_school, gias_school: create(:gias_school, :closed))

      expect(described_class.with_available_gias_school).to contain_exactly(available)
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:site_code) }

    it "creates a valid record" do
      expect(provider_school).to be_valid
    end

    context "with the same gias_school and site_code for one provider" do
      let(:existing) { create(:provider_school) }
      let(:duplicate) do
        build(
          :provider_school,
          provider: existing.provider,
          gias_school: existing.gias_school,
          site_code: existing.site_code,
        )
      end

      it "is invalid" do
        duplicate.validate
        expect(duplicate.errors[:gias_school_id]).to be_present
      end
    end
  end

  describe "main-site uniqueness (site_code = '-')" do
    let(:provider) { create(:provider) }

    it "allows a single main-site row per provider" do
      expect {
        create(:provider_school, provider:, site_code: "-")
      }.not_to raise_error
    end

    it "rejects a second main-site row for the same provider at model level" do
      create(:provider_school, provider:, site_code: "-")
      dup = build(:provider_school, provider:, site_code: "-")
      expect(dup).not_to be_valid
      expect(dup.errors[:site_code]).to be_present
    end

    it "rejects a second main-site row for the same provider at DB level" do
      create(:provider_school, provider:, site_code: "-")
      expect {
        described_class.new(
          provider:,
          gias_school: create(:gias_school),
          site_code: "-",
        ).save(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows two different providers to each have a main-site row" do
      create(:provider_school, site_code: "-")
      expect {
        create(:provider_school, site_code: "-")
      }.not_to raise_error
    end

    it "allows the same provider to have multiple non-main site codes" do
      create(:provider_school, provider:, site_code: "A")
      expect {
        create(:provider_school, provider:, site_code: "B")
      }.not_to raise_error
    end
  end

  describe "touching the provider" do
    let(:provider) { create(:provider, changed_at: 1.hour.ago) }

    it "bumps provider.changed_at on create" do
      Timecop.freeze do
        create(:provider_school, provider:)
        expect(provider.reload.changed_at).to be_within(1.second).of(Time.zone.now)
      end
    end

    it "bumps provider.changed_at on update" do
      provider_school = create(:provider_school, provider:)
      provider.update_columns(changed_at: 1.hour.ago)

      Timecop.freeze do
        provider_school.update!(site_code: "Z")
        expect(provider.reload.changed_at).to be_within(1.second).of(Time.zone.now)
      end
    end

    it "bumps only the associated provider.changed_at on destroy" do
      provider_school = create(:provider_school, provider:)
      other_provider = create(:provider)
      provider.update_columns(changed_at: 1.hour.ago)
      other_provider.update_columns(changed_at: 2.hours.ago)
      other_provider_changed_at = other_provider.reload.changed_at

      Timecop.freeze do
        provider_school.destroy!

        expect(provider.reload.changed_at).to be_within(1.second).of(Time.zone.now)
        expect(other_provider.reload.changed_at).to be_within(1.second).of(other_provider_changed_at)
      end
    end

    it "leaves provider.updated_at unchanged" do
      provider.update_columns(updated_at: 1.hour.ago)
      original_updated_at = provider.reload.updated_at

      create(:provider_school, provider:)
      expect(provider.reload.updated_at).to be_within(1.second).of(original_updated_at)
    end
  end

  describe "uuid" do
    it "is auto-generated on create" do
      provider_school = create(:provider_school)
      expect(provider_school.reload.uuid).to be_present
    end

    it "is a valid v4 uuid" do
      provider_school = create(:provider_school)
      expect(provider_school.reload.uuid).to match(
        /\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/,
      )
    end

    it "assigns a distinct uuid to each record" do
      first = create(:provider_school, site_code: "A")
      second = create(:provider_school, site_code: "B", provider: first.provider)
      expect(first.reload.uuid).not_to eq(second.reload.uuid)
    end

    it "can be updated" do
      provider_school = create(:provider_school)
      new_uuid = "11111111-1111-4111-8111-111111111111"

      provider_school.update!(uuid: new_uuid)

      expect(provider_school.reload.uuid).to eq(new_uuid)
    end
  end

  describe "database constraints" do
    let(:provider) { create(:provider) }
    let(:gias_school) { create(:gias_school) }

    it "enforces NOT NULL on provider_id" do
      expect {
        described_class.new(gias_school:, site_code: "-").save(validate: false)
      }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "enforces NOT NULL on gias_school_id" do
      expect {
        described_class.new(provider:, site_code: "-").save(validate: false)
      }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "enforces NOT NULL on site_code" do
      expect {
        described_class.new(provider:, gias_school:).save(validate: false)
      }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "enforces NOT NULL on uuid" do
      provider_school = create(:provider_school, provider:, gias_school:)
      expect {
        provider_school.update_column(:uuid, nil)
      }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "enforces the gias_school_id foreign key" do
      missing_id = GiasSchool.maximum(:id).to_i + 1_000
      record = described_class.new(provider:, site_code: "-")
      record.gias_school_id = missing_id
      expect {
        record.save(validate: false)
      }.to raise_error(ActiveRecord::InvalidForeignKey)
    end
  end
end
