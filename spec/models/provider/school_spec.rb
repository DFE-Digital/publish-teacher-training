# frozen_string_literal: true

require "rails_helper"

describe Provider::School do
  subject(:provider_school) { build(:provider_school) }

  describe "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:gias_school) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:site_code) }
    it { is_expected.to validate_presence_of(:gias_school_id) }

    it "creates a valid record" do
      expect(provider_school).to be_valid
    end

    context "with the same gias_school and site_code for one provider" do
      let(:existing) { create(:provider_school, :additional) }
      let(:duplicate) do
        build(
          :provider_school,
          :additional,
          provider: existing.provider,
          gias_school: existing.gias_school,
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
