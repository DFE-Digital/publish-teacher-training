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

  it "is idempotent when called twice with the same provider and gias_school" do
    described_class.call(provider:, gias_school_id: gias_school.id)

    expect {
      described_class.call(provider:, gias_school_id: gias_school.id)
    }.not_to change(Provider::School, :count)
  end

  it "returns the existing row when one already exists for this (provider, gias_school)" do
    existing = create(:provider_school, provider:, gias_school:, site_code: "A")

    result = described_class.call(provider:, gias_school_id: gias_school.id)

    expect(result).to eq(existing)
    expect(result.site_code).to eq("A")
  end

  it "returns the existing row when a RecordNotUnique race fires" do
    existing = create(:provider_school, provider:, gias_school:, site_code: "B")

    # Simulate a race: between find_or_create_by!'s SELECT and INSERT, another
    # process inserted the row.
    allow_any_instance_of(ActiveRecord::Associations::CollectionProxy)
      .to receive(:find_or_create_by!)
      .and_raise(ActiveRecord::RecordNotUnique)

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
