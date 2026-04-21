# frozen_string_literal: true

require "rails_helper"

describe ProviderSchools::Creator do
  let(:provider) { create(:provider) }
  let(:gias_school) { create(:gias_school) }

  it "creates a Provider::School row with the given attributes" do
    expect {
      described_class.call(provider:, gias_school_id: gias_school.id, site_code: "A")
    }.to change(Provider::School, :count).by(1)

    row = Provider::School.last
    expect(row.provider).to eq(provider)
    expect(row.gias_school_id).to eq(gias_school.id)
    expect(row.site_code).to eq("A")
  end

  it "returns the created row" do
    result = described_class.call(provider:, gias_school_id: gias_school.id, site_code: "-")

    expect(result).to be_a(Provider::School)
    expect(result).to be_persisted
  end

  it "is idempotent when called twice with the same attributes" do
    described_class.call(provider:, gias_school_id: gias_school.id, site_code: "A")

    expect {
      described_class.call(provider:, gias_school_id: gias_school.id, site_code: "A")
    }.not_to change(Provider::School, :count)
  end

  it "returns the existing row when a matching row already exists" do
    existing = create(:provider_school, provider:, gias_school:, site_code: "A")

    result = described_class.call(provider:, gias_school_id: gias_school.id, site_code: "A")

    expect(result).to eq(existing)
  end

  it "returns the existing row when a RecordNotUnique race fires" do
    existing = create(:provider_school, provider:, gias_school:, site_code: "B")

    allow(provider.schools).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordNotUnique)
    allow(provider).to receive(:schools).and_return(provider.schools)

    result = described_class.call(provider:, gias_school_id: gias_school.id, site_code: "B")

    expect(result).to eq(existing)
  end
end
