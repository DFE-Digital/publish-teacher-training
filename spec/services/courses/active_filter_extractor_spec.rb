require "rails_helper"

RSpec.describe Courses::ActiveFilterExtractor do
  describe "#call" do
    it "returns an empty array when there are no params" do
      search_form = Courses::SearchForm.new
      search_params = {}

      extractor = described_class.new(
        search_params: search_params,
        search_form: search_form,
      )

      active_filters = extractor.call

      expect(active_filters).to eq([])
    end

    it "skips default order when there is no location" do
      search_form = Courses::SearchForm.new(order: "course_name_ascending")
      search_params = search_form.search_params

      extractor = described_class.new(
        search_params: search_params,
        search_form: search_form,
      )

      active_filters = extractor.call

      expect(active_filters).to eq([])
    end

    it "skips default level" do
      search_form = Courses::SearchForm.new(level: "all")
      search_params = search_form.search_params

      extractor = described_class.new(
        search_params: search_params,
        search_form: search_form,
      )

      active_filters = extractor.call

      expect(active_filters).to eq([])
    end

    it "skips default minimum_degree_required" do
      search_form = Courses::SearchForm.new(minimum_degree_required: "show_all_courses")
      search_params = search_form.search_params

      extractor = described_class.new(
        search_params: search_params,
        search_form: search_form,
      )

      active_filters = extractor.call

      expect(active_filters).to eq([])
    end

    it "skips default applications_open" do
      search_form = Courses::SearchForm.new(applications_open: true)
      search_params = search_form.search_params

      extractor = described_class.new(
        search_params: search_params,
        search_form: search_form,
      )

      active_filters = extractor.call

      expect(active_filters).to eq([])
    end

    it "returns an active filter for non-default order" do
      search_form = Courses::SearchForm.new(order: "provider_name_ascending")
      search_params = search_form.search_params

      extractor = described_class.new(
        search_params: search_params,
        search_form: search_form,
      )

      active_filters = extractor.call

      expect(active_filters.size).to eq(1)
      active_filter = active_filters.first
      expect(active_filter.id).to eq(:order)
      expect(active_filter.raw_value).to eq("provider_name_ascending")
      expect(active_filter.value).to eq("provider_name_ascending")
    end

    it "creates separate filters for each subject value and resolves labels" do
      search_form = Courses::SearchForm.new(subjects: %w[00 G1])
      search_params = search_form.search_params

      extractor = described_class.new(
        search_params:,
        search_form:,
      )

      active_filters = extractor.call

      expect(active_filters.size).to eq(2)

      first_filter = active_filters.find { |filter| filter.raw_value == "00" }
      second_filter = active_filters.find { |filter| filter.raw_value == "G1" }

      expect(first_filter.id).to eq(:subjects)
      expect(first_filter.formatted_value).to eq("Primary")
      expect(first_filter.value).to eq("Primary")
      expect(first_filter.remove_params).to eq({ subjects: %w[G1] })

      expect(second_filter.id).to eq(:subjects)
      expect(second_filter.formatted_value).to eq("Mathematics")
      expect(second_filter.value).to eq("Mathematics")
      expect(second_filter.remove_params).to eq({ subjects: %w[00] })
    end

    it "creates a single filter with nil remove_params for scalar funding value" do
      search_form = Courses::SearchForm.new(funding: "fee")
      allow(search_form).to receive(:funding_options).and_return(%w[fee salary apprenticeship])

      search_params = search_form.search_params

      extractor = described_class.new(
        search_params:,
        search_form:,
      )

      active_filters = extractor.call

      expect(active_filters.size).to eq(1)
      active_filter = active_filters.first
      expect(active_filter.id).to eq(:funding)
      expect(active_filter.raw_value).to eq("fee")
      expect(active_filter.value).to eq("fee")
      expect(active_filter.remove_params).to eq({ funding: nil })
    end

    it "skips invalid subject values" do
      search_form = Courses::SearchForm.new(subjects: %w[00 99])

      search_params = search_form.search_params

      extractor = described_class.new(
        search_params: search_params,
        search_form: search_form,
      )

      active_filters = extractor.call

      expect(active_filters).to eq([])
    end

    it "builds a location filter from short_address" do
      search_form = Courses::SearchForm.new(short_address: "London")
      search_params = search_form.search_params

      extractor = described_class.new(
        search_params: search_params,
        search_form: search_form,
      )

      active_filters = extractor.call

      expect(active_filters.size).to eq(1)
      active_filter = active_filters.first
      expect(active_filter.id).to eq(:short_address)
      expect(active_filter.raw_value).to eq("London")
      expect(active_filter.value).to eq("London")
      expect(active_filter.remove_params).to eq({ location: nil, radius: nil })
    end

    it "applies radius condition only when short_address is present" do
      search_form_with_location = Courses::SearchForm.new(location: "London", short_address: "London", radius: "20")
      search_form_without_location = Courses::SearchForm.new(radius: "20")

      extractor_with_location = described_class.new(
        search_params: search_form_with_location.search_params,
        search_form: search_form_with_location,
      )

      extractor_without_location = described_class.new(
        search_params: search_form_without_location.search_params,
        search_form: search_form_without_location,
      )

      active_filters_with_location = extractor_with_location.call
      active_filters_without_location = extractor_without_location.call

      radius_filter = active_filters_with_location.find { |filter| filter.id == :radius }
      expect(radius_filter).not_to be_nil

      radius_filter_without_location = active_filters_without_location.find { |filter| filter.id == :radius }
      expect(radius_filter_without_location).to be_nil
    end

    it "filters out entries whose formatted_value is blank" do
      search_form = Courses::SearchForm.new
      search_params = { unknown_filter: "value" }

      extractor = described_class.new(
        search_params: search_params,
        search_form: search_form,
      )

      active_filters = extractor.call

      expect(active_filters).to eq([])
    end
  end
end
