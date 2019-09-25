describe API::V2::DeserializableCourse do
  let(:course) { build(:course) }
  let(:course_jsonapi) do
    JSON.parse(jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    ).to_json)["data"]
  end
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  describe "reverse_mapping" do
    subject { described_class.new({}).reverse_mapping }

    it "always contains all attributes" do
      API::V2::DeserializableCourse::COURSE_ATTRIBUTES.each do |attribute|
        expect(subject[attribute.to_sym]).to eq("/data/attributes/#{attribute}")
      end
    end
  end
end
