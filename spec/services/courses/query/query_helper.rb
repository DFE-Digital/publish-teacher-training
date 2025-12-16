# frozen_string_literal: true

module QueryHelper
  def test_search_result_wrapper_klass
    @test_search_result_wrapper_klass ||= Class.new(SimpleDelegator) do
      attr_reader :minimum_distance_to_search_location

      def initialize(course, minimum_distance_to_search_location:)
        super(course)
        @minimum_distance_to_search_location = minimum_distance_to_search_location
      end
    end
  end

  shared_examples "location search results" do |radius:|
    it "returns courses within a #{radius} mile radius" do
      params = { latitude: london.latitude, longitude: london.longitude, radius: }

      expect(described_class.call(params:)).to match_collection(
        expected,
        attribute_names: %w[name minimum_distance_to_search_location],
      )
    end
  end
end
