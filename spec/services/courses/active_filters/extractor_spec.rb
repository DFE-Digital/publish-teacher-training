require "rails_helper"

RSpec.describe Courses::ActiveFilters::Extractor do
  describe "#call" do
    context "sort filter by certain priority" do
      it "sorts active filters in the correct order" do
        search_params = {
          can_sponsor_visa: true,
          funding: %w[fee salary apprenticeship],
          interview_location: "online",
          level: "further_education",
          minimum_degree_required: "two_two",
          order: "distance",
          qualifications: %w[qts qts_with_pgce_or_pgde],
          radius: "10",
          send_courses: true,
          study_types: %w[full_time part_time],
          subject_code: "00",
          subject_name: "Primary",
          subjects: %w[00 01 C1 08],
          short_address: "Bristol",
        }

        search_form = Courses::SearchForm.new(search_params)

        extractor = described_class.new(
          search_params: search_params,
          search_form: search_form,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([
          Courses::ActiveFilter.new(
            id: :short_address,
            raw_value: "Bristol",
            value: "Bristol",
            remove_params: { location: nil, radius: nil },
          ),
          Courses::ActiveFilter.new(
            id: :radius,
            raw_value: "10",
            value: "10",
            remove_params: { radius: nil },
          ),
          Courses::ActiveFilter.new(
            id: :subjects,
            raw_value: "00",
            value: "Primary",
            remove_params: { subject_code: nil, subjects: %w[01 C1 08], subject_name: nil },
          ),
          Courses::ActiveFilter.new(
            id: :subjects,
            raw_value: "01",
            value: "Primary with English",
            remove_params: { subjects: %w[00 C1 08] },
          ),
          Courses::ActiveFilter.new(
            id: :subjects,
            raw_value: "C1",
            value: "Biology",
            remove_params: { subjects: %w[00 01 08] },
          ),
          Courses::ActiveFilter.new(
            id: :subjects,
            raw_value: "08",
            value: "Business studies",
            remove_params: { subjects: %w[00 01 C1] },
          ),
          Courses::ActiveFilter.new(
            id: :level,
            raw_value: "further_education",
            value: "further_education",
            remove_params: { level: nil },
          ),
          Courses::ActiveFilter.new(
            id: :send_courses,
            raw_value: true,
            value: true,
            remove_params: { send_courses: nil },
          ),
          Courses::ActiveFilter.new(
            id: :funding,
            raw_value: "fee",
            value: "fee",
            remove_params: { funding: %w[salary apprenticeship] },
          ),
          Courses::ActiveFilter.new(
            id: :funding,
            raw_value: "salary",
            value: "salary",
            remove_params: { funding: %w[fee apprenticeship] },
          ),
          Courses::ActiveFilter.new(
            id: :funding,
            raw_value: "apprenticeship",
            value: "apprenticeship",
            remove_params: { funding: %w[fee salary] },
          ),
          Courses::ActiveFilter.new(
            id: :study_types,
            raw_value: "full_time",
            value: "full_time",
            remove_params: { study_types: %w[part_time] },
          ),
          Courses::ActiveFilter.new(
            id: :study_types,
            raw_value: "part_time",
            value: "part_time",
            remove_params: { study_types: %w[full_time] },
          ),
          Courses::ActiveFilter.new(
            id: :qualifications,
            raw_value: "qts",
            value: "qts",
            remove_params: { qualifications: %w[qts_with_pgce_or_pgde] },
          ),
          Courses::ActiveFilter.new(
            id: :qualifications,
            raw_value: "qts_with_pgce_or_pgde",
            value: "qts_with_pgce_or_pgde",
            remove_params: { qualifications: %w[qts] },
          ),
          Courses::ActiveFilter.new(
            id: :minimum_degree_required,
            raw_value: "two_two",
            value: "two_two",
            remove_params: { minimum_degree_required: nil },
          ),
          Courses::ActiveFilter.new(
            id: :can_sponsor_visa,
            raw_value: true,
            value: true,
            remove_params: { can_sponsor_visa: nil },
          ),
          Courses::ActiveFilter.new(
            id: :interview_location,
            raw_value: "online",
            value: "online",
            remove_params: { interview_location: nil },
          ),
        ])
      end
    end

    context "when subjects are duplicated" do
      it "remove duplicates" do
        search_params = {
          subject_code: "00",
          subject_name: "Primary",
          subjects: %w[00 00 00],
        }
        search_form = Courses::SearchForm.new

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        expect(extractor.call).to eq(
          [
            Courses::ActiveFilter.new(
              id: :subjects,
              value: "Primary",
              raw_value: "00",
              remove_params: { subjects: nil, subject_code: nil, subject_name: nil },
            ),
          ],
        )
      end
    end

    context "when params are empty or default" do
      it "returns an empty array when there are no params" do
        search_form = Courses::SearchForm.new
        search_params = {}

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([])
      end

      it "skips default order when there is no location" do
        search_form = Courses::SearchForm.new(order: "course_name_ascending")
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([])
      end

      it "skips default level" do
        search_form = Courses::SearchForm.new(level: "all")
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([])
      end

      it "skips default minimum_degree_required" do
        search_form = Courses::SearchForm.new(minimum_degree_required: "show_all_courses")
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([])
      end

      it "skips default applications_open" do
        search_form = Courses::SearchForm.new(applications_open: true)
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([])
      end
    end

    context "when params have non-default values" do
      it "returns an active filter for non-default order" do
        search_form = Courses::SearchForm.new(order: "provider_name_ascending")
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_filter = Courses::ActiveFilter.new(
          id: :order,
          raw_value: "provider_name_ascending",
          value: "provider_name_ascending",
          remove_params: { order: nil },
        )

        expect(active_filters).to eq([expected_filter])
      end

      it "returns an active filter for non-default level" do
        search_form = Courses::SearchForm.new(level: "further_education")
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_filter = Courses::ActiveFilter.new(
          id: :level,
          raw_value: "further_education",
          value: "further_education",
          remove_params: { level: nil },
        )

        expect(active_filters).to eq([expected_filter])
      end

      it "returns nil for applications_open false" do
        search_form = Courses::SearchForm.new(applications_open: false)
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([])
      end
    end

    context "when params contain array values" do
      it "creates separate filters for each subject value and resolves names" do
        search_form = Courses::SearchForm.new(subjects: %w[00 G1])
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_primary = Courses::ActiveFilter.new(
          id: :subjects,
          raw_value: "00",
          value: "Primary",
          remove_params: { subjects: %w[G1] },
        )

        expected_mathematics = Courses::ActiveFilter.new(
          id: :subjects,
          raw_value: "G1",
          value: "Mathematics",
          remove_params: { subjects: %w[00] },
        )

        expect(active_filters).to contain_exactly(expected_primary, expected_mathematics)
      end

      it "creates separate filters for multiple funding values" do
        search_form = Courses::SearchForm.new(funding: %w[fee salary])
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_fee = Courses::ActiveFilter.new(
          id: :funding,
          raw_value: "fee",
          value: "fee",
          remove_params: { funding: %w[salary] },
        )

        expected_salary = Courses::ActiveFilter.new(
          id: :funding,
          raw_value: "salary",
          value: "salary",
          remove_params: { funding: %w[fee] },
        )

        expect(active_filters).to contain_exactly(expected_fee, expected_salary)
      end
    end

    context "when params contain scalar values" do
      it "creates a single filter with nil remove_params for scalar funding value" do
        search_form = Courses::SearchForm.new(funding: "fee")
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_filter = Courses::ActiveFilter.new(
          id: :funding,
          raw_value: "fee",
          value: "fee",
          remove_params: { funding: nil },
        )

        expect(active_filters).to eq([expected_filter])
      end

      it "creates a single filter for scalar subject value" do
        search_form = Courses::SearchForm.new(subjects: "00")
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_filter = Courses::ActiveFilter.new(
          id: :subjects,
          raw_value: "00",
          value: "Primary",
          remove_params: { subjects: nil },
        )

        expect(active_filters).to eq([expected_filter])
      end
    end

    context "when params contain invalid values" do
      it "skips invalid subject values" do
        search_form = Courses::SearchForm.new(subjects: %w[00 999999999999])
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([
          Courses::ActiveFilter.new(
            id: :subjects,
            raw_value: "00",
            value: "Primary",
            remove_params: { subjects: nil },
          ),
        ])
      end

      it "skips invalid provider code" do
        search_form = Courses::SearchForm.new(provider_code: "999999999999999")
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([])
      end

      it "skips invalid funding option" do
        search_form = Courses::SearchForm.new
        search_params = { funding: "invalid_funding" }

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([])
      end

      it "skips invalid level values" do
        search_form = Courses::SearchForm.new
        search_params = { level: "invalid_level" }

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([])
      end
    end

    context "when building location filters" do
      it "builds a location filter from short_address" do
        search_form = Courses::SearchForm.new(short_address: "London")
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_filter = Courses::ActiveFilter.new(
          id: :short_address,
          raw_value: "London",
          value: "London",
          remove_params: { location: nil, radius: nil },
        )

        expect(active_filters).to eq([expected_filter])
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

        expected_radius_filter = Courses::ActiveFilter.new(
          id: :radius,
          raw_value: "20",
          value: "20",
          remove_params: { radius: nil },
        )

        expect(active_filters_with_location).to include(expected_radius_filter)
        expect(active_filters_without_location).to eq([])
      end

      it "includes both location and radius when both present" do
        search_form = Courses::SearchForm.new(location: "London", short_address: "London", radius: "20")
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_location_filter = Courses::ActiveFilter.new(
          id: :short_address,
          raw_value: "London",
          value: "London",
          remove_params: { location: nil, radius: nil },
        )

        expected_radius_filter = Courses::ActiveFilter.new(
          id: :radius,
          raw_value: "20",
          value: "20",
          remove_params: { radius: nil },
        )

        expect(active_filters).to include(expected_location_filter, expected_radius_filter)
      end
    end

    context "when formatted_value is blank" do
      it "filters out entries whose formatted_value is blank" do
        search_form = Courses::SearchForm.new
        search_params = { unknown_filter: "value" }

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([])
      end
    end

    context "with funding options" do
      it "resolves all funding_options values as valid filters" do
        search_form = Courses::SearchForm.new
        search_form.funding_options.each do |funding_value|
          form_with_funding = Courses::SearchForm.new(funding: funding_value)
          search_params = form_with_funding.search_params

          extractor = described_class.new(
            search_params:,
            search_form: form_with_funding,
          )

          active_filters = extractor.call

          expected_filter = Courses::ActiveFilter.new(
            id: :funding,
            raw_value: funding_value,
            value: funding_value,
            remove_params: { funding: nil },
          )

          expect(active_filters).to eq([expected_filter])
        end
      end
    end

    context "with study_type options" do
      it "resolves all study_type_options values as valid filters" do
        search_form = Courses::SearchForm.new
        search_form.study_type_options.each do |study_type|
          form_with_study_type = Courses::SearchForm.new(study_types: [study_type])
          search_params = form_with_study_type.search_params

          extractor = described_class.new(
            search_params:,
            search_form: form_with_study_type,
          )

          active_filters = extractor.call

          expected_filter = Courses::ActiveFilter.new(
            id: :study_types,
            raw_value: study_type,
            value: study_type,
            remove_params: { study_types: nil },
          )

          expect(active_filters).to eq([expected_filter])
        end
      end
    end

    context "with qualification options" do
      it "resolves all qualification_options values as valid filters" do
        search_form = Courses::SearchForm.new
        search_form.qualification_options.each do |qualification|
          form_with_qualification = Courses::SearchForm.new(qualifications: [qualification])
          search_params = form_with_qualification.search_params

          extractor = described_class.new(
            search_params:,
            search_form: form_with_qualification,
          )

          active_filters = extractor.call

          expected_filter = Courses::ActiveFilter.new(
            id: :qualifications,
            raw_value: qualification,
            value: qualification,
            remove_params: { qualifications: nil },
          )

          expect(active_filters).to eq([expected_filter])
        end
      end
    end

    context "with start_date options" do
      before do
        allow(FeatureFlag).to receive(:active?).with(:find_filtering_and_sorting).and_return(true)
      end

      it "resolves all start_date_options values as valid filters" do
        search_form = Courses::SearchForm.new
        search_form.start_date_options.each do |start_date|
          form_with_start_date = Courses::SearchForm.new(start_date: [start_date])
          search_params = form_with_start_date.search_params

          extractor = described_class.new(
            search_params:,
            search_form: form_with_start_date,
          )

          active_filters = extractor.call

          expected_filter = Courses::ActiveFilter.new(
            id: :start_date,
            raw_value: start_date,
            value: start_date,
            remove_params: { start_date: nil },
          )

          expect(active_filters).to eq([expected_filter])
        end
      end
    end

    context "with minimum_degree_required options" do
      it "resolves all minimum_degree_required_options values as valid filters" do
        search_form = Courses::SearchForm.new
        search_form.minimum_degree_required_options.each do |degree|
          form_with_degree = Courses::SearchForm.new(minimum_degree_required: degree)
          search_params = form_with_degree.search_params

          extractor = described_class.new(
            search_params:,
            search_form: form_with_degree,
          )

          active_filters = extractor.call

          expected_filter = Courses::ActiveFilter.new(
            id: :minimum_degree_required,
            raw_value: degree,
            value: degree,
            remove_params: { minimum_degree_required: nil },
          )

          expect(active_filters).to eq([expected_filter])
        end
      end
    end

    context "with order options" do
      %w[start_date_ascending fee_uk_ascending fee_intl_ascending].each do |order_value|
        it "resolves #{order_value} as a valid filter" do
          form_with_order = Courses::SearchForm.new(order: order_value)
          search_params = form_with_order.search_params

          extractor = described_class.new(
            search_params:,
            search_form: form_with_order,
          )

          active_filters = extractor.call

          expected_filter = Courses::ActiveFilter.new(
            id: :order,
            raw_value: order_value,
            value: order_value,
            remove_params: { order: nil },
          )

          expect(active_filters).to eq([expected_filter])
        end
      end
    end

    context "with can_sponsor_visa" do
      it "returns a filter when can_sponsor_visa is true" do
        search_form = Courses::SearchForm.new(can_sponsor_visa: true)
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_filter = Courses::ActiveFilter.new(
          id: :can_sponsor_visa,
          raw_value: true,
          value: true,
          remove_params: { can_sponsor_visa: nil },
        )

        expect(active_filters).to eq([expected_filter])
      end

      it "skips can_sponsor_visa when false" do
        search_form = Courses::SearchForm.new
        search_params = { can_sponsor_visa: false }

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([])
      end
    end

    context "with engineers_teach_physics" do
      it "returns a filter when engineers_teach_physics is true" do
        search_form = Courses::SearchForm.new(engineers_teach_physics: true, subjects: %w[F3])
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_engineers_filter = Courses::ActiveFilter.new(
          id: :engineers_teach_physics,
          raw_value: true,
          value: true,
          remove_params: { engineers_teach_physics: nil },
        )

        expected_subject_filter = Courses::ActiveFilter.new(
          id: :subjects,
          raw_value: "F3",
          value: "Physics",
          remove_params: { subjects: nil },
        )

        expect(active_filters).to include(expected_engineers_filter, expected_subject_filter)
      end

      it "skips engineers_teach_physics when false but keeps other valid filters" do
        search_form = Courses::SearchForm.new(subjects: %w[F3])
        search_params = search_form.search_params.merge(engineers_teach_physics: false)

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_subject_filter = Courses::ActiveFilter.new(
          id: :subjects,
          raw_value: "F3",
          value: "Physics",
          remove_params: { subjects: nil },
        )

        expect(active_filters).to eq([expected_subject_filter])
      end
    end

    context "with send_courses" do
      it "returns a filter when send_courses is true" do
        search_form = Courses::SearchForm.new(send_courses: true)
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_filter = Courses::ActiveFilter.new(
          id: :send_courses,
          raw_value: true,
          value: true,
          remove_params: { send_courses: nil },
        )

        expect(active_filters).to eq([expected_filter])
      end

      it "skips send_courses when false" do
        search_form = Courses::SearchForm.new
        search_params = { send_courses: false }

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([])
      end
    end

    context "with interview_location" do
      it "returns a filter when interview_location is online" do
        search_form = Courses::SearchForm.new(interview_location: "online")
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_filter = Courses::ActiveFilter.new(
          id: :interview_location,
          raw_value: "online",
          value: "online",
          remove_params: { interview_location: nil },
        )

        expect(active_filters).to eq([expected_filter])
      end

      it "skips interview_location when not online" do
        search_form = Courses::SearchForm.new
        search_params = { interview_location: "invalid_location" }

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq([])
      end
    end

    context "with provider_code formatter" do
      it "formats provider_code using providers_list name" do
        provider = create(:provider, provider_name: "Example University", provider_code: "DFE01")
        search_form = Courses::SearchForm.new(provider_code: provider.provider_code)
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_filter = Courses::ActiveFilter.new(
          id: :provider_code,
          raw_value: "DFE01",
          value: "Example University (DFE01)",
          remove_params: { provider_code: nil, provider_name: nil },
        )

        expect(active_filters).to eq([expected_filter])
      end
    end

    context "with subject formatter" do
      it "formats subjects using all_subjects name" do
        search_form = Courses::SearchForm.new(subjects: %w[00])
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_filter = Courses::ActiveFilter.new(
          id: :subjects,
          raw_value: "00",
          value: "Primary",
          remove_params: { subjects: nil },
        )

        expect(active_filters).to eq([expected_filter])
      end
    end

    context "radius" do
      it "skips default radius for london for filtering and sorting" do
        FeatureFlag.activate(:find_filtering_and_sorting)

        search_form = Courses::SearchForm.new(
          location: "London, UK",
          short_address: "London",
          formatted_address: "London, UK",
          radius: 20,
        )

        extractor = described_class.new(
          search_params: { short_address: "London", radius: 20 },
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq(
          [
            Courses::ActiveFilter.new(
              id: :short_address,
              value: "London",
              raw_value: "London",
              remove_params: { location: nil, radius: nil },
            ),
          ],
        )
      end

      it "displays non-default radius for london" do
        search_form = Courses::SearchForm.new(
          location: "London, UK",
          short_address: "London",
          formatted_address: "London, UK",
          radius: 50,
        )

        extractor = described_class.new(
          search_params: { short_address: "London", radius: 50 },
          search_form:,
        )

        active_filters = extractor.call

        expected_filter = Courses::ActiveFilter.new(
          id: :radius,
          raw_value: 50,
          value: 50,
          remove_params: { radius: nil },
        )

        expect(active_filters).to include(expected_filter)
      end

      it "skips default radius for locality search" do
        search_form = Courses::SearchForm.new(
          location: "SW1A 1AA",
          short_address: "Locality",
          formatted_address: "Locality",
          postal_code: "SW1A 1AA",
          address_types: %w[postal_code],
          radius: 10,
        )
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq(
          [
            Courses::ActiveFilter.new(
              id: :short_address,
              raw_value: "Locality",
              value: "Locality",
              remove_params: { location: nil, radius: nil },
            ),
          ],
        )
      end

      it "displays non-default radius for locality search" do
        search_form = Courses::SearchForm.new(
          short_address: "SW1A 1AA",
          location: "SW1A 1AA",
          formatted_address: "South",
          postal_code: "SW1A 1AA",
          address_types: %w[postal_code],
          radius: 20,
        )
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expected_filter = Courses::ActiveFilter.new(
          id: :radius,
          raw_value: 20,
          value: 20,
          remove_params: { radius: nil },
        )

        expect(active_filters).to include(expected_filter)
      end

      it "skips default radius for general search" do
        search_form = Courses::SearchForm.new(
          location: "Bristol",
          short_address: "Bristol",
          formatted_address: "Bristol, UK",
          radius: 50,
        )
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params:,
          search_form:,
        )

        active_filters = extractor.call

        expect(active_filters).to eq(
          [
            Courses::ActiveFilter.new(
              id: :short_address,
              raw_value: "Bristol",
              value: "Bristol",
              remove_params: { location: nil, radius: nil },
            ),
          ],
        )
      end

      it "displays non-default radius for general search" do
        search_form = Courses::SearchForm.new(
          location: "Bristol",
          short_address: "Bristol",
          formatted_address: "Bristol, UK",
          radius: 100,
        )
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params: search_params,
          search_form: search_form,
        )

        active_filters = extractor.call

        expected_filter = Courses::ActiveFilter.new(
          id: :radius,
          raw_value: 100,
          value: 100,
          remove_params: { radius: nil },
        )

        expect(active_filters).to include(expected_filter)
      end

      it "skips radius when no location is present" do
        search_form = Courses::SearchForm.new(radius: "50")
        search_params = search_form.search_params

        extractor = described_class.new(
          search_params: search_params,
          search_form: search_form,
        )

        active_filters = extractor.call
        expect(active_filters).to eq([])
      end

      it "returns radius as string and location" do
        search_form = Courses::SearchForm.new

        extractor = described_class.new(
          search_params: { short_address: "London", radius: "100" },
          search_form:,
        )

        active_filters = extractor.call
        expect(active_filters).to eq(
          [
            Courses::ActiveFilter.new(
              id: :short_address,
              raw_value: "London",
              value: "London",
              remove_params: { location: nil, radius: nil },
            ),
            Courses::ActiveFilter.new(
              id: :radius,
              raw_value: "100",
              value: "100",
              remove_params: { radius: nil },
            ),
          ],
        )
      end
    end

    context "when only search by subject code" do
      it "clears both subject_code and subjects containing that code" do
        search_params = {
          subject_code: "00",
          subject_name: "Primary",
        }

        search_form = Courses::SearchForm.new(search_params)
        active_filters = described_class.new(
          search_params: search_params,
          search_form: search_form,
        ).call

        expect(active_filters).to eq(
          [
            Courses::ActiveFilter.new(
              id: :subject_code,
              raw_value: "00",
              value: "Primary",
              remove_params: { subjects: nil, subject_code: nil, subject_name: nil },
            ),
          ],
        )
      end
    end

    describe "subject_code and subjects synchronization" do
      context "when removing subject_code filter" do
        it "clears both subject_code and subjects containing that code" do
          search_params = {
            subject_code: "00",
            subject_name: "Primary",
            subjects: %w[00 01 C1],
          }

          search_form = Courses::SearchForm.new(search_params)
          extractor = described_class.new(
            search_params: search_params,
            search_form: search_form,
          )

          active_filters = extractor.call

          expect(active_filters).to eq(
            [
              Courses::ActiveFilter.new(
                id: :subjects,
                raw_value: "00",
                value: "Primary",
                remove_params: { subjects: %w[01 C1], subject_code: nil, subject_name: nil },
              ),
              Courses::ActiveFilter.new(
                id: :subjects,
                raw_value: "01",
                value: "Primary with English",
                remove_params: { subjects: %w[00 C1] },
              ),
              Courses::ActiveFilter.new(
                id: :subjects,
                raw_value: "C1",
                value: "Biology",
                remove_params: { subjects: %w[00 01] },
              ),
            ],
          )
        end

        it "removes subject_code and all subjects if only that code exists in subjects" do
          search_params = {
            subject_code: "C1",
            subject_name: "Biology",
            subjects: %w[C1],
          }

          search_form = Courses::SearchForm.new(search_params)
          extractor = described_class.new(
            search_params: search_params,
            search_form: search_form,
          )

          active_filters = extractor.call

          expect(active_filters).to eq(
            [
              Courses::ActiveFilter.new(
                id: :subjects,
                raw_value: "C1",
                value: "Biology",
                remove_params: { subjects: nil, subject_code: nil, subject_name: nil },
              ),
            ],
          )
        end

        it "removes subject name when name is not a subject" do
          search_params = {
            subject_name: "Subject that does not exist",
          }
          search_form = Courses::SearchForm.new(search_params)
          extractor = described_class.new(
            search_params: search_params,
            search_form: search_form,
          )
          active_filters = extractor.call
          expect(active_filters).to eq([])
        end
      end
    end
  end
end
