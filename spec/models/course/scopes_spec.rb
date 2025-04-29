# frozen_string_literal: true

require "rails_helper"

describe Course, ".scopes" do
  describe "scopes" do
    subject { course }

    let(:recruitment_cycle) { course.recruitment_cycle }
    let(:french) { find_or_create(:modern_languages_subject, :french) }
    let!(:financial_incentive) { create(:financial_incentive, subject: modern_languages) }
    let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
    let(:course) do
      create(
        :course,
        level: "secondary",
        name: "Biology",
        course_code: "3X9F",
        subjects: [find_or_create(:secondary_subject, :biology)],
      )
    end

    describe "canonical" do
      let(:provider_a) { create(:provider, provider_name: "Provider A") }
      let(:course_a) do
        create(:course,
               name: "Course A",
               course_code: "AAA",
               provider: provider_a)
      end

      let(:another_course_a) do
        create(:course,
               name: "Course A",
               course_code: "BBB",
               provider: provider_a)
      end

      let(:course_a_with_provider_b) do
        create(:course,
               name: "Course A",
               course_code: "AAA",
               provider: provider_b)
      end

      let(:course_a_with_provider_b_with_different_course_code) do
        create(:course,
               name: "Course A",
               course_code: "AAB",
               provider: provider_b)
      end

      let(:course_b) do
        create(
          :course,
          name: "Course B",
          provider: provider_a,
        )
      end

      let(:provider_b) { create(:provider, provider_name: "Provider B") }
      let(:course_c) do
        create(
          :course,
          name: "Course C",
          provider: provider_b,
        )
      end

      let(:course_d) do
        create(
          :course,
          name: "Course D",
          provider: provider_b,
        )
      end

      before do
        course_a
        course_b
        course_c
        course_d
      end

      describe ".ascending_provider_canonical_order" do
        subject { described_class.ascending_provider_canonical_order }

        it "sorts in ascending order of provider name and course name" do
          expect(subject).to eq([course_a, course_b, course_c, course_d])
        end

        context "when there are multiple courses with the same name" do
          before { another_course_a }

          it "sorts by course_code" do
            expect(subject).to eq([course_a, another_course_a, course_b, course_c, course_d])
          end
        end
      end

      describe ".descending_provider_canonical_order" do
        subject { described_class.descending_provider_canonical_order }

        it "sorts in descending order of provider name" do
          expect(subject).to eq([course_c, course_d, course_a, another_course_a, course_b])
        end

        context "when there are multiple courses with the same name" do
          before { another_course_a }

          it "sorts by course_code" do
            expect(subject).to eq([course_c, course_d, course_a, another_course_a, course_b])
          end
        end
      end

      describe ".ascending_course_canonical_order" do
        subject { described_class.ascending_course_canonical_order }

        it "sorts in ascending order of course name" do
          expect(subject).to eq([course_a, course_b, course_c, course_d])
        end

        context "when there are multiple courses with the same name" do
          before do
            course_a_with_provider_b
            another_course_a
          end

          it "sorts by provider_name" do
            expect(subject).to eq([course_a, another_course_a, course_a_with_provider_b, course_b, course_c, course_d])
          end

          context "when there are multiple providers with the same name" do
            before { course_a_with_provider_b_with_different_course_code }

            it "sorts by course_code" do
              expect(subject).to eq([course_a,
                                     another_course_a,
                                     course_a_with_provider_b,
                                     course_a_with_provider_b_with_different_course_code,
                                     course_b,
                                     course_c,
                                     course_d])
            end
          end
        end
      end

      describe ".descending_course_canonical_order" do
        subject { described_class.descending_course_canonical_order }

        it "sorts in descending order of course name" do
          expect(subject).to eq([course_d, course_c, course_b, course_a])
        end

        context "when there are multiple courses with the same name" do
          before do
            course_a_with_provider_b
            another_course_a
          end

          it "sorts by provider_name" do
            expect(subject).to eq([course_d, course_c, course_b, course_a, another_course_a, course_a_with_provider_b])
          end

          context "when there are multiple providers with the same name" do
            before { course_a_with_provider_b_with_different_course_code }

            it "sorts by course_code" do
              expect(subject).to eq([course_d,
                                     course_c,
                                     course_b,
                                     course_a,
                                     another_course_a,
                                     course_a_with_provider_b,
                                     course_a_with_provider_b_with_different_course_code])
            end
          end
        end
      end
    end

    describe ".accredited_provider_order" do
      subject { described_class.accredited_provider_order(provider.provider_name) }

      let(:provider) { create(:provider) }
      let!(:delivered_course) { create(:course, provider:) }
      let!(:accredited_course) { create(:course, accrediting_provider: provider) }

      it "returns courses accredited after courses delivered" do
        expect(subject).to eq([delivered_course, accredited_course])
      end
    end

    describe "case_insensitive_search" do
      subject { described_class.case_insensitive_search("2vVZ") }

      let(:course) { create(:course, course_code: "2VvZ") }

      it "returns correct course with incorrect" do
        expect(subject).to eq([course])
      end
    end

    describe ".by_name_(ascending|descending)" do
      let(:course_a) do
        create(:course, name: "Course A")
      end

      let(:course_b) do
        create(:course, name: "Course B")
      end

      before do
        course_a
        course_b
      end

      describe ".by_name_ascending" do
        it "sorts in ascending order of provider name" do
          expect(described_class.by_name_ascending).to eq([course_a, course_b])
        end
      end

      describe ".by_name_descending" do
        it "sorts in descending order of provider name" do
          expect(described_class.by_name_descending).to eq([course_b, course_a])
        end
      end
    end

    describe ".changed_since" do
      context "with no parameters" do
        subject { described_class.changed_since(nil) }

        let!(:old_course) { create(:course, age: 1.hour.ago) }
        let!(:course) { create(:course, age: 1.hour.ago) }

        it { is_expected.to include course }
        it { is_expected.to include old_course }
      end

      context "with a course that was just updated" do
        subject { described_class.changed_since(10.minutes.ago) }

        let(:course) { create(:course, age: 1.hour.ago) }
        let!(:old_course) { create(:course, age: 1.hour.ago) }

        before { course.touch }

        it { is_expected.to include course }
        it { is_expected.not_to include old_course }
      end

      context "with a course that has been changed less than a second after the given timestamp" do
        subject { described_class.changed_since(timestamp) }

        let(:timestamp) { 5.minutes.ago }
        let(:course) { create(:course, changed_at: timestamp + 0.001.seconds) }

        it { is_expected.to include course }
      end

      context "with a course that has been changed exactly at the given timestamp" do
        subject { described_class.changed_since(timestamp) }

        let(:timestamp) { 10.minutes.ago }
        let(:course) { create(:course, changed_at: timestamp) }

        it { is_expected.not_to include course }
      end
    end

    describe ".within" do
      let(:published_enrichment) { build(:course_enrichment, :published) }
      let(:enrichments) { [published_enrichment] }
      let(:course_a) do
        create(
          :course,
          enrichments:,
          site_statuses: [
            build(:site_status, :findable, site: build(:site, longitude: 0, latitude: 0)),
          ],
        )
      end

      let(:course_b) do
        create(
          :course,
          enrichments:,
          site_statuses: [
            build(:site_status, :findable, site: build(:site, longitude: 32, latitude: 32)),
          ],
        )
      end

      it "returns courses in range" do
        course_a
        course_b
        courses_within_range = described_class.within(16, origin: [0, 0])

        expect(courses_within_range.count).to eq(1)
        expect(described_class.within(16, origin: [0, 0])).to contain_exactly(course_a)
      end
    end

    describe ".published" do
      subject { described_class.published }

      let(:test_course) { create(:course, enrichments:) }

      before do
        test_course
      end

      context "when initial draft course" do
        let(:enrichments) { [build(:course_enrichment, :initial_draft)] }

        it "is not returned" do
          expect(subject).to be_empty
        end
      end

      context "when draft course" do
        let(:enrichments) { [build(:course_enrichment)] }

        it "is not returned" do
          expect(subject).to be_empty
        end
      end

      context "when rolled over course" do
        let(:enrichments) { [build(:course_enrichment, :rolled_over)] }

        it "is not returned" do
          expect(subject).to be_empty
        end
      end

      context "when published" do
        let(:enrichments) { [build(:course_enrichment, :published)] }

        it "is returned" do
          expect(subject).to contain_exactly(test_course)
        end
      end

      context "when there are multiple enrichments" do
        context "published is present" do
          let(:enrichments) { [build(:course_enrichment, :published)] }

          before do
            test_course.enrichments << build(:course_enrichment, :withdrawn)
          end

          it "is returned" do
            expect(subject).to contain_exactly(test_course)
          end
        end

        context "and published not present" do
          let(:enrichments) { [build(:course_enrichment, :withdrawn)] }

          before do
            test_course.enrichments << build(:course_enrichment, :initial_draft)
          end

          it "is not returned" do
            expect(subject).to be_empty
          end
        end
      end
    end

    describe ".with_recruitment_cycle" do
      subject { described_class.with_recruitment_cycle(provider.recruitment_cycle.year) }

      let(:test_course) { create(:course, provider:) }

      before { test_course }

      context "course is in recruitment cycle" do
        let(:provider) { create(:provider) }

        it "is returned" do
          expect(subject).to contain_exactly(test_course)
        end
      end

      context "course is not in recruitment cycle" do
        let(:provider) { create(:provider, :next_recruitment_cycle) }

        it "is not returned" do
          expect(subject).to contain_exactly(test_course)
        end
      end
    end

    describe ".findable" do
      subject { described_class.findable }

      let(:test_course) { create(:course, site_statuses:) }

      before { test_course }

      context "course is findable" do
        let(:site_statuses) do
          [
            build(:site_status, :findable),
          ]
        end

        it "is returned" do
          expect(subject).to contain_exactly(test_course)
        end
      end

      context "course is not findable" do
        let(:site_statuses) do
          [
            build(:site_status),
          ]
        end

        it "is not returned" do
          expect(subject).to be_empty
        end
      end
    end

    describe ".with_vacancies" do
      subject { described_class.with_vacancies }

      let(:test_course) { create(:course, site_statuses:) }

      before { test_course }

      context "course has vacancies" do
        let(:site_statuses) do
          [
            build(:site_status, :with_any_vacancy, :findable),
          ]
        end

        it "is returned" do
          expect(subject).to contain_exactly(test_course)
        end
      end

      context "course has no vacancies" do
        let(:site_statuses) do
          [
            build(:site_status, :no_vacancies, :findable),
          ]
        end

        it "is not returned" do
          expect(subject).to be_empty
        end
      end

      context "course is not findable" do
        let(:site_statuses) do
          [
            build(:site_status, :with_any_vacancy),
          ]
        end

        it "is not returned" do
          expect(subject).to be_empty
        end
      end
    end

    describe ".with_study_modes" do
      subject { described_class.with_study_modes(study_modes) }

      let(:course_part_time) { create(:course, study_mode: :part_time) }
      let(:course_full_time) { create(:course, study_mode: :full_time) }
      let(:course_both) { create(:course, study_mode: :full_time_or_part_time) }

      before do
        course_both
        course_full_time
        course_part_time
      end

      context "full_time" do
        let(:study_modes) { "full_time" }

        it "returns full time courses" do
          expect(subject).to contain_exactly(course_both, course_full_time)
        end
      end

      context "part_time" do
        let(:study_modes) { "part_time" }

        it "returns part time courses" do
          expect(subject).to contain_exactly(course_both, course_part_time)
        end
      end

      context "full time and part_time" do
        let(:study_modes) { %w[full_time part_time] }

        it "returns all" do
          expect(subject).to contain_exactly(course_both, course_part_time, course_full_time)
        end
      end
    end

    describe ".with_funding_types" do
      subject { described_class.with_funding_types(funding_types) }

      let(:fee_course_higher_education) { create(:course, :with_higher_education) }
      let(:fee_course_scitt) { create(:course, :with_scitt) }
      let(:fee_course_school_direct) { create(:course, :with_school_direct) }
      let(:salary_course) { create(:course, :with_salary) }
      let(:apprenticeship_course) { create(:course, :with_apprenticeship) }

      context "fee courses" do
        let(:funding_types) { %w[fee] }

        before do
          fee_course_higher_education
          fee_course_scitt
          fee_course_school_direct
          salary_course
          apprenticeship_course
        end

        it "returns fee courses" do
          expect(subject).to contain_exactly(fee_course_higher_education, fee_course_school_direct, fee_course_scitt)
        end
      end

      context "salary" do
        let(:funding_types) { %w[salary] }

        before do
          salary_course
          apprenticeship_course
          fee_course_higher_education
        end

        it "returns fee courses" do
          expect(subject).to contain_exactly(salary_course)
        end
      end

      context "apprenticeship" do
        let(:funding_types) { %w[apprenticeship] }

        before do
          apprenticeship_course
          salary_course
          fee_course_scitt
        end

        it "returns fee courses" do
          expect(subject).to contain_exactly(apprenticeship_course)
        end
      end
    end

    describe ".with_degree_grades" do
      subject { described_class.with_degree_grades(degree_grades) }

      let(:two_two_course) { create(:course, degree_grade: :two_two) }
      let(:third_class_course) { create(:course, degree_grade: :third_class) }
      let(:minimum_degree_not_required_course) { create(:course, degree_grade: :not_required) }

      before do
        two_two_course
        third_class_course
        minimum_degree_not_required_course
      end

      context "2:2 courses" do
        let(:degree_grades) { %w[two_two] }

        it "returns courses with a 'two_two' degree grade" do
          expect(subject).to contain_exactly(two_two_course)
        end
      end

      context "third class degree courses" do
        let(:degree_grades) { %w[third_class] }

        it "returns courses with a 'third_class' degree grade" do
          expect(subject).to contain_exactly(third_class_course)
        end
      end

      context "no requirement degree courses" do
        let(:degree_grades) { %w[not_required] }

        it "returns courses with a 'not_required' degree grade" do
          expect(subject).to contain_exactly(minimum_degree_not_required_course)
        end
      end
    end

    describe ".with_salary" do
      subject { described_class.with_salary }

      let!(:course_higher_education_programme) do
        create(:course, program_type: :higher_education_programme, funding: :fee)
      end

      let!(:course_scitt_salaried_programme) do
        create(:course, program_type: :scitt_salaried_programme, funding: :salary)
      end

      let!(:course_higher_education_salaried_programme) do
        create(:course, program_type: :higher_education_salaried_programme, funding: :salary)
      end

      let!(:course_school_direct_training_programme) do
        create(:course, program_type: :school_direct_training_programme, funding: :fee)
      end

      let!(:course_school_direct_salaried_training_programme) do
        create(:course, program_type: :school_direct_salaried_training_programme, funding: :salary)
      end

      let!(:course_scitt_programme) { create(:course, program_type: :scitt_programme, funding: :fee) }
      let!(:course_pg_teaching_apprenticeship) do
        create(:course, program_type: :pg_teaching_apprenticeship, funding: :apprenticeship)
      end

      it "only returns salaried training programme" do
        expect(subject).to contain_exactly(
          course_scitt_salaried_programme,
          course_higher_education_salaried_programme,
          course_school_direct_salaried_training_programme,
          course_pg_teaching_apprenticeship,
        )
      end
    end

    describe ".with_qualifications" do
      subject { described_class.with_qualifications(qualifications) }

      let(:course_qts) { TestDataCache.get(:course, :resulting_in_qts) }
      let(:course_pgce_with_qts) { TestDataCache.get(:course, :resulting_in_pgce_with_qts) }
      let(:course_pgde_with_qts) { TestDataCache.get(:course, :resulting_in_pgde_with_qts) }
      let(:course_pgce) { TestDataCache.get(:course, :resulting_in_pgce) }
      let(:course_pgde) { TestDataCache.get(:course, :resulting_in_pgde) }

      before do
        course_qts
        course_pgce_with_qts
        course_pgde_with_qts
        course_pgce
        course_pgde
      end

      context "qts" do
        let(:qualifications) { "qts" }

        it "returns qts courses" do
          expect(subject).to contain_exactly(course_qts)
        end
      end

      context "pgce_with_qts" do
        let(:qualifications) { "pgce_with_qts" }

        it "returns pgce_with_qts courses" do
          expect(subject).to contain_exactly(course_pgce_with_qts)
        end
      end

      context "pgde_with_qts" do
        let(:qualifications) { "pgde_with_qts" }

        it "returns pgde_with_qts courses" do
          expect(subject).to contain_exactly(course_pgde_with_qts)
        end
      end

      context "pgce" do
        let(:qualifications) { "pgce" }

        it "returns pgce" do
          expect(subject).to contain_exactly(course_pgce)
        end
      end

      context "pgde" do
        let(:qualifications) { "pgde" }

        it "returns pgce" do
          expect(subject).to contain_exactly(course_pgde)
        end
      end

      context "multiple qualifications" do
        let(:qualifications) { %w[pgde pgce qts] }

        it "returns all requested" do
          expect(subject).to contain_exactly(course_pgce, course_pgde, course_qts)
        end
      end
    end

    describe ".with_provider_name" do
      let(:provider) { create(:provider, provider_name: "ACME") }
      let(:provider2) { create(:provider, provider_name: "DAVE") }
      let(:course) { create(:course, provider:) }
      let(:provider_name) { "ACME" }
      let(:accredited_provider_name) { "University of Awesome" }
      let(:accredited_provider) { build(:provider, :accredited_provider, provider_name: accredited_provider_name) }
      let(:accredited_course) { create(:course, accrediting_provider: accredited_provider) }

      before do
        provider
        provider2
        course
        provider_name
      end

      context "with an existing provider name" do
        subject { described_class.with_provider_name(provider_name) }

        it { is_expected.to contain_exactly(course) }
      end

      context "with a provider name with no courses" do
        subject { described_class.with_provider_name("DAVE") }

        it { is_expected.to be_empty }
      end

      context "with an accredited provider name" do
        subject { described_class.with_provider_name(accredited_provider_name) }

        it { is_expected.to contain_exactly(accredited_course) }
      end
    end

    describe ".with_accredited_bodies" do
      context "course with an accredited provider" do
        subject { described_class.with_accredited_bodies(accredited_provider.provider_code) }

        let!(:provider) { create(:provider) }
        let!(:course) { create(:course, provider:) }
        let!(:accredited_provider) { create(:provider, :accredited_provider) }
        let!(:accredited_course) { create(:course, accrediting_provider: accredited_provider) }

        it "returns courses for which the provider is the accredited provider" do
          expect(subject).to contain_exactly(accredited_course)
        end
      end
    end

    context "::findable && ::with_vacancies" do
      let(:course_in_scope) { create(:course) }
      let(:course_not_in_scope) { create(:course) }

      before do
        create(:site_status, :published, :running, :full_time_vacancies, course: course_in_scope)
        create(:site_status, :unpublished, :running, :full_time_vacancies, course: course_not_in_scope)
        create(:site_status, :published, :running, :no_vacancies, course: course_not_in_scope)
      end

      it "scopes are combined with AND and not OR" do
        expect(described_class.findable.with_vacancies.to_a).to eql([course_in_scope])
      end
    end

    describe ".engineers_teach_physics" do
      subject { described_class.engineers_teach_physics }

      context "when the course has the campaign 'engineers_teach_physics'" do
        let(:course) { create(:course, :engineers_teach_physics) }

        it "returns the course" do
          expect(subject).to eq [course]
        end
      end

      context "when the course has no campaign" do
        let(:course) { create(:course, provider:) }

        it "does not return the course" do
          expect(subject).to eq []
        end
      end
    end

    describe ".can_sponsor_visa" do
      subject { described_class.can_sponsor_visa }

      let(:provider) { create(:provider) }
      let(:course) { create(:course, provider: create(:provider)) }

      before do
        course
      end

      context "when the provider can sponsor skilled worker visas" do
        context "and is a salaried course" do
          let(:course) { create(:course, :salary_type_based, :can_sponsor_skilled_worker_visa, provider:) }

          it "returns the course" do
            expect(subject).to eq [course]
          end
        end

        context "and is non-salaried course" do
          let(:course) { create(:course, :fee_type_based, :can_sponsor_skilled_worker_visa, provider:) }

          it "does not return the course" do
            expect(subject).to eq []
          end
        end
      end

      context "when the provider can sponsor student visas" do
        context "and is non-salaried course" do
          let(:course) { create(:course, :fee_type_based, :can_sponsor_student_visa, provider:) }

          it "returns the course" do
            expect(subject).to eq [course]
          end
        end

        context "and is a salaried course" do
          let(:course) { create(:course, :salary_type_based, :can_sponsor_student_visa, provider:) }

          it "does not return the course" do
            expect(subject).to eq []
          end
        end
      end

      context "when the provider cannot sponsor visas" do
        it "does not return the course" do
          expect(subject).to eq []
        end
      end
    end
  end
end
