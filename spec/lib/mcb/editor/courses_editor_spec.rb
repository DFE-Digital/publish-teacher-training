require "mcb_helper"

describe MCB::Editor::CoursesEditor, :needs_audit_user do
  def run_editor(*input_cmds)
    with_stubbed_stdout(stdin: input_cmds.join("\n")) do
      subject.run
    end
  end

  let(:provider_code) { "X12" }
  let(:course_code) { "3FC4" }
  let(:course_codes) { [course_code] }
  let(:email) { "user@education.gov.uk" }
  let(:provider) { create(:provider, provider_code: provider_code) }
  let(:accredited_body) { create(:provider, :accredited_body) }
  let(:japanese) { find_or_create(:modern_languages_subject, :japanese) }
  let(:primary_with_mathematics) { find_or_create(:primary_subject, :primary_with_mathematics) }
  let(:biology) { find_or_create(:secondary_subject, :biology) }
  let(:mathematics) { find_or_create(:secondary_subject, :mathematics) }
  let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
  let(:further_education) { find_or_create(:further_education_subject) }
  let(:current_cycle) { find_or_create :recruitment_cycle }
  let(:current_year) { current_cycle.year.to_i }
  let(:last_year) { current_year - 1 }
  let(:is_send) { false }
  let(:subjects) { [] }
  let(:level) { "primary" }
  let(:age_range_in_years) { "3_to_7" }
  let(:course) {
    create(:course,
           provider: provider,
           accrediting_provider: accredited_body,
           course_code: course_code,
           name: "Original name",
           maths: "must_have_qualification_at_application_time",
           english: "equivalence_test",
           science: "not_required",
           program_type: "pg_teaching_apprenticeship",
           qualification: "qts",
           study_mode: "part_time",
           age_range_in_years: age_range_in_years,
           start_date: Date.new(current_year, 8, 1),
           level: level,
           subjects: subjects,
           applications_open_from: Date.new(last_year, 10, 9),
           is_send: is_send)
  }

  before do
    course
    japanese
    primary_with_mathematics
    biology
    mathematics
    further_education
  end

  subject { described_class.new(provider: provider, course_codes: course_codes, requester: requester) }

  context "when an authorised user" do
    let!(:requester) { create(:user, email: email, organisations: provider.organisations) }
    let!(:another_accredited_body) { create(:provider, :accredited_body) }

    describe "runs the editor" do
      it "updates the course title" do
        expect { run_editor("edit title", "Mathematics", "exit") }.to change { course.reload.name }.
          from("Original name").to("Mathematics")
      end

      it "creates a Course audit with the correct requester when Editing" do
        run_editor("edit title", "Mathematics", "exit")
        course.reload

        expect(course.audits.last.user).to eq(requester)
      end

      describe "(course code)" do
        it "updates the course code when that is valid" do
          expect { run_editor("edit course code", "CXXZ", "exit") }.
            to change { course.reload.course_code }.
            from(course_code).to("CXXZ")
        end

        it "upper-cases the course code before assigning it" do
          expect { run_editor("edit course code", "cxxz", "exit") }.
            to change { course.reload.course_code }.
            from(course_code).to("CXXZ")
        end

        it "does not apply an empty course code" do
          expect { run_editor("edit course code", "", "CXXY", "exit") }.
            to change { course.reload.course_code }.
            from(course_code).to("CXXY")
        end
      end

      it "does nothing upon an immediate exit" do
        expect { run_editor("exit") }.to_not change { course.reload.name }.
          from("Original name")
      end
    end

    describe "does not specify any course codes" do
      let!(:another_course) {
        create(:course,
               provider: provider,
               course_code: "A123",
               name: "Another name")
      }
      let(:course_codes) { [] }

      it "edits all courses on the provider" do
        expect { run_editor("edit title", "Mathematics", "exit") }.
          to change { provider.reload.courses.order(:name).pluck(:name) }.
          from(["Another name", "Original name"]).to(%w[Mathematics Mathematics])
      end
    end

    context "when there are several courses with the same course code" do
      let(:another_provider) { create(:provider) }
      let!(:another_course_with_the_same_course_code) {
        create(:course,
               provider: another_provider,
               course_code: course.course_code,
               name: "Another name")
      }

      it "edits the course from the specified provider" do
        expect { run_editor("edit title", "Mathematics", "exit") }.
          to change { course.reload.name }.
          from("Original name").to("Mathematics")
      end
    end

    context "when trying to edit a course code that doesn't exist on this provider but exists on another one" do
      let(:course_code) { "ABCD" }
      let(:another_provider) { create(:provider) }
      let!(:another_course_with_another_provider) {
        create(:course,
               provider: another_provider,
               course_code: "XYZ1",
               name: "Another name")
      }
      subject { described_class.new(provider: provider, course_codes: %w{XYZ1}, requester: requester) }

      it "raises an error" do
        expect { subject }.to raise_error(ArgumentError, /Couldn't find course XYZ1/)
      end
    end

    describe "tries to edit a non-existent course" do
      let(:course_codes) { [course_code, "ABCD"] }

      it "raises an error" do
        expect { subject }.to raise_error(ArgumentError, /Couldn't find course ABCD/)
      end
    end
  end

  context "for an unauthorised user" do
    let!(:requester) { create(:user, email: email, organisations: []) }

    it "raises an error" do
      expect { subject }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
