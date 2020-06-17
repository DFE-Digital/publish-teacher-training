require "rails_helper"

describe CourseSearchService do
  describe ".call" do
    describe "when no scope is passed" do
      subject { described_class.call(filter: filter) }
      let(:filter) { {} }

      it "defaults to Course" do
        expect(Course).to receive_message_chain(:findable).and_return(select_scope)
        expect(select_scope).to receive(:select).and_return(inner_query_scope)
        expect(Course).to receive(:where).and_return(expected_scope)
        expect(subject).to eq(expected_scope)
      end
    end

    let(:scope) { class_double(Course) }
    let(:findable_scope) { class_double(Course) }
    let(:select_scope) { class_double(Course) }
    let(:distinct_scope) { class_double(Course) }
    let(:course_ids_scope) { class_double(Course) }
    let(:order_scope) { class_double(Course) }
    let(:joins_provider_scope) { class_double(Course) }
    let(:inner_query_scope) { class_double(Course) }
    let(:filter) { nil }
    let(:sort) { nil }
    let(:expected_scope) { double }

    subject { described_class.call(filter: filter, sort: sort, course_scope: scope) }

    before do
      allow(scope).to receive(:findable).and_return(findable_scope)
    end

    describe "sort by" do
      context "ascending provider name and course name" do
        let(:sort) { "name,provider.provider_name" }

        it "orders in ascending order" do
          expect(findable_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(order_scope)
          expect(order_scope).to receive(:ascending_canonical_order).and_return(select_scope)
          expect(select_scope).to receive(:select).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "descending provider name and course name" do
        let(:sort) { "-provider.provider_name,-name" }

        it "orders in descending order" do
          expect(findable_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(order_scope)
          expect(order_scope).to receive(:descending_canonical_order).and_return(select_scope)
          expect(select_scope).to receive(:select).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "by distance" do
        let(:sort) { "distance" }
        let(:filter) do
          { latitude: 54.9713392, longitude: -1.6112336 }
        end

        it "orders in descending order" do
          expect(findable_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(findable_scope)
          expect(findable_scope).to receive(:joins).and_return(joins_provider_scope)
          expect(joins_provider_scope).to receive(:joins).with(:provider).and_return(select_scope)
          boosted_distance_column = "
      (CASE
        WHEN provider.provider_type = 'O' THEN (distance - 10)
        ELSE distance
      END) as boosted_distance"
          select_criteria = "course.*, distance, #{boosted_distance_column}"

          expect(select_scope).to receive(:select).with(select_criteria)
            .and_return(order_scope)
          expect(order_scope).to receive(:order).with(:boosted_distance).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "unspecified" do
        it "does not order" do
          expect(findable_scope).not_to receive(:order)
          expect(findable_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where)
          expect(subject).not_to eq(expected_scope)
        end
      end
    end

    describe "filter is nil" do
      let(:filter) { nil }

      it "returns all" do
        expect(findable_scope).to receive(:select).and_return(inner_query_scope)
        expect(Course).to receive(:where).and_return(expected_scope)
        expect(subject).to eq(expected_scope)
      end
    end

    describe "range" do
      context "when a range is specified" do
        let(:longitude) { 0 }
        let(:latitude) { 1 }
        let(:radius) { 5 }
        let(:filter) { { longitude: longitude, latitude: latitude, radius: radius } }

        it "adds the within scope" do
          expect(findable_scope).to receive(:within).with(radius, origin: [latitude, longitude]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when a range is not specified" do
        let(:longitude) { 0 }
        let(:latitude) { 1 }
        let(:filter) { { longitude: longitude, latitude: latitude } }

        it "does not add the within scope" do
          expect(findable_scope).not_to receive(:within)
        end
      end
    end

    describe "filter[provider.provider_name]" do
      context "when provider name is present" do
        let(:filter) { { "provider.provider_name": "University of Warwick" } }
        let(:expected_scope) { double }
        let(:accredited_body_scope) { double }
        let(:order_scope) { double }

        it "adds some scope" do
          expect(findable_scope).to receive(:with_provider_name).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).with(:id).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(accredited_body_scope)
          expect(accredited_body_scope).to receive(:accredited_body_order).and_return(order_scope)
          expect(order_scope).to receive(:ascending_canonical_order).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[funding]" do
      context "when value is salary" do
        let(:filter) { { funding: "salary" } }
        let(:expected_scope) { double }

        it "adds the with_salary scope" do
          expect(findable_scope).to receive(:with_salary).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when value is all" do
        let(:filter) { { funding: "all" } }

        it "doesn't add the with_salary scope" do
          expect(findable_scope).not_to receive(:with_salary)
          expect(findable_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[qualification]" do
      context "when qualifications passed" do
        let(:filter) { { qualification: "pgde,pgce_with_qts,pgde_with_qts,qts,pgce" } }
        let(:expected_scope) { double }

        it "adds the with_qualifications scope" do
          expect(findable_scope)
            .to receive(:with_qualifications)
            .with(%w(pgde pgce_with_qts pgde_with_qts qts pgce))
            .and_return(course_ids_scope)

          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)

          expect(subject).to eq(expected_scope)
        end
      end

      context "when no qualifications passed" do
        let(:filter) { {} }

        it "adds the with_qualifications scope" do
          expect(findable_scope).not_to receive(:with_qualifications)
          expect(findable_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[with_vacancies]" do
      context "when true" do
        let(:filter) { { has_vacancies: true } }
        let(:expected_scope) { double }

        it "adds the with_vacancies scope" do
          expect(findable_scope).to receive(:with_vacancies).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when false" do
        let(:filter) { { has_vacancies: false } }

        it "adds the with_vacancies scope" do
          expect(findable_scope).not_to receive(:with_vacancies)
          expect(findable_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the with_vacancies scope" do
          expect(findable_scope).not_to receive(:with_vacancies)
          expect(findable_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[study_type]" do
      context "when full_time" do
        let(:filter) { { study_type: "full_time" } }
        let(:expected_scope) { double }

        it "adds the with_study_modes scope" do
          expect(findable_scope).to receive(:with_study_modes).with(%w(full_time)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when part_time" do
        let(:filter) { { study_type: "part_time" } }
        let(:expected_scope) { double }

        it "adds the with_study_modes scope" do
          expect(findable_scope).to receive(:with_study_modes).with(%w(part_time)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when both" do
        let(:filter) { { study_type: "part_time,full_time" } }
        let(:expected_scope) { double }

        it "adds the with_study_modes scope with an array of both arguments" do
          expect(findable_scope).to receive(:with_study_modes).with(%w(part_time full_time)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the scope" do
          expect(findable_scope).not_to receive(:with_study_modes)
          expect(findable_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[funding_type]" do
      context "when fee" do
        let(:filter) { { funding_type: "fee" } }
        let(:expected_scope) { double }

        it "adds the with_funding_types scope" do
          expect(findable_scope).to receive(:with_funding_types).with(%w(fee)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when salary" do
        let(:filter) { { funding_type: "salary" } }
        let(:expected_scope) { double }

        it "adds the with_funding_types scope" do
          expect(findable_scope).to receive(:with_funding_types).with(%w(salary)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when apprenticeship" do
        let(:filter) { { funding_type: "apprenticeship" } }
        let(:expected_scope) { double }

        it "adds the with_funding_types scope" do
          expect(findable_scope).to receive(:with_funding_types).with(%w(apprenticeship)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when all" do
        let(:filter) { { funding_type: "fee,salary,apprenticeship" } }
        let(:expected_scope) { double }

        it "adds the with_funding_types scope" do
          expect(findable_scope).to receive(:with_funding_types).with(%w(fee salary apprenticeship)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the scope" do
          expect(findable_scope).not_to receive(:with_funding_types)
          expect(findable_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[subjects]" do
      context "a single subject code" do
        let(:filter) { { subjects: "A1" } }
        let(:expected_scope) { double }

        it "adds the subject scope" do
          expect(findable_scope).to receive(:with_subjects).with(%w(A1)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "multiple subject codes" do
        let(:filter) { { subjects: "A1,B2" } }
        let(:expected_scope) { double }

        it "adds the subject scope" do
          expect(findable_scope).to receive(:with_subjects).with(%w(A1 B2)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the scope" do
          expect(findable_scope).not_to receive(:with_subjects)
          expect(findable_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[send_courses]" do
      context "when true" do
        let(:filter) { { send_courses: true } }
        let(:expected_scope) { double }

        it "adds the with_send scope" do
          expect(findable_scope).to receive(:with_send).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when false" do
        let(:filter) { { send_courses: false } }

        it "adds the with_send scope" do
          expect(findable_scope).not_to receive(:with_send)
          expect(findable_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the with_send scope" do
          expect(findable_scope).not_to receive(:with_send)
          expect(findable_scope).to receive(:select).and_return(inner_query_scope)
          expect(Course).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "multiple filters" do
      let(:filter) { { study_type: "part_time", funding: "salary" } }
      let(:salary_scope) { double }
      let(:expected_scope) { double }

      it "combines scopes" do
        expect(findable_scope).to receive(:with_salary).and_return(salary_scope)
        expect(salary_scope).to receive(:with_study_modes).with(%w(part_time)).and_return(course_ids_scope)
        expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
        expect(Course).to receive(:where).and_return(expected_scope)
        expect(subject).to eq(expected_scope)
      end
    end
  end

  describe "10 miles diff" do
    context "university course vs non university course" do
      null_island = { latitude: 0, longitude: 0 }

      let(:university_course) do
        create(:course, provider: university_provider,
          site_statuses: [build(:site_status, :findable, site: site)],
          enrichments: [build(:course_enrichment, :published)])
      end

      let(:non_university_course) do
        create(:course, provider: non_university_provider,
          site_statuses: [build(:site_status, :findable, site: site2)],
          enrichments: [build(:course_enrichment, :published)])
      end

      let(:courses) do
        [university_course, non_university_course]
      end

      let(:site) do
        build(:site, **null_island)
      end

      let(:site2) do
        build(:site, **null_island)
      end

      let(:university_provider) do
        build(:provider, provider_type: :university, sites: [site])
      end

      let(:non_university_provider) do
        build(:provider, provider_type: :scitt, sites: [site2])
      end

      before do
        courses
      end

      let(:scope) do
        Course.all
      end

      subject do
        described_class.call(filter: null_island, sort: "distance", course_scope: scope)
      end

      it "returns correctly" do
        expect(subject.count(:id)).to eq(2)
        expect(subject.first.boosted_distance).to eq(-10)
        expect(subject.first.distance).to eq(0)
        expect(subject.first).to eq(university_course)
        expect(subject.second.boosted_distance).to eq(0)
        expect(subject.second.distance).to eq(0)
        expect(subject.second).to eq(non_university_course)
      end
    end
  end
end
