# frozen_string_literal: true

require "rails_helper"

describe ProviderSchools::Creator do
  let(:provider) { create(:provider) }
  let(:gias_school) { create(:gias_school) }

  it "creates a Provider::School row with the given provider and gias_school" do
    expect {
      described_class.call(provider:, gias_school_id: gias_school.id)
    }.to change(Provider::School, :count).by(1)

    row = Provider::School.last
    expect(row.provider).to eq(provider)
    expect(row.gias_school_id).to eq(gias_school.id)
  end

  it "assigns a site_code from Schools::CodeGenerator" do
    allow(Schools::CodeGenerator).to receive(:call).with(provider:).and_return("Q")

    result = described_class.call(provider:, gias_school_id: gias_school.id)

    expect(result.site_code).to eq("Q")
  end

  it "returns the created row" do
    result = described_class.call(provider:, gias_school_id: gias_school.id)

    expect(result).to be_a(Provider::School)
    expect(result).to be_persisted
  end

  it "is idempotent when called twice" do
    existing = described_class.call(provider:, gias_school_id: gias_school.id)

    expect {
      result = described_class.call(provider:, gias_school_id: gias_school.id)
      expect(result).to eq(existing)
    }.not_to change(Provider::School, :count)
  end

  it "returns the existing row for the GIAS school" do
    existing = create(:provider_school, provider:, gias_school:, site_code: "A")

    result = described_class.call(provider:, gias_school_id: gias_school.id)

    expect(result).to eq(existing)
  end

  it "does not reuse a main-site row" do
    main_site = create(:provider_school, :main_site, provider:, gias_school:)

    expect {
      result = described_class.call(provider:, gias_school_id: gias_school.id)
      expect(result).not_to eq(main_site)
      expect(result.site_code).not_to eq(Provider::School::MAIN_SITE_CODE)
    }.to change(Provider::School, :count).by(1)
  end

  it "returns the existing row when a RecordNotUnique race fires" do
    existing = create(:provider_school, provider:, gias_school:, site_code: "B")

    allow(provider).to receive(:with_lock).and_raise(ActiveRecord::RecordNotUnique)

    result = described_class.call(provider:, gias_school_id: gias_school.id)

    expect(result).to eq(existing)
  end

  it "serialises concurrent adds to the same provider via a row-level lock" do
    expect(provider).to receive(:with_lock).and_call_original.at_least(:once)
    allow(Provider).to receive(:find).and_return(provider)

    # Can't truly test concurrency in a unit spec, but we verify the lock is
    # taken around the write.
    described_class.call(provider:, gias_school_id: gias_school.id)
  end
end
