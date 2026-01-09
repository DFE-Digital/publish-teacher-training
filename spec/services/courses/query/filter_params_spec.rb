# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:results) { described_class.call(params:) }

  context "when no filters or sorting are applied" do
    let!(:findable_course) { create(:course, :with_full_time_sites) }
    let!(:another_course) { create(:course, :with_full_time_sites) }
    let!(:non_findable_course) { create(:course) }

    let(:params) { {} }

    it "returns all findable courses" do
      expect(results).to contain_exactly(findable_course, another_course)
    end
  end

  context "when filter for interview location (online)" do
    let!(:course_with_online_interviews) do
      create(:course, :with_full_time_sites, name: "Course Online").tap do |course|
        create(:course_enrichment, :published, course:, interview_location: "online")
      end
    end

    let!(:course_with_both_interviews) do
      create(:course, :with_full_time_sites, name: "Course Both").tap do |course|
        create(:course_enrichment, :published, course:, interview_location: "both")
      end
    end

    let!(:course_in_person_only) do
      create(:course, :with_full_time_sites, name: "Course In person").tap do |course|
        create(:course_enrichment, :published, course:, interview_location: "in person")
      end
    end

    let!(:course_without_published_enrichment) do
      create(:course, :with_full_time_sites, name: "Course Draft only").tap do |course|
        create(:course_enrichment, :initial_draft, course:, interview_location: "online")
      end
    end

    let(:params) { { interview_location: "online" } }

    it "returns courses whose latest published enrichment offers online or both" do
      expect(results).to match_collection(
        [course_with_both_interviews, course_with_online_interviews],
        attribute_names: %w[name],
      )
    end

    it "excludes courses with only in-person interviews or no published enrichment" do
      expect(results).not_to include(course_in_person_only)
      expect(results).not_to include(course_without_published_enrichment)
    end
  end

  context "when filter for visa sponsorship" do
    let!(:course_that_sponsor_visa) do
      create(:course, :with_full_time_sites, :can_sponsor_skilled_worker_visa, name: "Art and design")
    end
    let!(:another_course_that_sponsor_visa) do
      create(:course, :with_full_time_sites, :can_sponsor_student_visa, name: "Biology")
    end
    let!(:another_course_that_sponsor_all_visas) do
      create(:course, :with_full_time_sites, :can_sponsor_student_visa, :can_sponsor_skilled_worker_visa, name: "Computing")
    end
    let!(:course_that_does_not_sponsor_visa) do
      create(:course, :with_full_time_sites, can_sponsor_skilled_worker_visa: false, can_sponsor_student_visa: false, name: "Drama")
    end

    let(:params) { { can_sponsor_visa: "true" } }

    it "returns courses that sponsor visa" do
      expect(results).to match_collection(
        [course_that_sponsor_visa, another_course_that_sponsor_visa, another_course_that_sponsor_all_visas],
        attribute_names: %w[can_sponsor_skilled_worker_visa can_sponsor_student_visa],
      )
    end
  end

  context "when filter for engineers teach physics" do
    let!(:biology_course) do
      create(
        :course,
        :with_full_time_sites,
        :secondary,
        name: "Biology",
        course_code: "S872",
        subjects: [find_or_create(:secondary_subject, :biology)],
      )
    end
    let!(:physics_course) do
      create(
        :course,
        :with_full_time_sites,
        :secondary,
        name: "Physics",
        course_code: "P45D",
        subjects: [find_or_create(:secondary_subject, :physics)],
      )
    end
    let!(:engineers_teach_physics_course) do
      create(
        :course,
        :with_full_time_sites,
        :secondary,
        :engineers_teach_physics,
        name: "Engineers teach physics",
        course_code: "ETP1",
        subjects: [find_or_create(:secondary_subject, :physics)],
      )
    end

    let(:params) { { engineers_teach_physics: true } }

    it "returns courses that sponsor visa" do
      expect(results).to match_collection(
        [engineers_teach_physics_course],
        attribute_names: %w[id name campaign_name],
      )
    end
  end

  context "when filter by subject code" do
    let!(:biology) do
      create(:course, :with_full_time_sites, :secondary, name: "Biology", subjects: [find_or_create(:secondary_subject, :biology)])
    end
    let!(:chemistry) do
      create(:course, :with_full_time_sites, :secondary, name: "Chemistry", subjects: [find_or_create(:secondary_subject, :chemistry)])
    end
    let!(:mathematics) do
      create(:course, :with_full_time_sites, :secondary, name: "Mathematics", subjects: [find_or_create(:secondary_subject, :mathematics)])
    end

    let(:params) { { subject_code: "C1" } }

    it "returns courses that match the given subject code" do
      expect(results).to match_collection(
        [biology],
        attribute_names: %w[name],
      )
    end
  end

  context "when filter by subject code and subjects" do
    let!(:biology) do
      create(:course, :with_full_time_sites, :secondary, name: "Biology", subjects: [find_or_create(:secondary_subject, :biology)])
    end
    let!(:chemistry) do
      create(:course, :with_full_time_sites, :secondary, name: "Chemistry", subjects: [find_or_create(:secondary_subject, :chemistry)])
    end
    let!(:mathematics) do
      create(:course, :with_full_time_sites, :secondary, name: "Mathematics", subjects: [find_or_create(:secondary_subject, :mathematics)])
    end

    let(:params) { { subjects: %w[F1], subject_code: "C1" } }

    it "returns courses that match both the given subject code and subjects" do
      expect(results).to match_collection(
        [biology, chemistry],
        attribute_names: %w[name],
      )
    end
  end

  context "when filter by secondary subjects" do
    let!(:biology) do
      create(:course, :with_full_time_sites, :secondary, name: "Biology", subjects: [find_or_create(:secondary_subject, :biology)])
    end
    let!(:chemistry) do
      create(:course, :with_full_time_sites, :secondary, name: "Chemistry", subjects: [find_or_create(:secondary_subject, :chemistry)])
    end
    let!(:mathematics) do
      create(:course, :with_full_time_sites, :secondary, name: "Mathematics", subjects: [find_or_create(:secondary_subject, :mathematics)])
    end

    let(:params) { { subjects: %w[C1 F1] } }

    it "returns specific secondary courses" do
      expect(results).to match_collection(
        [biology, chemistry],
        attribute_names: %w[name],
      )
    end
  end

  context "when filter by study mode" do
    let!(:full_time_course) do
      create(:course, :with_full_time_sites, study_mode: "full_time", name: "Biology", course_code: "S872")
    end
    let!(:part_time_course) do
      create(:course, :with_part_time_sites, study_mode: "part_time", name: "Chemistry", course_code: "K592")
    end
    let!(:full_time_or_part_time_course) do
      create(:course, :with_full_time_or_part_time_sites, study_mode: "full_time_or_part_time", name: "Computing", course_code: "L364")
    end

    context "when filter by full time only" do
      let(:params) { { study_types: %w[full_time] } }

      it "returns full time courses only" do
        expect(results).to match_collection(
          [full_time_course, full_time_or_part_time_course],
          attribute_names: %w[study_mode],
        )
      end
    end

    context "when filter by part time only" do
      let(:params) { { study_types: %w[part_time] } }

      it "returns part time courses only" do
        expect(results).to match_collection(
          [part_time_course, full_time_or_part_time_course],
          attribute_names: %w[study_mode],
        )
      end
    end

    context "when filter by full time and part time" do
      let(:params) { { study_types: %w[full_time part_time] } }

      it "returns full time and part time courses" do
        expect(results).to match_collection(
          [full_time_course, part_time_course, full_time_or_part_time_course],
          attribute_names: %w[study_mode],
        )
      end
    end

    context "when pass invalid parameter" do
      let(:params) { { study_types: "something" } }

      it "returns full time and part time courses" do
        expect(results).to match_collection(
          [full_time_course, part_time_course, full_time_or_part_time_course],
          attribute_names: %w[study_mode],
        )
      end
    end
  end

  context "when filter by qualifications" do
    let!(:qts_course) do
      create(:course, :with_full_time_sites, qualification: "qts", name: "Art and design")
    end
    let!(:pgce_with_qts_course) do
      create(:course, :with_full_time_sites, qualification: "pgce_with_qts", name: "Biology")
    end
    let!(:pgde_with_qts_course) do
      create(:course, :with_full_time_sites, qualification: "pgde_with_qts", name: "Computing")
    end
    let!(:course_without_qts) do
      create(:course, :with_full_time_sites, qualification: "undergraduate_degree_with_qts", name: "Drama")
    end

    context "when filter by qts" do
      let(:params) { { qualifications: %w[qts] } }

      it "returns courses with qts qualification only" do
        expect(results).to match_collection(
          [qts_course],
          attribute_names: %w[qualification],
        )
      end
    end

    context "when filter by qts with pgce or pgde" do
      let(:params) { { qualifications: %w[qts_with_pgce_or_pgde] } }

      it "returns courses with qts and pgce/pgde qualifications" do
        expect(results).to match_collection(
          [pgce_with_qts_course, pgde_with_qts_course],
          attribute_names: %w[qualification],
        )
      end
    end

    context "when filter by qts with pgce (for backwards compatibility)" do
      let(:params) { { qualifications: %w[qts_with_pgce] } }

      it "returns courses with qts and pgce/pgde qualifications" do
        expect(results).to match_collection(
          [pgce_with_qts_course, pgde_with_qts_course],
          attribute_names: %w[qualification],
        )
      end
    end
  end

  context "when filter for further education" do
    let!(:further_education_course) do
      create(:course, :with_full_time_sites, level: "further_education")
    end
    let!(:regular_course) do
      create(:course, :with_full_time_sites, level: "secondary")
    end
    let(:params) { { level: "further_education" } }

    it "returns courses for further education only" do
      expect(results).to match_collection(
        [further_education_course],
        attribute_names: %w[level],
      )
    end
  end

  context "when filter for applications open" do
    let!(:course_opened) do
      create(:course, :with_full_time_sites, :open)
    end
    let!(:course_closed) do
      create(:course, :with_full_time_sites, :closed)
    end
    let(:params) { { applications_open: "true" } }

    it "returns courses that sponsor visa" do
      expect(results).to match_collection(
        [course_opened],
        attribute_names: %w[application_status],
      )
    end
  end

  context "when filter for special education needs" do
    let!(:course_with_special_education_needs) do
      create(:course, :with_full_time_sites, :with_special_education_needs)
    end
    let!(:course_with_no_special_education_needs) do
      create(:course, :with_full_time_sites, is_send: false)
    end
    let(:params) { { send_courses: "true" } }

    it "returns courses that sponsor visa" do
      expect(results).to match_collection(
        [course_with_special_education_needs],
        attribute_names: %w[is_send],
      )
    end
  end

  context "when filter by degree grade requirements" do
    let!(:requires_two_one_course) do
      create(:course, :published_postgraduate, degree_grade: "two_one", name: "Art and design")
    end
    let!(:requires_two_two_course) do
      create(:course, :published_postgraduate, degree_grade: "two_two", name: "Biology")
    end
    let!(:requires_third_class_course) do
      create(:course, :published_postgraduate, degree_grade: "third_class", name: "Computing")
    end
    let!(:requires_pass_degree) do
      create(:course, :published_postgraduate, degree_grade: "not_required", name: "Drama")
    end
    let!(:undergraduate_does_not_require_degree_course) do
      create(:course, :published_teacher_degree_apprenticeship, degree_grade: "not_required", name: "Mathematics")
    end

    context "when filter by two_one" do
      let(:params) { { minimum_degree_required: "two_one" } }

      it "returns courses requiring two_one or lower" do
        expect(results).to match_collection(
          [requires_two_one_course, requires_two_two_course, requires_third_class_course, requires_pass_degree],
          attribute_names: %w[name degree_grade degree_type],
        )
      end
    end

    context "when filter by two_two" do
      let(:params) { { minimum_degree_required: "two_two" } }

      it "returns courses requiring two_two or lower" do
        expect(results).to match_collection(
          [requires_two_two_course, requires_third_class_course, requires_pass_degree],
          attribute_names: %w[name degree_grade degree_type],
        )
      end
    end

    context "when filter by third class" do
      let(:params) { { minimum_degree_required: "third_class" } }

      it "returns courses requiring a third class degree or lower" do
        expect(results).to match_collection(
          [requires_third_class_course, requires_pass_degree],
          attribute_names: %w[name degree_grade degree_type],
        )
      end
    end

    context "when filter by pass" do
      let(:params) { { minimum_degree_required: "pass" } }

      it "returns courses requiring a pass degree" do
        expect(results).to match_collection(
          [requires_pass_degree],
          attribute_names: %w[name degree_grade degree_type],
        )
      end
    end

    context "when filter by not requiring a degree" do
      let(:params) { { minimum_degree_required: "no_degree_required" } }

      it "returns courses that do not require a degree" do
        expect(results).to match_collection(
          [undergraduate_does_not_require_degree_course],
          attribute_names: %w[name degree_grade degree_type],
        )
      end
    end
  end

  context "when filter by funding" do
    let!(:fee_course) do
      create(:course, :with_full_time_sites, funding: "fee", name: "Art and design")
    end
    let!(:salaried_course) do
      create(:course, :with_full_time_sites, funding: "salary", name: "Biology")
    end
    let!(:apprenticeship_course) do
      create(:course, :with_full_time_sites, funding: "apprenticeship", name: "Computing")
    end

    context "when filter by fee" do
      let(:params) { { funding: %w[fee] } }

      it "returns courses with fees only" do
        expect(results).to match_collection(
          [fee_course],
          attribute_names: %w[funding],
        )
      end
    end

    context "when filter by salary" do
      let(:params) { { funding: %w[salary] } }

      it "returns courses with salary" do
        expect(results).to match_collection(
          [salaried_course],
          attribute_names: %w[funding],
        )
      end
    end

    context "when filter by apprenticeship" do
      let(:params) { { funding: %w[apprenticeship] } }

      it "returns courses with apprenticeship" do
        expect(results).to match_collection(
          [apprenticeship_course],
          attribute_names: %w[funding],
        )
      end
    end

    context "when filter by salary in the old search parameter" do
      let(:params) { { funding: "salary" } }

      it "returns courses with salary" do
        expect(results).to match_collection(
          [salaried_course],
          attribute_names: %w[funding],
        )
      end
    end

    context "when filter by two funding types" do
      let(:params) { { funding: %w[fee salary] } }

      it "returns courses with the expected funding types" do
        expect(results).to match_collection(
          [fee_course, salaried_course],
          attribute_names: %w[funding],
        )
      end
    end

    context "when filter by all funding types" do
      let(:params) { { funding: %w[fee salary apprenticeship] } }

      it "returns all courses" do
        expect(results).to match_collection(
          [fee_course, salaried_course, apprenticeship_course],
          attribute_names: %w[funding],
        )
      end
    end
  end

  context "when searching by start date" do
    let(:current_recruitment_cycle_year) { RecruitmentCycle.current.year.to_i }
    let(:next_recruitment_cycle_year) { current_recruitment_cycle_year + 1 }
    let!(:january_course) do
      create(:course, :with_full_time_sites, name: "Art and design", start_date: Time.zone.local(current_recruitment_cycle_year, 1, 1))
    end
    let!(:august_course) do
      create(:course, :with_full_time_sites, name: "Biology", start_date: Time.zone.local(current_recruitment_cycle_year, 8, 1))
    end
    let!(:beginning_of_september_course) do
      create(:course, :with_full_time_sites, name: "Computing", start_date: Time.zone.local(current_recruitment_cycle_year, 9, 1))
    end
    let!(:middle_of_september_course) do
      create(:course, :with_full_time_sites, name: "English", start_date: Time.zone.local(current_recruitment_cycle_year, 9, 15))
    end
    let!(:end_of_september_course) do
      create(:course, :with_full_time_sites, name: "Primary with english", start_date: Time.zone.local(current_recruitment_cycle_year, 9, 30))
    end
    let!(:october_course) do
      create(:course, :with_full_time_sites, name: "Spanish", start_date: Time.zone.local(current_recruitment_cycle_year, 10, 1))
    end
    let!(:next_year_january_course) do
      create(:course, :with_full_time_sites, name: "Mathematics", start_date: Time.zone.local(next_recruitment_cycle_year, 1, 15))
    end
    let!(:next_year_july_course) do
      create(:course, :with_full_time_sites, name: "Physics", start_date: Time.zone.local(next_recruitment_cycle_year, 7, 31))
    end

    context "when searching for january to august courses" do
      let(:params) { { start_date: %w[jan_to_aug] } }

      it "returns courses that start between January and August" do
        expect(results).to match_collection(
          [
            january_course,
            august_course,
          ],
          attribute_names: %w[id name start_date],
        )
      end
    end

    context "when searching for only september courses" do
      let(:params) { { start_date: %w[september] } }

      it "returns courses that starts in september" do
        expect(results).to match_collection(
          [
            beginning_of_september_course,
            middle_of_september_course,
            end_of_september_course,
          ],
          attribute_names: %w[id name start_date],
        )
      end
    end

    context "when searching for october to july courses" do
      let(:params) { { start_date: %w[oct_to_jul] } }

      it "returns courses that start between October and July of the following year" do
        expect(results).to contain_exactly(
          october_course,
          next_year_january_course,
          next_year_july_course,
        )
      end
    end

    context "when searching for all options" do
      let(:params) { { start_date: %w[jan_to_aug september oct_to_jul] } }

      it "returns all courses" do
        expect(results).to contain_exactly(
          january_course,
          august_course,
          beginning_of_september_course,
          middle_of_september_course,
          end_of_september_course,
          october_course,
          next_year_january_course,
          next_year_july_course,
        )
      end
    end

    context "when searching for invalid start date value" do
      let(:params) { { start_date: %w[something] } }

      it "returns all courses" do
        expect(results).to contain_exactly(
          january_course,
          august_course,
          beginning_of_september_course,
          middle_of_september_course,
          end_of_september_course,
          october_course,
          next_year_january_course,
          next_year_july_course,
        )
      end
    end
  end
end
