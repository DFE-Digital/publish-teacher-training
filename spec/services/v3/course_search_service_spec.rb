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

        it "returns all courses if filter is absent" do
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

        it "returns all courses if filter is absent" do
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

        it "returns all courses when filter is absent" do
          filter = {}
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [full_time_vacancies, part_time_vacancies, no_vacancies]
        end
      end

      context "filter by findable" do
        let!(:findable) { create(:course, site_statuses: [build(:site_status, :findable)]) }
        let!(:not_findable) { create(:course, site_statuses: [build(:site_status, :unpublished)]) }

        it "returns only findable courses when filter is true" do
          filter = { has_vacancies: true }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [findable]
        end

        it "returns all courses when filter is false" do
          filter = { has_vacancies: false }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [findable, not_findable]
        end

        it "returns all courses when filter is absent" do
          filter = {}
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [findable, not_findable]
        end
      end

      context "filter by study_type" do
        let!(:full_time) { create(:course, study_mode: :full_time) }
        let!(:part_time) { create(:course, study_mode: :part_time) }

        it "returns full_time courses when study_type is full_time" do
          filter = { study_type: "full_time" }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [full_time]
        end

        it "returns part_time courses when study_type is part_time" do
          filter = { study_type: "part_time" }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [part_time]
        end

        it "returns all courses when both study types are present" do
          filter = { study_type: "full_time,part_time" }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [full_time, part_time]
        end

        it "returns all courses when filter is absent" do
          filter = {}
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [full_time, part_time]
        end
      end

      context "filter by funding_type" do
        let!(:fee) { create(:course, :fee_type_based) }
        let!(:salary) { create(:course, :with_salary) }
        let!(:apprenticeship) { create(:course, :with_apprenticeship) }

        it "returns fee courses if funding_type is fee" do
          filter = { funding_type: "fee" }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [fee]
        end

        it "returns salary courses if funding_type is salary" do
          filter = { funding_type: "salary" }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [salary]
        end

        it "returns apprenticeship courses if funding_type is apprenticeship" do
          filter = { funding_type: "apprenticeship" }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [apprenticeship]
        end

        it "returns all courses if all funding types present" do
          filter = { funding_type: "fee,salary,apprenticeship" }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [fee, salary, apprenticeship]
        end

        it "returns all courses if filter is absent" do
          filter = {}
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [fee, salary, apprenticeship]
        end
      end

      context "filter by degree_grade" do
        let!(:two_one) { create(:course, degree_grade: :two_one) }
        let!(:two_two) { create(:course, degree_grade: :two_two) }
        let!(:third) { create(:course, degree_grade: :third_class) }
        let!(:not_required) { create(:course, degree_grade: :not_required) }

        it "returns two_two courses when degree_grade is two_two" do
          filter = { degree_grade: "two_two" }
          expect(described_class.call(filter: filter).all).to match_array [two_two]
        end

        it "returns not_required courses when degree_grade is not_required" do
          filter = { degree_grade: "not_required" }
          expect(described_class.call(filter: filter).all).to match_array [not_required]
        end

        it "returns all courses when degree_grade is all grades" do
          filter = { degree_grade: "two_one,two_two,third_class,not_required" }
          expect(described_class.call(filter: filter).all).to match_array(
            [two_one, two_two, third, not_required],
          )
        end

        it "returns all courses when degree_grade is absent" do
          filter = {}
          expect(described_class.call(filter: filter).all).to match_array(
            [two_one, two_two, third, not_required],
          )
        end
      end
    end
  end

  xdescribe "old .call" do
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
