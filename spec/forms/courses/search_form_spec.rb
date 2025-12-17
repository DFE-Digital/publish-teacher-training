# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::SearchForm do
  describe "#search_params" do
    context "when can_sponsor_visa is true" do
      let(:form) { described_class.new(can_sponsor_visa: "true") }

      it "returns the correct search params with can_sponsor_visa set to true" do
        expect(form.search_params).to eq({ can_sponsor_visa: true })
      end
    end

    context "when send_courses is true" do
      let(:form) { described_class.new(send_courses: "true") }

      it "returns the correct search params with send_courses set to true" do
        expect(form.search_params).to eq({ send_courses: true })
      end
    end

    context "when applications_open is true" do
      let(:form) { described_class.new(applications_open: "true") }

      it "returns the correct search params with applications_open set to true" do
        expect(form.search_params).to eq({ applications_open: true })
      end
    end

    context "when study_types are provided" do
      let(:form) { described_class.new(study_types: %w[full_time part_time]) }

      it "returns the correct search params with study_types as an array" do
        expect(form.search_params).to eq({ study_types: %w[full_time part_time] })
      end
    end

    context "when study_types is an old parameter" do
      let(:form) { described_class.new(study_type: %w[full_time part_time]) }

      it "returns the correct search params with study_types as an array" do
        expect(form.search_params).to eq({ study_types: %w[full_time part_time] })
        expect(form.study_types).to eq(%w[full_time part_time])
      end
    end

    context "when further education is provided" do
      context "when new level params" do
        let(:form) { described_class.new(level: "further_education") }

        it "returns level search params" do
          expect(form.search_params).to eq({ level: "further_education" })
        end
      end

      context "when old age group params is used" do
        let(:form) { described_class.new(age_group: "further_education") }

        it "returns level search params" do
          expect(form.search_params).to eq({ level: "further_education" })
        end
      end

      context "when old qualification params is used as array" do
        let(:form) { described_class.new(qualification: ["pgce pgde"]) }

        it "returns level search params" do
          expect(form.search_params).to eq({ level: "further_education" })
        end
      end

      context "when all old qualification params is used" do
        let(:form) { described_class.new(qualification: ["qts", "pgce_with_qts", "pgce pgde"]) }

        it "returns level search params" do
          expect(form.search_params).to eq({ qualifications: %w[qts qts_with_pgce_or_pgde], level: "further_education" })
          expect(form.qualifications).to eq(%w[qts qts_with_pgce_or_pgde])
          expect(form.level).to eq("further_education")
        end
      end
    end

    context "when minimum degree grade is provided" do
      shared_examples "minimum degree required in search params" do |mapping|
        let(:form) { described_class.new(mapping[:from]) }

        it "maps #{mapping[:from]} to #{mapping[:to]}" do
          expect(form.search_params).to eq(mapping[:to])
        end

        it "returns the expected #{mapping[:to].keys.first} value" do
          expect(form.minimum_degree_required).to eq(mapping[:to].values.first)
        end
      end

      context "when new params" do
        include_examples "minimum degree required in search params",
                         from: { minimum_degree_required: "two_one" },
                         to: { minimum_degree_required: "two_one" }
      end

      context "when old 2:1 params is used" do
        include_examples "minimum degree required in search params",
                         from: { degree_required: "show_all_courses" },
                         to: { minimum_degree_required: "two_one" }
      end

      context "when old 2:2 params is used" do
        include_examples "minimum degree required in search params",
                         from: { degree_required: "two_two" },
                         to: { minimum_degree_required: "two_two" }
      end

      context 'when old "Third class" params is used' do
        include_examples "minimum degree required in search params",
                         from: { degree_required: "third_class" },
                         to: { minimum_degree_required: "third_class" }
      end

      context 'when old "Pass" params is used' do
        include_examples "minimum degree required in search params",
                         from: { degree_required: "not_required" },
                         to: { minimum_degree_required: "pass" }
      end

      context "when old undergraduate params is used" do
        include_examples "minimum degree required in search params",
                         from: { university_degree_status: false },
                         to: { minimum_degree_required: "no_degree_required" }
      end

      context "when old undergraduate params is used always takes precedence over degree required old param" do
        include_examples "minimum degree required in search params",
                         from: { degree_required: "show_all_courses", university_degree_status: false },
                         to: { minimum_degree_required: "no_degree_required" }
      end

      context "when param value does not exist" do
        include_examples "minimum degree required in search params",
                         from: { degree_required: "does_not_exist" },
                         to: {}
      end

      context "when show postgraduate params is used" do
        include_examples "minimum degree required in search params",
                         from: { university_degree_status: true },
                         to: {}
      end
    end

    context "when funding is provided" do
      let(:form) { described_class.new(funding: %w[fee salary]) }

      it "returns the correct search params with funding as an array" do
        expect(form.search_params).to eq({ funding: %w[fee salary] })
      end
    end

    context "when searching by provider" do
      context "when using the new parameter" do
        let(:form) { described_class.new(provider_name: "NIoT") }

        it "returns the correct search params with provider name" do
          expect(form.search_params).to eq({ provider_name: "NIoT" })
        end
      end

      context "when using the old parameter" do
        let(:form) { described_class.new('provider.provider_name': "NIoT") }

        it "returns the correct search params with provider name" do
          expect(form.search_params).to eq({ provider_name: "NIoT" })
        end
      end

      context "when searching by provider code" do
        let(:form) { described_class.new(provider_code: "ABC") }

        it "returns the correct search params with provider code" do
          expect(form.search_params).to eq({ provider_code: "ABC" })
        end
      end
    end

    context "when subjects are provided" do
      let(:form) { described_class.new(subjects: %w[C1]) }

      it "returns the correct search params with subjects" do
        expect(form.search_params).to eq({ subjects: %w[C1] })
      end
    end

    context "when subject code is provided" do
      let(:form) { described_class.new(subject_name: "Biology", subject_code: "C1") }

      it "convert into subjects and remove subject code" do
        expect(form.search_params).to eq({ subject_name: "Biology", subject_code: "C1" })
      end
    end

    context "when excluded courses are provided" do
      context "when excluded courses are an array" do
        let(:form) { described_class.new(excluded_courses: [{ provider_code: "ABC", course_code: "C1" }]) }

        it "returns the correct search params with excluded courses" do
          expect(form.search_params).to eq({ excluded_courses: [{ provider_code: "ABC", course_code: "C1" }] })
        end
      end

      context "when excluded courses are hash" do
        let(:form) { described_class.new(excluded_courses: { 0 => { provider_code: "ABC", course_code: "C1" } }) }

        it "returns the correct search params with excluded courses" do
          expect(form.search_params).to eq({ excluded_courses: [{ provider_code: "ABC", course_code: "C1" }] })
        end
      end
    end

    context "when location is provided" do
      let(:form) { described_class.new(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 10) }

      it "returns the correct search params with location details" do
        expect(form.search_params).to eq(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 10)
      end
    end

    context "when location is provided without radius" do
      let(:form) { described_class.new(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435) }

      it "returns the correct search params with location details and default radius" do
        expect(form.search_params).to eq(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 50)
      end
    end

    context "when location is provided with blank radius" do
      let(:form) { described_class.new(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: "") }

      it "returns the correct search params with location details and default radius" do
        expect(form.search_params).to eq(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 50)
      end
    end

    context "when radius is provided without location" do
      let(:form) { described_class.new(radius: "10") }

      it "returns empty params" do
        expect(form.search_params).to eq({})
      end
    end

    context "when empty coordinates and subjects" do
      let(:form) { described_class.new(address_types: [], subject_code: "", subject_name: "") }

      it "returns empty search params" do
        expect(form.search_params).to eq({})
      end
    end

    context "when location is provided with radius" do
      let(:form) { described_class.new(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 200) }

      it "returns the correct search params with location details and default radius" do
        expect(form.search_params).to eq(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 200)
      end
    end

    context "when location is provided with administrative_area_level type and no radius" do
      let(:form) { described_class.new(location: "Cornwall, UK", latitude: 51.53328, longitude: -0.1734435, address_types: %w[administrative_area_level_2]) }

      it "returns the large area radius" do
        expect(form.search_params).to eq(location: "Cornwall, UK", latitude: 51.53328, longitude: -0.1734435, radius: 50, address_types: %w[administrative_area_level_2])
      end
    end

    ###
    ### FILTERING AND SORTING FEATURE FLAG
    ###
    describe "Filtering and sorting enabled" do
      before do
        allow(FeatureFlag).to receive(:active?).with(:find_filtering_and_sorting).and_return(true)
      end

      context "when location is blank and order is distance" do
        let(:form) { described_class.new(location: "", order: "distance") }

        it "forces the ordering to be by course_name_ascending" do
          expect(form.search_params).to eq({ order: "course_name_ascending", minimum_degree_required: "show_all_courses" })
        end
      end

      context "when location is present and order is blank" do
        let(:form) { described_class.new(formatted_address: "London, UK", location: "London, UK") }

        it "defaults the ordering to distance" do
          expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", formatted_address: "London, UK", location: "London, UK", order: "distance", radius: 20 })
        end
      end

      context "when location is present and order is explicitly set" do
        let(:form) { described_class.new(formatted_address: "London, UK", location: "London, UK", order: "course_name_ascending") }

        it "respects the user's ordering choice" do
          expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", formatted_address: "London, UK", location: "London, UK", order: "course_name_ascending", radius: 20 })
        end
      end

      context "when location is blank and order is blank" do
        let(:form) { described_class.new(location: "", order: "") }

        it "forces the ordering to be by course_name_ascending" do
          expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending" })
        end
      end

      context "when location is present, ordered by fee, but fee funding is removed" do
        let(:form) { described_class.new(formatted_address: "London, UK", location: "London, UK", order: "fee_uk_ascending", funding: %w[salary]) }

        it "resets the ordering to distance" do
          expect(form.search_params[:order]).to eq("distance")
        end
      end
    end
    ###
    ### END FILTERING AND SORTING FEATURE FLAG
    ###

    context "when ordering is provided" do
      context "when new params" do
        let(:form) { described_class.new(order: "course_name_ascending") }

        it "returns the correct search params with order" do
          expect(form.search_params).to eq({ order: "course_name_ascending" })
        end
      end

      shared_examples "converts old ordering" do |mapping|
        let(:form) { described_class.new(mapping[:from]) }

        it "maps #{mapping[:from]} to #{mapping[:to]}" do
          expect(form.search_params).to eq(mapping[:to])
        end

        it "returns the expected #{mapping[:to].keys.first} value" do
          expect(form.order).to eq(mapping[:to].values.first)
        end
      end

      context "when using old course name ascending order params" do
        include_examples "converts old ordering", from: { sortby: "course_asc" }, to: { order: "course_name_ascending" }
      end

      context "when using old course name descending order params" do
        include_examples "converts old ordering", from: { sortby: "course_desc" }, to: { order: "course_name_descending" }
      end

      context "when using old provider name ascending order params" do
        include_examples "converts old ordering", from: { sortby: "provider_asc" }, to: { order: "provider_name_ascending" }
      end

      context "when using old provider name descending order params" do
        include_examples "converts old ordering", from: { sortby: "provider_desc" }, to: { order: "provider_name_descending" }
      end

      context "when using old order param with a non existent value" do
        include_examples "converts old ordering", from: { sortby: "something" }, to: {}
      end

      context "when using old order params with a non existent value and also using the new parameter" do
        include_examples "converts old ordering", from: { sortby: "something", order: "course_name_ascending" }, to: { order: "course_name_ascending" }
      end
    end

    context "when no attributes are set" do
      let(:form) { described_class.new }

      it "returns empty search params" do
        expect(form.search_params).to eq({})
      end
    end

    context "when multiple attributes are set" do
      let(:form) { described_class.new(can_sponsor_visa: "true", send_courses: "true", study_types: %w[full_time]) }

      it "returns the correct search params with all attributes" do
        expect(form.search_params).to eq({ can_sponsor_visa: true, send_courses: true, study_types: %w[full_time] })
      end
    end

    context "when attributes contain nil values" do
      let(:form) { described_class.new(can_sponsor_visa: nil) }

      it "returns search params without nil values" do
        expect(form.search_params).to eq({})
      end
    end
  end

  describe "#search_for_physics?" do
    context "when subjects include physics subject" do
      let(:form) { described_class.new(subjects: %w[F3]) }

      it "returns true" do
        expect(form.search_for_physics?).to be true
      end
    end

    context "when subjects include physics subject code" do
      let(:form) { described_class.new(subject_code: "F3") }

      it "returns true" do
        expect(form.search_for_physics?).to be true
      end
    end

    context "when engineers_teach_physics is present only without physics" do
      let(:form) { described_class.new(engineers_teach_physics: "true") }

      it "returns false" do
        expect(form.search_for_physics?).to be false
      end
    end

    context "when neither subjects include physics nor engineers_teach_physics is present" do
      let(:form) { described_class.new(subjects: %w[01]) }

      it "returns false" do
        expect(form.search_for_physics?).to be false
      end
    end
  end

  describe "#engineers_teach_physics" do
    context "when subjects include physics subject" do
      let(:form) { described_class.new(subjects: %w[F3], engineers_teach_physics: true) }

      it "returns true" do
        expect(form.engineers_teach_physics).to be true
      end
    end

    context "when subjects include physics subject code" do
      let(:form) { described_class.new(subject_code: "F3", engineers_teach_physics: true) }

      it "returns true" do
        expect(form.engineers_teach_physics).to be true
      end
    end

    context "when engineers_teach_physics is present only without physics" do
      let(:form) { described_class.new(engineers_teach_physics: true) }

      it "returns false" do
        expect(form.engineers_teach_physics).to be_nil
      end
    end

    context "when neither subjects include physics nor engineers_teach_physics is present" do
      let(:form) { described_class.new(subjects: %w[01]) }

      it "returns false" do
        expect(form.engineers_teach_physics).to be_nil
      end
    end
  end

  describe "#location" do
    context "when location is the old parameter" do
      let(:form) { described_class.new(lq: "London NW9, UK") }

      it "returns the correct search params with location details" do
        expect(form.location).to eq("London NW9, UK")
      end
    end

    context "when location is set" do
      let(:form) { described_class.new(location: "London NW9, UK") }

      it "returns the correct search params with location details" do
        expect(form.location).to eq("London NW9, UK")
      end
    end
  end

  describe "geolocation attributes" do
    let(:form) do
      described_class.new(
        location: "London NW9, UK",
        country: "England",
        formatted_address: "London NW9, UK",
        address_types: %w[postal_code postal_code_prefix],
      )
    end

    it "assigns geolocation attributes" do
      expect(form.country).to eq("England")
      expect(form.formatted_address).to eq("London NW9, UK")
      expect(form.address_types).to eq(%w[postal_code postal_code_prefix])
    end
  end

  describe "#active_filters" do
    it "returns an empty array when no filters are active" do
      search_form = described_class.new

      active_filters = search_form.active_filters

      expect(active_filters).to eq([])
    end

    it "excludes non-filter address fields from active filters" do
      search_form = described_class.new(
        order: "course_name_ascending",
        level: "all",
        minimum_degree_required: "show_all_courses",
        applications_open: true,
        location: "London",
        formatted_address: "London, UK",
        postal_code: "SW1A 1AA",
        latitude: 51.501,
        longitude: -0.141,
        country: "United Kingdom",
        route: "The Mall",
        locality: "London",
        administrative_area_level_1: "Greater London",
        administrative_area_level_2: "Westminster",
        administrative_area_level_4: "St James's",
        address_types: %w[locality],
      )

      active_filters = search_form.active_filters

      expect(active_filters).to eq([])
    end

    it "returns the same object on subsequent calls" do
      search_form = described_class.new(
        funding: %w[fee],
      )

      first_call = search_form.active_filters
      second_call = search_form.active_filters

      expect(first_call).to equal(second_call)
    end
  end

  describe "#minimum_degree_required_options" do
    it "returns all minimum degree options" do
      search_form = described_class.new

      options = search_form.minimum_degree_required_options

      expect(options).to eq(%w[two_one two_two third_class pass no_degree_required])
    end
  end

  describe "#funding_options" do
    it "returns all funding options" do
      search_form = described_class.new

      options = search_form.funding_options

      expect(options).to eq(%w[fee salary apprenticeship])
    end
  end

  describe "#qualification_options" do
    it "returns all qualification options" do
      search_form = described_class.new

      options = search_form.qualification_options

      expect(options).to eq(%w[qts qts_with_pgce_or_pgde])
    end
  end

  describe "#start_date_options" do
    it "returns all start date options" do
      search_form = described_class.new

      options = search_form.start_date_options

      expect(options).to eq(%w[september all_other_dates])
    end
  end

  describe "#study_type_options" do
    it "returns all study type options" do
      search_form = described_class.new

      options = search_form.study_type_options

      expect(options).to eq(%w[full_time part_time])
    end
  end
end
