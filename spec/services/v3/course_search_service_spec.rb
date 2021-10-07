# rubocop:disable RSpec/StubbedMock
require "rails_helper"

RSpec.describe V3::CourseSearchService do
  describe ".call" do
    describe "sorting" do
      before do
        create(:course, name: "A", provider: build(:provider, provider_name: "A"))
        create(:course, name: "B", provider: build(:provider, provider_name: "B"))
        create(:course, name: "C", provider: build(:provider, provider_name: "A"))
        create(:course, name: "D", provider: build(:provider, provider_name: "B"))
      end

      context "sort by ascending provider name and course name" do
        let(:sort) { "name,provider.provider_name" }

        it "orders as specified" do
          courses = described_class.call(sort: sort).all
          expect(courses.map { |c| c.provider.provider_name }).to eq %w[A A B B]
          expect(courses.map(&:name)).to eq %w[A C B D]
        end
      end

      context "sort by descending provider name and course name" do
        let(:sort) { "-provider.provider_name,-name" }

        it "orders as specified" do
          courses = described_class.call(sort: sort).all
          expect(courses.map { |c| c.provider.provider_name }).to eq %w[B B A A]
          expect(courses.map(&:name)).to eq %w[D B C A]
        end
      end

      context "distance" do
        let(:sort) { "distance" }
        let(:origin) { { latitude: 0, longitude: 0 } }
        let(:near_to_origin) { { latitude: 1, longitude: 0 } }
        let(:far_from_origin) { { latitude: 2, longitude: 0 } }
        let(:furthest_from_origin) { { latitude: 3, longitude: 0 } }

        let!(:furthest_course) do
          create(
            :course,
            site_statuses: [build(:site_status, :findable, site: build(:site, **furthest_from_origin))],
          )
        end
        let!(:far_course) do
          create(
            :course,
            site_statuses: [build(:site_status, :findable, site: build(:site, **far_from_origin))],
          )
        end
        let!(:near_course) do
          create(
            :course,
            site_statuses: [build(:site_status, :findable, site: build(:site, **near_to_origin))],
          )
        end

        it "orders distance descending" do
          courses = described_class.call(sort: sort).all

          expect(courses.map(&:id)).to eq [furthest_course.id, far_course.id, near_course.id]
        end
      end
    end

    describe "filtering" do
      context "filter by distance" do
        let(:origin) { { latitude: 0, longitude: 0 } }
        let(:radius) { 5 } # miles
        let(:near_to_origin) { { latitude: 0.01, longitude: 0 } } # ~1 mile away
        let(:far_from_origin) { { latitude: 0.2, longitude: 0 } } # ~12 miles away
        let(:furthest_from_origin) { { latitude: 0.3, longitude: 0 } } # ~18 miles away

        let(:filter) { { longitude: origin[:longitude], latitude: origin[:latitude], radius: radius } }

        let!(:furthest_course) do
          create(
            :course,
            site_statuses: [build(:site_status, :findable, site: build(:site, **furthest_from_origin))],
          )
        end
        let!(:far_course) do
          create(
            :course,
            site_statuses: [build(:site_status, :findable, site: build(:site, **far_from_origin))],
          )
        end
        let!(:near_course) do
          create(
            :course,
            site_statuses: [build(:site_status, :findable, site: build(:site, **near_to_origin))],
          )
        end

        it "returns only courses within the radius" do
          courses = described_class.call(filter: filter).all
          expect(courses).to eq [near_course]
        end
      end

      context "filter by provider" do
        let(:filter) { { "provider.provider_name": "University of Warwick" } }

        before do
          create(:course, provider: build(:provider, provider_name: "University of Warwick"))
          create(:course, provider: build(:provider, provider_name: "University of Life"))
        end

        it "returns only courses belonging to the named provider" do
          courses = described_class.call(filter: filter).all
          expect(courses.map { |c| c.provider.provider_name }).to eq ["University of Warwick"]
        end
      end

      context "filter by funding" do
        let(:with_salary) { create(:course, :with_salary) }
        let(:without_salary) { create(:course) }

        it "returns only courses with a salary if filter value is 'salary'" do
          filter = { funding: "salary" }
          courses = described_class.call(filter: filter).all
          expect(courses).to eq [without_salary]
        end

        it "returns all courses if filter value is 'all'" do
          filter = { funding: "all" }
          courses = described_class.call(filter: filter).all
          expect(courses).to eq [without_salary]
        end

        it "returns all courses if filter is blank" do
          filter = {}
          courses = described_class.call(filter: filter).all
          expect(courses).to eq [with_salary, without_salary]
        end
      end

      context "filter by qualification" do
        let!(:pgce) { create(:course, :resulting_in_pgce) }
        let!(:pgce_with_qts) { create(:course, :resulting_in_pgce_with_qts) }
        let!(:pgde) { create(:course, :resulting_in_pgde) }

        it "returns only courses matching the specified qualifications" do
          filter = { qualification: "pgde,pgce_with_qts" }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [pgde, pgce_with_qts]
        end

        it "returns all courses if filter is blank" do
          filter = {}
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [pgce, pgde, pgce_with_qts]
        end
      end

      context "filter by vacancies" do
        let!(:full_time_vacancies) { create(:course, site_statuses: [build(:site_status, :findable, :full_time_vacancies)]) }
        let!(:part_time_vacancies) { create(:course, study_mode: :part_time, site_statuses: [build(:site_status, :findable, :part_time_vacancies)]) }
        let!(:no_vacancies) { create(:course, site_statuses: [build(:site_status, :findable, :no_vacancies)]) }

        it "returns only courses with vacancies when filter is true" do
          filter = { has_vacancies: true }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [full_time_vacancies, part_time_vacancies]
        end

        it "returns all courses when filter is false" do
          filter = { has_vacancies: false }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [full_time_vacancies, part_time_vacancies, no_vacancies]
        end

        it "returns all courses when filter is blank" do
          filter = {}
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [full_time_vacancies, part_time_vacancies, no_vacancies]
        end
      end
    end
  end

  describe "old .call" do
    let(:course_with_includes) { class_double(Course) }
    let(:scope) { class_double(Course) }
    let(:select_scope) { class_double(Course) }
    let(:distinct_scope) { class_double(Course) }
    let(:course_ids_scope) { class_double(Course) }
    let(:order_scope) { class_double(Course) }
    let(:joins_provider_scope) { class_double(Course) }
    let(:inner_query_scope) { class_double(Course) }
    let(:outer_query_scope) { class_double(Course) }
    let(:filter) { nil }
    let(:sort) { nil }
    let(:expected_scope) { double }

    before do
      allow(Course).to receive(:includes)
        .with(
          :enrichments,
          :financial_incentives,
          course_subjects: [:subject],
          site_statuses: [:site],
          provider: %i[recruitment_cycle ucas_preferences],
        ).and_return(course_with_includes)

      allow(course_with_includes).to receive(:where).and_return(outer_query_scope)
    end

    describe "when no scope is passed" do
      subject { described_class.call(filter: filter) }

      let(:filter) { {} }

      it "defaults to Course" do
        expect(Course).to receive(:select).and_return(inner_query_scope)
        expect(course_with_includes).to receive(:where).and_return(expected_scope)
        expect(subject).to eq(expected_scope)
      end
    end

    subject do
      described_class.call(filter: filter, sort: sort, course_scope: scope)
    end

    xdescribe "sort by" do
      context "unspecified" do
        it "does not order" do
          expect(scope).not_to receive(:order)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where)
          expect(subject).not_to eq(expected_scope)
        end
      end
    end

    xdescribe "filter is nil" do
      let(:filter) { nil }

      it "returns all" do
        expect(scope).to receive(:select).and_return(inner_query_scope)
        expect(course_with_includes).to receive(:where).and_return(expected_scope)
        expect(subject).to eq(expected_scope)
      end
    end

    xdescribe "range" do
      context "when a range is not specified" do
        let(:longitude) { 0 }
        let(:latitude) { 1 }
        let(:filter) { { longitude: longitude, latitude: latitude } }

        it "does not add the within scope" do
          expect(scope).not_to receive(:within)
        end
      end
    end

    describe "filter[findable]" do
      context "when true" do
        let(:filter) { { findable: true } }
        let(:expected_scope) { double }

        it "adds the findable scope" do
          expect(scope).to receive(:findable).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when false" do
        let(:filter) { { findable: false } }

        it "doesn't add the findable scope" do
          expect(scope).not_to receive(:findable)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the findable scope" do
          expect(scope).not_to receive(:findable)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[study_type]" do
      context "when full_time" do
        let(:filter) { { study_type: "full_time" } }
        let(:expected_scope) { double }

        it "adds the with_study_modes scope" do
          expect(scope).to receive(:with_study_modes).with(%w(full_time)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when part_time" do
        let(:filter) { { study_type: "part_time" } }
        let(:expected_scope) { double }

        it "adds the with_study_modes scope" do
          expect(scope).to receive(:with_study_modes).with(%w(part_time)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when both" do
        let(:filter) { { study_type: "part_time,full_time" } }
        let(:expected_scope) { double }

        it "adds the with_study_modes scope with an array of both arguments" do
          expect(scope).to receive(:with_study_modes).with(%w(part_time full_time)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the scope" do
          expect(scope).not_to receive(:with_study_modes)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[funding_type]" do
      context "when fee" do
        let(:filter) { { funding_type: "fee" } }
        let(:expected_scope) { double }

        it "adds the with_funding_types scope" do
          expect(scope).to receive(:with_funding_types).with(%w(fee)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when salary" do
        let(:filter) { { funding_type: "salary" } }
        let(:expected_scope) { double }

        it "adds the with_funding_types scope" do
          expect(scope).to receive(:with_funding_types).with(%w(salary)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when apprenticeship" do
        let(:filter) { { funding_type: "apprenticeship" } }
        let(:expected_scope) { double }

        it "adds the with_funding_types scope" do
          expect(scope).to receive(:with_funding_types).with(%w(apprenticeship)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when all" do
        let(:filter) { { funding_type: "fee,salary,apprenticeship" } }
        let(:expected_scope) { double }

        it "adds the with_funding_types scope" do
          expect(scope).to receive(:with_funding_types).with(%w(fee salary apprenticeship)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the scope" do
          expect(scope).not_to receive(:with_funding_types)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[degree_grade]" do
      context "when two_two" do
        let(:filter) { { degree_grade: "two_two" } }
        let(:expected_scope) { double }

        it "adds the with_degree_grades scope" do
          expect(scope).to receive(:with_degree_grades).with(%w(two_two)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when third_class" do
        let(:filter) { { degree_grade: "third_class" } }
        let(:expected_scope) { double }

        it "adds the with_degree_grades scope" do
          expect(scope).to receive(:with_degree_grades).with(%w(third_class)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when not_required" do
        let(:filter) { { degree_grade: "not_required" } }
        let(:expected_scope) { double }

        it "adds the with_degree_grades scope" do
          expect(scope).to receive(:with_degree_grades).with(%w(not_required)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when all" do
        let(:filter) { { degree_grade: "two_one,two_two,third_class,not_required" } }
        let(:expected_scope) { double }

        it "adds the with_degree_grades scope" do
          expect(scope).to receive(:with_degree_grades).with(%w(two_one two_two third_class not_required)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the scope" do
          expect(scope).not_to receive(:with_degree_grades)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[subjects]" do
      context "a single subject code" do
        let(:filter) { { subjects: "A1" } }
        let(:expected_scope) { double }

        it "adds the subject scope" do
          expect(scope).to receive(:with_subjects).with(%w(A1)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "multiple subject codes" do
        let(:filter) { { subjects: "A1,B2" } }
        let(:expected_scope) { double }

        it "adds the subject scope" do
          expect(scope).to receive(:with_subjects).with(%w(A1 B2)).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the scope" do
          expect(scope).not_to receive(:with_subjects)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[send_courses]" do
      context "when true" do
        let(:filter) { { send_courses: true } }
        let(:expected_scope) { double }

        it "adds the with_send scope" do
          expect(scope).to receive(:with_send).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when false" do
        let(:filter) { { send_courses: false } }

        it "adds the with_send scope" do
          expect(scope).not_to receive(:with_send)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the with_send scope" do
          expect(scope).not_to receive(:with_send)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "multiple filters" do
      let(:filter) { { study_type: "part_time", funding: "salary" } }
      let(:salary_scope) { double }
      let(:expected_scope) { double }

      it "combines scopes" do
        expect(scope).to receive(:with_salary).and_return(salary_scope)
        expect(salary_scope).to receive(:with_study_modes).with(%w(part_time)).and_return(course_ids_scope)
        expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
        expect(course_with_includes).to receive(:where).and_return(expected_scope)
        expect(subject).to eq(expected_scope)
      end
    end

    describe "filter[can_sponsor_visa]" do
      context "when true" do
        let(:filter) { { can_sponsor_visa: true } }
        let(:expected_scope) { double }

        it "adds the provider_can_sponsor_visa scope" do
          expect(scope).to receive(:provider_can_sponsor_visa).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when false" do
        let(:filter) { { can_sponsor_visa: false } }

        it "adds the provider_can_sponsor_visa scope" do
          expect(scope).not_to receive(:provider_can_sponsor_visa)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the provider_can_sponsor_visa scope" do
          expect(scope).not_to receive(:provider_can_sponsor_visa)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end
  end
end
# rubocop:enable RSpec/StubbedMock
