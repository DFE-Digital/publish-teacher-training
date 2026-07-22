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

  it "uses the supplied site_code when a legacy site was created first" do
    result = described_class.call(provider:, gias_school_id: gias_school.id, site_code: "Z")

    expect(result.site_code).to eq("Z")
  end

  it "uses the supplied uuid when a legacy site was created first" do
    uuid = SecureRandom.uuid

    result = described_class.call(provider:, gias_school_id: gias_school.id, uuid:)

    expect(result.uuid).to eq(uuid)
  end

  it "uses the supplied site_code and uuid together when a legacy site was created first" do
    uuid = SecureRandom.uuid

    result = described_class.call(provider:, gias_school_id: gias_school.id, site_code: "Z", uuid:)

    expect(result.site_code).to eq("Z")
    expect(result.uuid).to eq(uuid)
  end

  it "returns the created row" do
    result = described_class.call(provider:, gias_school_id: gias_school.id)

    expect(result).to be_a(Provider::School)
    expect(result).to be_persisted
  end

  it "is idempotent when called twice with the same provider, gias_school and site_code" do
    described_class.call(provider:, gias_school_id: gias_school.id, site_code: "A")

    expect {
      described_class.call(provider:, gias_school_id: gias_school.id, site_code: "A")
    }.not_to change(Provider::School, :count)
  end

  it "returns the existing row when one already exists for this provider, gias_school and site_code" do
    existing = create(:provider_school, provider:, gias_school:, site_code: "A")

    result = described_class.call(provider:, gias_school_id: gias_school.id, site_code: "A")

    expect(result).to eq(existing)
    expect(result.site_code).to eq("A")
  end

  it "does not reuse a main-site row when creating a normal school row for the same GIAS school" do
    main_site = create(:provider_school, :main_site, provider:, gias_school:)

    expect {
      result = described_class.call(provider:, gias_school_id: gias_school.id, site_code: "A")
      expect(result).not_to eq(main_site)
      expect(result.site_code).to eq("A")
    }.to change(Provider::School, :count).by(1)
  end

  it "updates the uuid on an existing row when one is supplied" do
    existing = create(:provider_school, provider:, gias_school:, site_code: "A", uuid: SecureRandom.uuid)
    uuid = SecureRandom.uuid

    result = described_class.call(provider:, gias_school_id: gias_school.id, site_code: "A", uuid:)

    expect(result).to eq(existing)
    expect(result.uuid).to eq(uuid)
  end

  it "returns the existing row when a RecordNotUnique race fires" do
    existing = create(:provider_school, provider:, gias_school:, site_code: "B")

    allow(provider).to receive(:with_lock).and_raise(ActiveRecord::RecordNotUnique)

    result = described_class.call(provider:, gias_school_id: gias_school.id, site_code: "B")

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
