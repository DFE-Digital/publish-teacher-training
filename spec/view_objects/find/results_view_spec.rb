require "rails_helper"

module Find
  describe ResultsView do
    let(:query_parameters) { ActionController::Parameters.new(parameter_hash) }

    let(:default_output_parameters) do
      {
        "qualifications" => %w[qts pgce_with_qts other],
        "fulltime" => false,
        "parttime" => false,
        "hasvacancies" => true,
        "senCourses" => false,
      }
    end

    describe "#query_parameters_with_defaults" do
      subject(:results_view) { described_class.new(query_parameters:).query_parameters_with_defaults }

      context "params are empty" do
        let(:parameter_hash) { {} }

        it { is_expected.to eq(default_output_parameters) }
      end

      context "query_parameters have qualifications set" do
        let(:parameter_hash) { { "qualifications" => "other" } }

        it { is_expected.to eq(default_output_parameters.merge(parameter_hash)) }
      end

      context "query_parameters have fulltime set" do
        let(:parameter_hash) { { "fulltime" => "true" } }

        it { is_expected.to eq(default_output_parameters.merge("fulltime" => true)) }
      end

      context "query_parameters have parttime set" do
        let(:parameter_hash) { { "parttime" => "true" } }

        it { is_expected.to eq(default_output_parameters.merge("parttime" => true)) }
      end

      context "query_parameters have hasvacancies set" do
        let(:parameter_hash) { { "hasvacancies" => "true" } }

        it { is_expected.to eq(default_output_parameters.merge("hasvacancies" => true)) }
      end

      context "query_parameters have senCourses set" do
        let(:parameter_hash) { { "senCourses" => "false" } }

        it { is_expected.to eq(default_output_parameters.merge("senCourses" => false)) }
      end

      context "query_parameters not lose track of 'l' used by C# radio buttons" do
        let(:parameter_hash) { { "l" => "2" } }

        it { is_expected.to eq(default_output_parameters.merge(parameter_hash)) }
      end

      context "parameters without default present in query_parameters" do
        let(:parameter_hash) { { "lat" => "52.3812321", "lng" => "-3.9440235" } }

        it { is_expected.to eq(default_output_parameters.merge(parameter_hash)) }
      end

      context "rails specific parameters are present" do
        let(:parameter_hash) { { "utf8" => "true", "authenticity_token" => "booyah" } }

        it "filters them out" do
          expect(results_view).to eq(default_output_parameters.merge({}))
        end
      end

      context "query_parameters have subjects set" do
        # TODO: the query parameters are currently C# DB ids. They are converted internally
        # in this class but should also be C# parameters when they are output here
        # This will change when we fully switch to Rails

        let(:parameter_hash) { { "subjects" => "14,41,20" } }

        it { is_expected.to eq(default_output_parameters.merge(parameter_hash)) }
      end
    end

    describe "filter_path_with_unescaped_commas" do
      let(:default_query_parameters) do
        {
          "qualifications" => %w[qts pgce_with_qts other],
          "fulltime" => "false",
          "parttime" => "false",
          "hasvacancies" => "true",
          "senCourses" => "false",
        }
      end

      subject(:results_view) { described_class.new(query_parameters: default_query_parameters).filter_params_with_unescaped_commas("/test") }

      it "appends an unescaped querystring to the passed path" do
        allow(UnescapedQueryStringService).to receive(:call).with(
          base_path: "/test",
          parameters: default_output_parameters,
        )
          .and_return("test_result")
        expect(results_view).to eq("test_result")
      end
    end

    describe "#qts?" do
      let(:results_view) { described_class.new(query_parameters: parameter_hash) }

      context "when the hash includes 'qts'" do
        let(:parameter_hash) { { "qualifications" => %w[qts pgce_with_qts] } }

        it "returns true" do
          expect(results_view.qts?).to be_truthy
        end
      end

      context "when the hash does not include 'QTS only'" do
        let(:parameter_hash) { { "qualifications" => %w[other] } }

        it "returns false" do
          expect(results_view.qts?).to be_falsy
        end
      end
    end

    describe "#pgce_or_pgde_with_qts?" do
      let(:results_view) { described_class.new(query_parameters: parameter_hash) }

      context "when the hash includes 'PGCE (or PGDE) with QTS'" do
        let(:parameter_hash) { { "qualifications" => "qts,pgce_with_qts" } }

        it "returns true" do
          expect(results_view.pgce_or_pgde_with_qts?).to be_truthy
        end
      end

      context "when the hash does not include 'PGCE (or PGDE) with QTS'" do
        let(:parameter_hash) { { "qualifications" => "other" } }

        it "returns false" do
          expect(results_view.pgce_or_pgde_with_qts?).to be_falsy
        end
      end
    end

    describe "#other_qualifications?" do
      let(:results_view) { described_class.new(query_parameters: parameter_hash) }

      context "when the hash includes 'Further Education (PGCE or PGDE without QTS)'" do
        let(:parameter_hash) { { "qualifications" => "qts,other" } }

        it "returns true" do
          expect(results_view.other_qualifications?).to be_truthy
        end
      end

      context "when the hash does not include 'Further Education (PGCE or PGDE without QTS)'" do
        let(:parameter_hash) { { "qualifications" => "qts" } }

        it "returns false" do
          expect(results_view.other_qualifications?).to be_falsy
        end
      end
    end

    describe "#all_qualifications?" do
      let(:results_view) { described_class.new(query_parameters: parameter_hash) }

      context "when all selected'" do
        let(:parameter_hash) { { "qualifications" => "qts,pgce_with_qts,other" } }

        it "returns true" do
          expect(results_view.all_qualifications?).to be(true)
        end
      end

      context "when not all selected" do
        let(:parameter_hash) { { "qualifications" => "qts" } }

        it "returns false" do
          expect(results_view.all_qualifications?).to be(false)
        end
      end
    end

    describe "#send_courses?" do
      let(:results_view) { described_class.new(query_parameters: parameter_hash) }

      context "when the senCourses is True" do
        let(:parameter_hash) { { "senCourses" => "True" } }

        it "returns true" do
          expect(results_view.send_courses?).to be_truthy
        end
      end

      context "when the senCourses is nil" do
        let(:parameter_hash) { {} }

        it "returns false" do
          expect(results_view.send_courses?).to be_falsy
        end
      end
    end

    describe "#number_of_extra_subjects" do
      let(:results_view) { described_class.new(query_parameters: parameter_hash) }

      context "The maximum number of subjects are selected" do
        let(:parameter_hash) { { "subject_codes" => (1..43).to_a } }

        it "Returns the number of extra subjects - 2" do
          expect(results_view.number_of_extra_subjects).to eq(37)
        end
      end

      context "more than NUMBER_OF_SUBJECTS_DISPLAYED subjects are selected" do
        let(:parameter_hash) { { "subject_codes" => %w[00 01 F1 Q8 P3] } }

        it "returns the number of the extra subjects" do
          expect(results_view.number_of_extra_subjects).to eq(5)
        end
      end

      context "no subjects are selected" do
        let(:parameter_hash) { {} }

        # Not sure what this is supposed to do
        xit "returns the total number subjects - NUMBER_OF_SUBJECTS_DISPLAYED" do
          expect(results_view.number_of_extra_subjects).to eq(37)
        end
      end
    end

    describe "#location" do
      subject { described_class.new(query_parameters: parameter_hash).location }

      context "when loc is passed" do
        let(:parameter_hash) { { "loc" => "Hogwarts" } }

        it { is_expected.to eq("Hogwarts") }
      end

      context "when loc is not passed" do
        let(:parameter_hash) { {} }

        it { is_expected.to eq("Across England") }
      end
    end

    describe "#radius" do
      subject { described_class.new(query_parameters: parameter_hash).radius }

      let(:parameter_hash) { {} }

      it { is_expected.to eq("50") }
    end

    describe "#show_map?" do
      subject { described_class.new(query_parameters: parameter_hash).show_map? }

      context "when lng, lat and rad are passed" do
        let(:parameter_hash) { { "lng" => "0.3", "lat" => "0.2", "rad" => "10" } }

        it { is_expected.to be(true) }
      end

      context "when only rad is passed" do
        let(:parameter_hash) { { "rad" => "10" } }

        it { is_expected.to be(false) }
      end

      context "when only lat is passed" do
        let(:parameter_hash) { { "lat" => "0.10" } }

        it { is_expected.to be(false) }
      end

      context "when only lng is passed" do
        let(:parameter_hash) { { "lng" => "1.0" } }

        it { is_expected.to be(false) }
      end

      context "when no params are passed" do
        let(:parameter_hash) { {} }

        it { is_expected.to be(false) }
      end
    end

    describe "#courses" do
      let(:results_view) { described_class.new(query_parameters: {}) }

      it "returns a Course ActiveRecord::Relation" do
        expect(results_view.courses).to be_a(ActiveRecord::Relation)
      end
    end

    # TODO: where is this map displayed?
    xdescribe "#map_image_url" do
      subject { described_class.new(query_parameters: parameter_hash).map_image_url }

      let(:parameter_hash) do
        {
          "loc" => "Hogwarts, Reading, UK",
          "rad" => "10",
          "lng" => "-27.1504002",
          "lat" => "-109.3042697",
        }
      end

      before do
        allow(Settings.google).to receive(:maps_api_key).and_return("yellowskullkey")
        allow(Settings.google).to receive(:maps_api_url).and_return("https://maps.googleapis.com/maps/api/staticmap")
      end

      it { is_expected.to eq("https://maps.googleapis.com/maps/api/staticmap?key=yellowskullkey&center=-109.3042697,-27.1504002&zoom=9&size=300x200&scale=2&markers=-109.3042697,-27.1504002") }
    end

    describe "#provider" do
      subject { described_class.new(query_parameters: parameter_hash).provider }

      context "when query is passed" do
        let(:parameter_hash) { { "query" => "Kamino" } }

        it { is_expected.to eq("Kamino") }
      end
    end

    describe "#location_filter?" do
      subject { described_class.new(query_parameters: parameter_hash).location_filter? }

      context "when l param is set to 1" do
        let(:parameter_hash) { { "l" => "1" } }

        it { is_expected.to be(true) }
      end

      context "when l param is not set to 1" do
        let(:parameter_hash) { { "l" => "2" } }

        it { is_expected.to be(false) }
      end
    end

    describe "#england_filter?" do
      subject { described_class.new(query_parameters: parameter_hash).england_filter? }

      context "when l param is set to 2" do
        let(:parameter_hash) { { "l" => "2" } }

        it { is_expected.to be(true) }
      end

      context "when l param is not set to 2" do
        let(:parameter_hash) { { "l" => "3" } }

        it { is_expected.to be(false) }
      end
    end

    describe "#provider_filter?" do
      subject { described_class.new(query_parameters: parameter_hash).provider_filter? }

      context "when l param is set to 3" do
        let(:parameter_hash) { { "l" => "3" } }

        it { is_expected.to be(true) }
      end

      context "when l param is not set to 3" do
        let(:parameter_hash) { { "l" => "2" } }

        it { is_expected.to be(false) }
      end
    end

    describe "#course_count" do
      subject { described_class.new(query_parameters: parameter_hash).course_count }
      let(:parameter_hash) do
        {
          "qualifications" => %w[qts pgce_with_qts other],
          "fulltime" => "true",
          "parttime" => "true",
          "hasvacancies" => "true",
          "senCourses" => "false",
        }
      end

      context "there are more than three results" do
        before do
          create_list(:course, 10)
        end

        it { is_expected.to be(10) }
      end

      context "there are no results" do
        it { is_expected.to be(0) }
      end
    end

    describe "#subjects" do
      context "when no parameters are passed" do
        let(:results_view) { described_class.new(query_parameters: {}) }

        it "returns the subjects in alphabetical order" do
          expect(results_view.subjects.map(&:subject_name)).to eq(
            ["Ancient Greek",
             "Ancient Hebrew",
             "Art and design",
             "Balanced Science",
             "Biology",
             "Business studies",
             "Chemistry",
             "Citizenship",
             "Classics",
             "Communication and media studies",
             "Computing",
             "Dance",
             "Design and technology",
             "Drama",
             "Economics",
             "English",
             "English as a second or other language",
             "French",
             "Further education",
             "Geography",
             "German",
             "Health and social care",
             "History",
             "Humanities",
             "Italian",
             "Japanese",
             "Latin",
             "Mandarin",
             "Mathematics",
             "Modern Languages",
             "Modern languages (other)",
             "Music",
             "Philosophy",
             "Physical education",
             "Physical education with an EBacc subject",
             "Physics",
             "Primary",
             "Primary with English",
             "Primary with geography and history",
             "Primary with mathematics",
             "Primary with modern languages",
             "Primary with physical education",
             "Primary with science",
             "Psychology",
             "Religious education",
             "Russian",
             "Science",
             "Social sciences",
             "Spanish"],
          )
        end

        context "when subject parameters are passed" do
          let(:results_view) do
            described_class.new(query_parameters: {
              "subject_codes" => [
                french_subject_code,
                russian_subject_code,
                primary_subject_code,
                spanish_subject_code,
                mathematics_subject_code,
              ],
            })
          end

          let(:french_subject_code) { "15" }
          let(:primary_subject_code) { "00" }
          let(:spanish_subject_code) { "22" }
          let(:mathematics_subject_code) { "G1" }
          let(:russian_subject_code) { "21" }

          it "returns the subjects in alphabetical order" do
            expect(results_view.subjects.map(&:subject_name)).to eq(
              %w[
                French
                Mathematics
                Primary
                Russian
                Spanish
              ],
            )
          end
        end
      end
    end

    # TODO: is this in place?
    xdescribe "#suggested_search_visible?" do
      def suggested_search_count_parameters
        results_page_parameters.except("page[page]", "page[per_page]", "sort")
      end

      context "searching for courses within England" do
        subject { described_class.new(query_parameters: { "c" => "England", "lat" => "0.1", "lng" => "2.4", "rad" => "50" }).suggested_search_visible? }

        context "there are more than three results" do
          before do
            create_list(:course, 10)
          end

          it { is_expected.to be(false) }
        end

        context "there are less than three results and there are suggested courses found" do
          before do
            create_list(:course, 2)
          end

          it { is_expected.to be(true) }
        end

        context "there are less than three results and there are no suggested courses found" do
          before do
            stub_courses(query: results_page_parameters, course_count: 2)
            stub_courses(query: suggested_search_count_parameters, course_count: 0)
          end

          it { is_expected.to be(false) }
        end
      end

      context "searching for courses in a devolved nation" do
        context "there are less than three results and there are suggested courses found" do
          subject { described_class.new(query_parameters: { "c" => "Scotland", "lat" => "0.1", "lng" => "2.4", "rad" => "50" }).suggested_search_visible? }

          before do
            stub_courses(query: results_page_parameters, course_count: 2)
            stub_courses(query: suggested_search_count_parameters, course_count: 10)
          end

          it { is_expected.to be(false) }
        end
      end
    end

    describe "#placement_schools_summary" do
      subject(:placement_schools_summary) { results_view.placement_schools_summary(course) }

      let(:results_view) { described_class.new(query_parameters: parameter_hash) }

      let(:site1) do
        build(:site, latitude: 51.5079, longitude: 0.0877, address1: "1 Foo Street", postcode: "BAA0NE")
      end

      let(:site_statuses) do
        [build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site1)]
      end

      let(:course) do
        build(
          :course,
          site_statuses:,
        )
      end

      context "site_distance less than 11 miles" do
        let(:parameter_hash) do
          {
            "lat" => "51.5079",
            "lng" => "0.0877",
          }
        end

        it { expect(placement_schools_summary).to eq("Placement schools are near you") }
      end

      context "site_distance less than 21 miles" do
        let(:parameter_hash) do
          {
            "lat" => "51.6985",
            "lng" => "0.1367",
          }
        end

        it { expect(placement_schools_summary).to eq("Placement schools might be near you") }
      end

      context "site_distance more than 21 miles" do
        let(:parameter_hash) do
          {
            "lat" => "52",
            "lng" => "0.1367",
          }
        end

        it { expect(placement_schools_summary).to eq("Placement schools might be in commuting distance") }
      end
    end

    describe "#site_distance" do
      let(:results_view) { described_class.new(query_parameters: parameter_hash) }

      context "closest site distance is greater than 1 mile" do
        let(:parameter_hash) { { "lat" => "51.4975", "lng" => "0.1357" } }

        it "calculates the distance to the closest site, rounding to one decimal place" do
          site1 = build(:site, latitude: 51.5079, longitude: 0.0877, address1: "1 Foo Street", postcode: "BAA0NE")
          site2 = build(:site, latitude: 54.9783, longitude: 1.6178, address1: "2 Foo Street", postcode: "BAA0NE")

          course = build(
            :course,
            site_statuses: [
              build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site1),
              build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site2),
            ],
          )

          expect(results_view.site_distance(course)).to eq(2)
        end
      end

      context "closest site distance is less than 1 mile" do
        let(:parameter_hash) { { "lat" => "51.4975", "lng" => "0.1357" } }

        it "calculates the distance to the closest site, rounding to one decimal place" do
          site1 = build(:site, latitude: 51.4985, longitude: 0.1367, address1: "1 Foo Street", postcode: "BAA0NE")
          site2 = build(:site, latitude: 54.9783, longitude: 1.6178, address1: "2 Foo Street", postcode: "BAA0NE")

          course = build(
            :course,
            site_statuses: [
              build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site1),
              build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site2),
            ],
          )

          expect(results_view.site_distance(course)).to eq(0.1)
        end
      end

      context "closest site distance is less than 0.05 miles" do
        let(:parameter_hash) { { "lat" => "51.4975", "lng" => "0.1357" } }

        it "calculates the distance to the closest site, rounding up to prevent 0.0 miles displaying" do
          site1 = build(:site, latitude: 51.4970, longitude: 0.1358, address1: "1 Foo Street", postcode: "BAA0NE")

          course = build(
            :course,
            site_statuses: [
              build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site1),
            ],
          )

          expect(results_view.site_distance(course)).to eq(0.1)
        end
      end
    end

    context "locations" do
      let(:results_view) { described_class.new(query_parameters: parameter_hash) }
      let(:parameter_hash) { { "lat" => "51.4975", "lng" => "0.1357" } }
      let(:geocoder) { instance_double(Geokit::LatLng) }

      let(:site1) do
        build(
          :site,
          latitude: 51.4985,
          longitude: 0.1367,
          location_name: "Main Site",
          address1: "10 Windy Way",
          address2: "Witham",
          address3: "Essex",
          address4: "UK",
          postcode: "CM8 2SD",
        )
      end
      let(:site2) do
        build(:site, latitude: 54.9783, longitude: 1.6178, location_name: "no address")
      end
      let(:site3) do
        build(
          :site,
          latitude: nil,
          longitude: nil,
          address1: "10 Windy Way",
          address2: "Witham",
          address3: "Essex",
          address4: "UK",
          postcode: "CM8 2SD",
          location_name: "no lat long",
        )
      end
      let(:site4) do
        build(
          :site,
          latitude: 51.4985,
          longitude: 0.1367,
          address1: "10 Windy Way",
          address2: "Witham",
          address3: "Essex",
          address4: "UK",
          postcode: "CM8 2SD",
          location_name: "suspended",
        )
      end

      let(:site5) do
        build(
          :site,
          latitude: 51.4985,
          longitude: 0.1358,
          address1: "No vacancies road",
          address2: "Witham",
          address3: "Essex",
          address4: "UK",
          postcode: "CM8 2SD",
        )
      end

      let(:course) do
        build(
          :course,
          site_statuses: [
            build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site1),
            build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site2),
            build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site3),
            build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site4, status: "suspended"),
            build(:site_status, :both_full_time_and_part_time_vacancies, :findable, :with_no_vacancies, site: site5),
          ],
        )
      end

      before do
        course
      end

      describe "#nearest_address" do
        it "returns the address to the nearest site with vacancies" do
          allow(Geokit::LatLng).to receive(:new).and_return(geocoder)
          allow(geocoder).to receive(:distance_to)
          allow(geocoder).to receive(:distance_to).with("51.4985,0.1367")
          allow(geocoder).to receive(:distance_to).with(",").and_raise(Geokit::Geocoders::GeocodeError)

          expect(results_view.nearest_address(course)).to eq("10 Windy Way, Witham, Essex, UK, CM8 2SD")
        end
      end

      describe "#nearest_location_name" do
        it "returns the location name to the nearest site" do
          allow(Geokit::LatLng).to receive(:new).and_return(geocoder)
          allow(geocoder).to receive(:distance_to)
          allow(geocoder).to receive(:distance_to).with("51.4985,0.1367")
          allow(geocoder).to receive(:distance_to).with(",").and_raise(Geokit::Geocoders::GeocodeError)

          expect(results_view.nearest_location_name(course)).to eq("Main Site")
        end
      end

      describe "#sites_count" do
        it "returns the running or new sites with vacancies count" do
          expect(results_view.sites_count(course)).to eq(2)
        end
      end

      describe "#site_distance" do
        it "returns the running or new sites with vacancies count" do
          expect(results_view.site_distance(course)).to eq(0.1)
        end
      end
    end

    describe "#sort_options" do
      context "all other queries" do
        subject(:results_view) { described_class.new(query_parameters: {}).sort_options }

        it {
          expect(results_view).to eq(
            [
              ["Training provider (A-Z)", 0, { "data-qa": "sort-form__options__ascending" }],
              ["Training provider (Z-A)", 1, { "data-qa": "sort-form__options__descending" }],
            ],
          )
        }
      end
    end

    describe "#no_results_found?" do
      subject { described_class.new(query_parameters: {}).no_results_found? }

      context "there are more than three results" do
        before do
          create_list(:course, 10)
        end

        it { is_expected.to be(false) }
      end

      context "there are no results" do
        it { is_expected.to be(true) }
      end
    end

    describe "#number_of_courses_string" do
      subject { described_class.new(query_parameters: {}).number_of_courses_string }

      context "there are two results" do
        before do
          create_list(:course, 2)
        end

        it { is_expected.to eq("2 courses") }
      end

      context "there is one result" do
        before do
          create(:course)
        end

        it { is_expected.to eq("1 course") }
      end

      context "there are no results" do
        it { is_expected.to eq("No courses") }
      end
    end

    # TODO: Set pagination to 10?
    describe "#total_pages" do
      subject(:results_view) { described_class.new(query_parameters:) }

      let(:parameter_hash) { {} }

      context "where there are no results" do
        it "returns 0 pages" do
          expect(results_view.total_pages).to be(0)
        end
      end

      context "where there are 30 results" do
        before do
          create_list(:course, 30)
        end

        it "returns 3 pages" do
          expect(results_view.total_pages).to be(3)
        end
      end

      context "where there are 60 results" do
        before do
          create_list(:course, 60)
        end

        it "returns 6 pages" do
          expect(results_view.total_pages).to be(6)
        end
      end
    end

    describe "#devolved_nation" do
      context "where country is devolved nation" do
        let(:results_view) { described_class.new(query_parameters: { "c" => "Wales" }) }

        it "returns true" do
          expect(results_view.devolved_nation?).to be true
        end
      end

      context "where country is not a devolved nation" do
        let(:results_view) { described_class.new(query_parameters: { "c" => "Italy" }) }

        it "returns false" do
          expect(results_view.devolved_nation?).to be false
        end
      end

      context "where country is England" do
        let(:results_view) { described_class.new(query_parameters: { "c" => "England" }) }

        it "returns false" do
          expect(results_view.devolved_nation?).to be false
        end
      end

      context "where country is nil" do
        let(:results_view) { described_class.new(query_parameters: { "c" => "nil" }) }

        it "returns false" do
          expect(results_view.devolved_nation?).to be false
        end
      end
    end

    describe "#filter_params_for" do
      context "when the user has searched for a location that is within a devolved nation" do
        let(:query_parameters) do
          {
            "c" => "Wales",
            "lat" => "1.23456",
            "long" => "0.54321",
            "loc" => "Cardiff",
            "lq" => "Cardiff",
            "l" => "1",
          }
        end

        subject(:results_view) { described_class.new(query_parameters:) }

        it "returns default params without the location params" do
          expect(results_view.filter_params_for("/")).to eq "/?fulltime=false&hasvacancies=true&parttime=false&qualifications%5B%5D=qts&qualifications%5B%5D=pgce_with_qts&qualifications%5B%5D=other&senCourses=false"
        end
      end

      context "when the user has searched for a location that is within England" do
        let(:query_parameters) do
          {
            "c" => "England",
            "lat" => "1.23456",
            "long" => "0.54321",
            "loc" => "Brixton",
            "lq" => "Brixton",
            "l" => "1",
          }
        end

        subject(:results_view) { described_class.new(query_parameters:) }

        it "returns default params without the location params" do
          expect(results_view.filter_params_for("/")).to eq "/?c=England&fulltime=false&hasvacancies=true&l=1&lat=1.23456&loc=Brixton&long=0.54321&lq=Brixton&parttime=false&qualifications%5B%5D=qts&qualifications%5B%5D=pgce_with_qts&qualifications%5B%5D=other&senCourses=false"
        end
      end
    end
  end
end
