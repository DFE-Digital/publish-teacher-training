describe API::V2::DeserializableProvider do
  let(:provider) { build(:provider) }
  let(:provider_jsonapi) do
    JSON.parse(jsonapi_renderer.render(
      provider,
      class: {
        Course: API::V2::SerializableProvider,
      },
    ).to_json)["data"]
  end
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  describe "reverse_mapping" do
    subject { described_class.new({}).reverse_mapping }

    it "always contains all attributes" do
      API::V2::DeserializableProvider::PROVIDER_ATTRIBUTES.each do |attribute|
        expect(subject[attribute.to_sym]).to eq("/data/attributes/#{attribute}")
      end
    end
  end
end
