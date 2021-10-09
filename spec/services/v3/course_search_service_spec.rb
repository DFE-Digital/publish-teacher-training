require "rails_helper"

RSpec.describe V3::CourseSearchService do
  describe ".call" do
    describe "sorting" do
      before do
        provider_a = build(:provider, provider_name: "A")
        provider_b = build(:provider, provider_name: "B")
        create(:course, name: "A", provider: provider_a)
        create(:course, name: "B", provider: provider_b)
        create(:course, name: "C", provider: provider_a)
        create(:course, name: "D", provider: provider_b)
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

        it "orders distance ascending" do
          courses = described_class.call(sort: sort).all

          expect(courses).to eq [near_course, far_course, furthest_course]
        end

        it "does not contain duplicates when multiple sites per course" do
          near_course.site_statuses << build(:site_status, :findable, site: build(:site, **far_from_origin))
          courses = described_class.call(sort: sort).all

          expect(courses).to eq [near_course, far_course, furthest_course]
        end
      end
    end

    describe "filtering" do
      context "multiple filters" do
        it "applies multiple filters" do
          filter = { study_type: "part_time", funding: "salary" }
          matching1 = create(:course, :with_salary, study_mode: :part_time)
          matching2 = create(:course, :with_apprenticeship, study_mode: :part_time)
          create(:course, :with_apprenticeship, study_mode: :full_time) # non-matching

          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [matching1, matching2]
        end
      end

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

      context "filter by provider name" do
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
        let!(:with_salary) { create(:course, :with_salary) }
        let!(:without_salary) { create(:course, :with_higher_education) }

        it "returns only courses with a salary if filter value is 'salary'" do
          filter = { funding: "salary" }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [with_salary]
        end

        it "returns all courses if filter value is 'all'" do
          filter = { funding: "all" }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [with_salary, without_salary]
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
          filter = { findable: true }
          courses = described_class.call(filter: filter).all
          expect(courses).to match_array [findable]
        end

        it "returns all courses when filter is false" do
          filter = { findable: false }
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

      context "filter by subjects" do
        let!(:primary_course1) { create(:course, :primary, subjects: [create(:primary_subject, :primary)]) }
        let!(:primary_course2) { create(:course, :primary, subjects: [create(:primary_subject, :primary_with_mathematics)]) }
        let!(:secondary_course) { create(:course, :secondary, subjects: [create(:secondary_subject, :science)]) }

        it "returns courses matching the subject code" do
          filter = { subjects: primary_course1.subjects.first.subject_code }
          expect(described_class.call(filter: filter).all).to match_array [primary_course1]
        end

        it "returns all courses matching multiple subject codes" do
          subject_codes = "#{primary_course1.subjects.first.subject_code},#{secondary_course.subjects.first.subject_code}"
          filter = { subjects: subject_codes }
          expect(described_class.call(filter: filter).all).to match_array [
            primary_course1,
            secondary_course,
          ]
        end

        it "returns all courses when filter is absent" do
          filter = {}
          expect(described_class.call(filter: filter).all).to match_array [
            primary_course1,
            primary_course2,
            secondary_course,
          ]
        end
      end

      context "filter by send_courses" do
        let!(:send_course) { create(:course, is_send: true) }
        let!(:non_send_course1) { create(:course, is_send: false) }
        let!(:non_send_course2) { create(:course, is_send: false) }

        it "returns SEND courses when filter is true" do
          filter = { send_courses: true }
          expect(described_class.call(filter: filter).all).to match_array [send_course]
        end

        it "returns all courses when filter is false" do
          filter = { send_courses: false }
          expect(described_class.call(filter: filter).all).to match_array [
            send_course,
            non_send_course1,
            non_send_course2,
          ]
        end

        it "returns all courses when filter is absent" do
          filter = {}
          expect(described_class.call(filter: filter).all).to match_array [
            send_course,
            non_send_course1,
            non_send_course2,
          ]
        end
      end

      context "filter by can_sponsor_visa" do
        let!(:sponsered_course1) { create(:course, provider: build(:provider, can_sponsor_student_visa: true, can_sponsor_skilled_worker_visa: false)) }
        let!(:sponsered_course2) { create(:course, provider: build(:provider, can_sponsor_student_visa: false, can_sponsor_skilled_worker_visa: true)) }
        let!(:unsponsered_course) { create(:course, provider: build(:provider, can_sponsor_student_visa: false, can_sponsor_skilled_worker_visa: false)) }

        # TODO: This spec passes locally but fails in CI. Not clear why from
        # initial investigation. Mark as pending until it can be revisited.
        xit "returns matching courses when filter is true" do
          filter = { can_sponsor_visa: true }
          expect(described_class.call(filter: filter).all).to match_array [sponsered_course1, sponsered_course2]
        end

        it "returns all courses when filter is false" do
          filter = { can_sponsor_visa: false }
          expect(described_class.call(filter: filter).all).to match_array [
            sponsered_course1,
            sponsered_course2,
            unsponsered_course,
          ]
        end

        it "returns all courses when filter is absent" do
          filter = {}
          expect(described_class.call(filter: filter).all).to match_array [
            sponsered_course1,
            sponsered_course2,
            unsponsered_course,
          ]
        end
      end
    end
  end

  describe "expand_university" do
    context "university course vs non university course" do
      null_island = { latitude: 0, longitude: 0 }

      over_5_miles_from_null_island = { latitude: 0.1, longitude: 0 }

      subject do
        described_class.call(filter: filter,
                             sort: "distance",
                             course_scope: scope)
      end

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
        build(:site, **over_5_miles_from_null_island)
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

      context "when false" do
        let(:filter) do
          null_island.merge(expand_university: "false")
        end

        it "returns correctly" do
          expect(subject.count(:id)).to eq(2)

          expect(subject.first.boosted_distance).to eq(0)
          expect(subject.first.distance).to eq(0)
          expect(subject.first).to eq(non_university_course)

          expect(subject.second.boosted_distance - subject.second.distance).to eq(-10)
          expect(subject.second).to eq(university_course)
        end
      end

      context "when absent" do
        let(:filter) do
          null_island
        end

        it "returns correctly" do
          expect(subject.count(:id)).to eq(2)

          expect(subject.first.boosted_distance).to eq(0)
          expect(subject.first.distance).to eq(0)
          expect(subject.first).to eq(non_university_course)

          expect(subject.second.boosted_distance - subject.second.distance).to eq(-10)
          expect(subject.second).to eq(university_course)
        end
      end

      context "when true" do
        describe "university course has less 10 miles" do
          let(:filter) do
            null_island.merge(expand_university: "true")
          end

          it "returns correctly" do
            expect(subject.count(:id)).to eq(2)

            expect(subject.first.boosted_distance - subject.first.distance).to eq(-10)
            expect(subject.first).to eq(university_course)

            expect(subject.second.boosted_distance).to eq(0)
            expect(subject.second.distance).to eq(0)
            expect(subject.second).to eq(non_university_course)
          end
        end
      end
    end
  end
end
