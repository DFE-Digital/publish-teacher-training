# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::SearchForm do
  describe "#search_params" do
    context "when can_sponsor_visa is true" do
      let(:form) { described_class.new(can_sponsor_visa: "true") }

      it "returns the correct search params with can_sponsor_visa set to true" do
        expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending", can_sponsor_visa: true })
      end
    end

    context "when send_courses is true" do
      let(:form) { described_class.new(send_courses: "true") }

      it "returns the correct search params with send_courses set to true" do
        expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending", send_courses: true })
      end
    end

    context "when applications_open is true" do
      let(:form) { described_class.new(applications_open: "true") }

      it "returns the correct search params with applications_open set to true" do
        expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending", applications_open: true })
      end
    end

    context "when study_types are provided" do
      let(:form) { described_class.new(study_types: %w[full_time part_time]) }

      it "returns the correct search params with study_types as an array" do
        expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending", study_types: %w[full_time part_time] })
      end
    end

    context "when further education is provided" do
      context "when new level params" do
        let(:form) { described_class.new(level: "further_education") }

        it "returns level search params" do
          expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending", level: "further_education" })
        end
      end
    end

    context "when funding is provided" do
      let(:form) { described_class.new(funding: %w[fee salary]) }

      it "returns the correct search params with funding as an array" do
        expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending", funding: %w[fee salary] })
      end
    end

    context "when searching by provider" do
      context "when using the new parameter" do
        let(:form) { described_class.new(provider_name: "NIoT") }

        it "returns the correct search params with provider name" do
          expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending", provider_name: "NIoT" })
        end
      end

      context "when searching by provider code" do
        let(:form) { described_class.new(provider_code: "ABC") }

        it "returns the correct search params with provider code" do
          expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending", provider_code: "ABC" })
        end
      end
    end

    context "when subjects are provided" do
      let(:form) { described_class.new(subjects: %w[C1]) }

      it "returns the correct search params with subjects" do
        expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending", subjects: %w[C1] })
      end
    end

    context "when subject code is provided" do
      let(:form) { described_class.new(subject_name: "Biology", subject_code: "C1") }

      it "convert into subjects and remove subject code" do
        expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending", subject_name: "Biology", subject_code: "C1" })
      end
    end

    context "when excluded courses are provided" do
      context "when excluded courses are an array" do
        let(:form) { described_class.new(excluded_courses: [{ provider_code: "ABC", course_code: "C1" }]) }

        it "returns the correct search params with excluded courses" do
          expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending", excluded_courses: [{ provider_code: "ABC", course_code: "C1" }] })
        end
      end

      context "when excluded courses are hash" do
        let(:form) { described_class.new(excluded_courses: { 0 => { provider_code: "ABC", course_code: "C1" } }) }

        it "returns the correct search params with excluded courses" do
          expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending", excluded_courses: [{ provider_code: "ABC", course_code: "C1" }] })
        end
      end
    end

    context "when location is provided" do
      let(:form) { described_class.new(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 10) }

      it "returns the correct search params with location details" do
        expect(form.search_params).to eq(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 10, minimum_degree_required: "show_all_courses", order: "distance")
      end
    end

    context "when location is provided without radius" do
      let(:form) { described_class.new(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435) }

      it "returns the correct search params with location details and default radius" do
        expect(form.search_params).to eq(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 50, minimum_degree_required: "show_all_courses", order: "distance")
      end
    end

    context "when location is provided with blank radius" do
      let(:form) { described_class.new(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: "") }

      it "returns the correct search params with location details and default radius" do
        expect(form.search_params).to eq(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 50, minimum_degree_required: "show_all_courses", order: "distance")
      end
    end

    context "when radius is provided without location" do
      let(:form) { described_class.new(radius: "10") }

      it "returns empty params" do
        expect(form.search_params).to eq(minimum_degree_required: "show_all_courses", order: "course_name_ascending")
      end
    end

    context "when empty coordinates and subjects" do
      let(:form) { described_class.new(address_types: [], subject_code: "", subject_name: "") }

      it "returns empty search params" do
        expect(form.search_params).to eq(minimum_degree_required: "show_all_courses", order: "course_name_ascending")
      end
    end

    context "when location is provided with radius but radius is no valid" do
      let(:form) { described_class.new(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 200) }

      it "returns the correct search params with location details and default radius" do
        expect(form.search_params).to eq(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 50, minimum_degree_required: "show_all_courses", order: "distance")
      end
    end

    context "when location is provided with administrative_area_level type and no radius" do
      let(:form) { described_class.new(location: "Cornwall, UK", latitude: 51.53328, longitude: -0.1734435, address_types: %w[administrative_area_level_2]) }

      it "returns the large area radius" do
        expect(form.search_params).to eq(location: "Cornwall, UK", latitude: 51.53328, longitude: -0.1734435, radius: 50, address_types: %w[administrative_area_level_2], minimum_degree_required: "show_all_courses", order: "distance")
      end
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

    context "when ordering is provided" do
      context "when new params" do
        let(:form) { described_class.new(order: "course_name_ascending") }

        it "returns the correct search params with order" do
          expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending" })
        end
      end
    end

    context "when no attributes are set" do
      let(:form) { described_class.new }

      it "returns empty search params" do
        expect(form.search_params).to eq(minimum_degree_required: "show_all_courses", order: "course_name_ascending")
      end
    end

    context "when multiple attributes are set" do
      let(:form) { described_class.new(can_sponsor_visa: "true", send_courses: "true", study_types: %w[full_time]) }

      it "returns the correct search params with all attributes" do
        expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending", can_sponsor_visa: true, send_courses: true, study_types: %w[full_time] })
      end
    end

    context "when attributes contain nil values" do
      let(:form) { described_class.new(can_sponsor_visa: nil) }

      it "returns search params without nil values" do
        expect(form.search_params).to eq({ minimum_degree_required: "show_all_courses", order: "course_name_ascending" })
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

  describe "#funding" do
    context "when funding has one value" do
      let(:form) { described_class.new(funding: "salary") }

      it "returns the funding param in an array" do
        expect(form.funding).to eq(%w[salary])
      end
    end

    context "when funding has no value" do
      let(:form) { described_class.new }

      it "returns the funding param in an array" do
        expect(form.funding).to be_nil
      end
    end

    context "when funding has two values" do
      let(:form) { described_class.new(funding: %w[fee salary]) }

      it "returns the funding param in an array" do
        expect(form.funding).to eq(%w[fee salary])
      end
    end
  end

  describe "#location" do
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
    it "returns the new start date options" do
      search_form = described_class.new

      options = search_form.start_date_options

      expect(options).to eq(%w[jan_to_aug september oct_to_jul])
    end
  end

  describe "#study_type_options" do
    it "returns all study type options" do
      search_form = described_class.new

      options = search_form.study_type_options

      expect(options).to eq(%w[full_time part_time])
    end
  end

  describe "#filter_counts" do
    context "with no filters selected" do
      let(:form) { described_class.new }

      it "returns nil for all counts" do
        expect(form.filter_counts).to eq({
          degree: nil,
          funding: nil,
          interview: nil,
          level: nil,
          ordering: nil,
          primary_subjects: nil,
          provider: nil,
          qualifications: nil,
          radius: nil,
          secondary_subjects: nil,
          send_courses: nil,
          sponsor_visa: nil,
          start_date: nil,
          study_types: nil,
          teach_physics: nil,
        })
      end
    end

    context "with primary subjects selected" do
      let(:form) { described_class.new(subjects: %w[00 01]) }

      it "returns the count of primary subjects" do
        expect(form.filter_counts[:primary_subjects]).to eq(2)
        expect(form.filter_counts[:secondary_subjects]).to be_nil
      end
    end

    context "with secondary subjects selected" do
      let(:form) { described_class.new(subjects: %w[C1 F1]) }

      it "returns the count of secondary subjects" do
        expect(form.filter_counts[:secondary_subjects]).to eq(2)
        expect(form.filter_counts[:primary_subjects]).to be_nil
      end
    end

    context "with mixed primary and secondary subjects" do
      let(:form) { described_class.new(subjects: %w[00 C1 F1]) }

      it "returns counts for both" do
        expect(form.filter_counts[:primary_subjects]).to eq(1)
        expect(form.filter_counts[:secondary_subjects]).to eq(2)
      end
    end

    context "with funding selected" do
      let(:form) { described_class.new(funding: %w[fee salary]) }

      it "returns the count of funding options" do
        expect(form.filter_counts[:funding]).to eq(2)
      end
    end

    context "with send_courses selected" do
      let(:form) { described_class.new(send_courses: true) }

      it "returns 1 for send_courses" do
        expect(form.filter_counts[:send_courses]).to eq(1)
      end
    end

    context "with qualifications selected" do
      let(:form) { described_class.new(qualifications: %w[qts qts_with_pgce_or_pgde]) }

      it "returns the count of qualifications" do
        expect(form.filter_counts[:qualifications]).to eq(2)
      end
    end

    context "with interview_location selected" do
      let(:form) { described_class.new(interview_location: "online") }

      it "returns 1 for interview" do
        expect(form.filter_counts[:interview]).to eq(1)
      end
    end

    context "with ordering" do
      context "when location is present and order is not distance" do
        let(:form) { described_class.new(location: "London, UK", order: "course_name_ascending") }

        it "returns 1 for ordering" do
          expect(form.filter_counts[:ordering]).to eq(1)
        end
      end

      context "when location is present and order is distance (default)" do
        let(:form) { described_class.new(location: "London, UK", order: "distance") }

        it "returns nil for ordering" do
          expect(form.filter_counts[:ordering]).to be_nil
        end
      end

      context "when no location and order is course_name_ascending (default)" do
        let(:form) { described_class.new(order: "course_name_ascending") }

        it "returns nil for ordering" do
          expect(form.filter_counts[:ordering]).to be_nil
        end
      end

      context "when no location and order is not the default" do
        let(:form) { described_class.new(order: "provider_name_ascending") }

        it "returns 1 for ordering" do
          expect(form.filter_counts[:ordering]).to eq(1)
        end
      end
    end

    context "with radius" do
      context "when using default radius (10)" do
        let(:form) { described_class.new(address_types: %w[locality], location: "Manchester, UK", radius: "10") }

        it "returns 0 for radius" do
          expect(form.filter_counts[:radius]).to be_nil
        end
      end

      context "when using non-default radius" do
        let(:form) { described_class.new(address_types: %w[locality], location: "Manchester, UK", radius: "100") }

        it "returns 1 for radius" do
          expect(form.filter_counts[:radius]).to eq(1)
        end
      end

      context "when London and using London default radius (20)" do
        let(:form) { described_class.new(location: "London, UK", formatted_address: "London, UK", radius: "20") }

        it "returns 1 for radius" do
          expect(form.filter_counts[:radius]).to be_nil
        end
      end

      context "when locality and using small radius (10)" do
        let(:form) { described_class.new(location: "SW1A 1AA", address_types: %w[postal_code], radius: "10") }

        it "returns 1 for radius" do
          expect(form.filter_counts[:radius]).to be_nil
        end
      end
    end

    context "with provider selected" do
      context "when provider_code is present" do
        let(:form) { described_class.new(provider_code: "ABC") }

        it "returns 1 for provider" do
          expect(form.filter_counts[:provider]).to eq(1)
        end
      end

      context "when provider_name is present" do
        let(:form) { described_class.new(provider_name: "University of London") }

        it "returns 1 for provider" do
          expect(form.filter_counts[:provider]).to eq(1)
        end
      end
    end

    context "with engineers_teach_physics selected" do
      let(:form) { described_class.new(subjects: %w[F3], engineers_teach_physics: "true") }

      it "returns 1 for teach_physics" do
        expect(form.filter_counts[:teach_physics]).to eq(1)
      end
    end

    context "with degree requirement" do
      context "when show_all_courses (default)" do
        let(:form) { described_class.new(minimum_degree_required: "show_all_courses") }

        it "returns nil for degree" do
          expect(form.filter_counts[:degree]).to be_nil
        end
      end

      context "when specific degree requirement selected" do
        let(:form) { described_class.new(minimum_degree_required: "two_one") }

        it "returns 1 for degree" do
          expect(form.filter_counts[:degree]).to eq(1)
        end
      end
    end

    context "with start_date selected" do
      let(:form) { described_class.new(start_date: %w[september_2025 january_2026]) }

      it "returns the count of start dates" do
        expect(form.filter_counts[:start_date]).to eq(2)
      end
    end

    context "with can_sponsor_visa selected" do
      let(:form) { described_class.new(can_sponsor_visa: true) }

      it "returns 1 for sponsor_visa" do
        expect(form.filter_counts[:sponsor_visa]).to eq(1)
      end
    end

    context "with study_types selected" do
      let(:form) { described_class.new(study_types: %w[full_time part_time]) }

      it "returns the count of study types" do
        expect(form.filter_counts[:study_types]).to eq(2)
      end
    end

    context "with level selected" do
      let(:form) { described_class.new(level: "further_education") }

      it "returns 1 for level" do
        expect(form.filter_counts[:level]).to eq(1)
      end
    end
  end

  describe "#subjects" do
    context "when subjects and subject code is nil" do
      it "returns empty" do
        expect(described_class.new.subjects).to be_empty
      end
    end

    context "when only subject code has a value" do
      it "returns subject code in the subjects" do
        expect(described_class.new(subject_code: "01").subjects).to eq(%w[01])
      end
    end

    context "when subject code and subject has a value" do
      it "returns subject code in the subjects" do
        expect(described_class.new(subject_code: "01", subjects: %w[00]).subjects).to eq(%w[00 01])
      end
    end

    context "when subject code is already in subjects" do
      it "returns subject code in the subjects" do
        expect(described_class.new(subject_code: "00", subjects: %w[00 01]).subjects).to eq(%w[00 01])
      end
    end
  end

  describe "#radius" do
    context "when valid radius" do
      it "returns radius" do
        [10, 20, 50, 100].each do |valid_radius|
          search_form = described_class.new(radius: valid_radius)
          expect(search_form.radius).to eq(valid_radius)
        end
      end
    end

    context "when invalid radius" do
      it "returns radius" do
        [1, 5, 15, "not-allowed", 999, "other-value", -9].each do |invalid_radius|
          search_form = described_class.new(radius: invalid_radius)
          expect(search_form.radius).to eq(50)
        end
      end
    end
  end

  describe "#location_category_changed?" do
    context "when both previous and current location categories are nil" do
      let(:form) { described_class.new(previous_location_category: nil, location: nil) }

      it "returns false" do
        expect(form.location_category_changed?).to be false
      end
    end

    context "when previous is nil and current is regional" do
      let(:form) do
        described_class.new(
          previous_location_category: "",
          location: "Cornwall, UK",
          formatted_address: "Cornwall, UK",
          address_types: %w[administrative_area_level_2 political],
        )
      end

      it "returns true" do
        expect(form.location_category_changed?).to be true
      end
    end

    context "when previous is london and current is regional" do
      let(:form) do
        described_class.new(
          previous_location_category: "london",
          location: "Cornwall, UK",
          formatted_address: "Cornwall, UK",
          address_types: %w[administrative_area_level_2 political],
        )
      end

      it "returns true" do
        expect(form.location_category_changed?).to be true
      end
    end

    context "when previous and current are both regional" do
      let(:form) do
        described_class.new(
          previous_location_category: "regional",
          location: "Cornwall, UK",
          formatted_address: "Cornwall, UK",
          address_types: %w[administrative_area_level_2 political],
        )
      end

      it "returns false" do
        expect(form.location_category_changed?).to be false
      end
    end

    context "when previous is regional and current is nil (location removed)" do
      let(:form) do
        described_class.new(
          previous_location_category: "regional",
          location: nil,
        )
      end

      it "returns true" do
        expect(form.location_category_changed?).to be true
      end
    end
  end

  describe "resetting defaults when location category changes" do
    describe "#order" do
      context "when location category changed from nil to regional" do
        let(:form) do
          described_class.new(
            previous_location_category: "",
            location: "Cornwall, UK",
            formatted_address: "Cornwall, UK",
            address_types: %w[administrative_area_level_2 political],
            order: "course_name_ascending",
          )
        end

        it "resets to distance (location default)" do
          expect(form.order).to eq("distance")
        end
      end

      context "when location category unchanged" do
        let(:form) do
          described_class.new(
            previous_location_category: "regional",
            location: "Cornwall, UK",
            formatted_address: "Cornwall, UK",
            address_types: %w[administrative_area_level_2 political],
            order: "course_name_ascending",
          )
        end

        it "preserves user selection" do
          expect(form.order).to eq("course_name_ascending")
        end
      end
    end

    describe "#radius" do
      context "when location category changed from london to regional" do
        let(:form) do
          described_class.new(
            previous_location_category: "london",
            location: "Cornwall, UK",
            formatted_address: "Cornwall, UK",
            address_types: %w[administrative_area_level_2 political],
            radius: "20",
          )
        end

        it "resets to regional default (50)" do
          expect(form.radius).to eq(50)
        end
      end

      context "when location category unchanged" do
        let(:form) do
          described_class.new(
            previous_location_category: "regional",
            location: "Cornwall, UK",
            formatted_address: "Cornwall, UK",
            address_types: %w[administrative_area_level_2 political],
            radius: "10",
          )
        end

        it "preserves user selection" do
          expect(form.radius).to eq("10")
        end
      end
    end
  end
end
