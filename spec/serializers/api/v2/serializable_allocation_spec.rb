require "rails_helper"

describe API::V2::SerializableAllocation do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:resource) { described_class.new(object: allocation) }
  let(:accredited_body) { allocation.accredited_body }
  let(:provider) { allocation.provider }
  let(:allocation_uplift) { allocation.allocation_uplift }
  let(:allocation) { build(:allocation, :with_allocation_uplift, number_of_places: 10) }

  subject do
    jsonapi_renderer.render(
      allocation,
      class: {
        Allocation: API::V2::SerializableAllocation,
        Provider: API::V2::SerializableProvider,
      },
      include: %i(
        accredited_body
        provider
      ),
    )
  end

  it "sets type to allocations" do
    expect(resource.jsonapi_type).to eq :allocations
  end

  it "includes the accredited_body relationship" do
    expect(subject.dig(:data, :relationships, :accredited_body, :data)).to eq({ type: :providers, id: accredited_body.id.to_s })
  end

  it "includes the allocation_uplift relationship" do
    expect(subject.dig(:data, :relationships, :allocation_uplift, :data)).to eq({ type: :allocation_uplift, id: allocation_uplift.id.to_s })
  end

  it "includes the provider relationship" do
    expect(subject.dig(:data, :relationships, :provider, :data)).to eq({ type: :providers, id: provider.id.to_s })
  end

  it "has a number_of_places attribute" do
    expect(subject.dig(:data, :attributes, :number_of_places)).to eq(10)
  end

  it "has a confirmed_number_of_places attribute" do
    expect(subject.dig(:data, :attributes, :confirmed_number_of_places)).to be_nil
  end

  context "when number of places is confirmed" do
    let(:allocation) do
      build(:allocation,
            number_of_places: 10,
            confirmed_number_of_places: 123)
    end

    it "confirmed_number_of_places returns correct value" do
      expect(subject.dig(:data, :attributes, :confirmed_number_of_places)).to be(123)
    end
  end

  it "has a request_type attribute" do
    expect(subject.dig(:data, :attributes, :request_type)).to eq("initial")
  end
end
