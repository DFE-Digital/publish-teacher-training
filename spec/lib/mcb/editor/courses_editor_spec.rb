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

      context "when syncing to Find" do
        let!(:another_course) { create(:course, provider: provider) }
        let(:course_codes) { [course_code, another_course.course_code] }
        let!(:search_api_request) do
          stub_request(:put, "#{Settings.search_api.base_url}/api/courses/")
            .with { |req| req.body == body.to_json }
            .to_return(
              status: 200,
            )
        end

        let(:body) do
          ActiveModel::Serializer::CollectionSerializer.new(
            [course, another_course],
            serializer: SearchAndCompare::CourseSerializer,
            adapter: :attributes,
          )
        end

        it "syncs courses to Find" do
          run_editor("sync course(s) to Find", "exit")

          expect(search_api_request).to have_been_made
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

    describe "runs the course creation wizard" do
      def run_new_course_wizard(*input_cmds)
        with_stubbed_stdout(stdin: input_cmds.join("\n")) do
          subject.new_course_wizard
        end
      end

      let!(:site_1) { create(:site, provider: provider, location_name: "Albemarle School") }
      let!(:site_2) { create(:site, provider: provider, location_name: "King Edward School") }
      let!(:site_3) { create(:site, provider: provider, location_name: "Emmanuel School") }
      let(:new_course) { provider.courses.build }

      subject {
        described_class.new(
          provider: provider,
          requester: requester,
          courses: [new_course],
        )
      }

      before do
        Timecop.freeze(Time.utc(last_year, 11, 1))
      end

      after do
        Timecop.return
      end

      let(:desired_attributes) {
        {
          title: "Biology",
          qualification: "qts",
          study_mode: "full_time",
          accredited_body: accredited_body.provider_code,
          start_date: "1 September #{current_year}",
          route: "pg_teaching_apprenticeship",
          maths: "equivalence_test",
          english: "equivalence_test",
          science: "not_required",
          age_range_in_years: "11_to_18",
          level: "secondary",
          course_code: "1X2B",
          recruitment_cycle: "2", # the 2nd option should always be the current recruitment cycle
          application_opening_date: "18 October #{last_year}",
          is_send: true,
        }
      }

      describe "selects the correctly leveled subject" do
        it "in a secondary course shows secondary subjects" do
          run_new_course_wizard(
            desired_attributes[:title],
            desired_attributes[:qualification],
            desired_attributes[:study_mode],
            desired_attributes[:accredited_body],
            desired_attributes[:start_date],
            desired_attributes[:route],
            desired_attributes[:maths],
            desired_attributes[:english],
            desired_attributes[:science],
            desired_attributes[:age_range_in_years],
            desired_attributes[:level],
            desired_attributes[:course_code],
            "y", # is SEND confirmation
            "[ ] Biology",
            "continue",
            "y", # confirm creation
            # location selection
            "[ ] #{site_1.location_name}",
            "[ ] #{site_3.location_name}",
            "continue",
            desired_attributes[:application_opening_date],
            "", # enter to finish
            "",
          )[:stdout]

          expect(Course.find_by(course_code: desired_attributes[:course_code]).subjects).to match_array([biology.becomes(SecondarySubject)])
        end

        it "in a secondary course implicitly select modern language if language subject is selected" do
          run_new_course_wizard(
            desired_attributes[:title],
            desired_attributes[:qualification],
            desired_attributes[:study_mode],
            desired_attributes[:accredited_body],
            desired_attributes[:start_date],
            desired_attributes[:route],
            desired_attributes[:maths],
            desired_attributes[:english],
            desired_attributes[:science],
            desired_attributes[:age_range_in_years],
            desired_attributes[:level],
            desired_attributes[:course_code],
            "y", # is SEND confirmation
            "[ ] Japanese",
            "continue",
            "y", # confirm creation
            # location selection
            "[ ] #{site_1.location_name}",
            "[ ] #{site_3.location_name}",
            "continue",
            desired_attributes[:application_opening_date],
            "", # enter to finish
            "",
          )[:stdout]

          expect(Course.find_by(course_code: desired_attributes[:course_code]).subjects).to match_array([modern_languages.becomes(SecondarySubject), japanese.becomes(ModernLanguagesSubject)])
        end

        it "only shows primary subjects if primary level is selected" do
          run_new_course_wizard(
            desired_attributes[:title],
            desired_attributes[:qualification],
            desired_attributes[:study_mode],
            desired_attributes[:accredited_body],
            desired_attributes[:start_date],
            desired_attributes[:route],
            desired_attributes[:maths],
            desired_attributes[:english],
            desired_attributes[:science],
            desired_attributes[:age_range_in_years],
            "primary",
            desired_attributes[:course_code],
            "y", # is SEND confirmation
            "[ ] Primary with mathematics",
            "continue",
            "y", # confirm creation
            # location selection
            "[ ] #{site_1.location_name}",
            "[ ] #{site_3.location_name}",
            "continue",
            desired_attributes[:application_opening_date],
            "", # enter to finish
            "",
          )[:stdout]

          expect(Course.find_by(course_code: desired_attributes[:course_code]).subjects)
            .to match_array(primary_with_mathematics.becomes(PrimarySubject))
        end

        it "only shows further education subjects if further education level is selected" do
          run_new_course_wizard(
            desired_attributes[:title],
            desired_attributes[:qualification],
            desired_attributes[:study_mode],
            desired_attributes[:accredited_body],
            desired_attributes[:start_date],
            desired_attributes[:route],
            desired_attributes[:maths],
            desired_attributes[:english],
            desired_attributes[:science],
            desired_attributes[:age_range_in_years],
            "further_education",
            desired_attributes[:course_code],
            "y", # is SEND confirmation
            "[ ] Further education",
            "continue",
            "y", # confirm creation
            # location selection
            "[ ] #{site_1.location_name}",
            "[ ] #{site_3.location_name}",
            "continue",
            desired_attributes[:application_opening_date],
            "", # enter to finish
            "",
          )[:stdout]

          expect(Course.find_by(course_code: desired_attributes[:course_code]).subjects).to eq([further_education.becomes(FurtherEducationSubject)])
        end
      end

      it "creates a new course with the passed parameters" do
        output = run_new_course_wizard(
          desired_attributes[:title],
          desired_attributes[:qualification],
          desired_attributes[:study_mode],
          desired_attributes[:accredited_body],
          desired_attributes[:start_date],
          desired_attributes[:route],
          desired_attributes[:maths],
          desired_attributes[:english],
          desired_attributes[:science],
          desired_attributes[:age_range_in_years],
          desired_attributes[:level],
          desired_attributes[:course_code],
          "y", # is SEND confirmation
          "[ ] Mathematics", # subject selection
          "continue",
          "y", # confirm creation
          # location selection
          "[ ] #{site_1.location_name}",
          "[ ] #{site_3.location_name}",
          "continue",
          desired_attributes[:application_opening_date],
          "", # enter to finish
          "",
        )[:stdout]

        expect(output).to include("Here's the final course that's been created")

        created_course = provider.courses.find_by!(course_code: desired_attributes[:course_code])
        expect(created_course.attributes).to include(
          "name" => desired_attributes[:title],
          "qualification" => desired_attributes[:qualification],
          "study_mode" => desired_attributes[:study_mode],
          "start_date" => Date.new(current_year, 9, 1),
          "program_type" => desired_attributes[:route],
          "maths" => desired_attributes[:maths],
          "english" => desired_attributes[:english],
          "science" => desired_attributes[:science],
          "age_range_in_years" => desired_attributes[:age_range_in_years],
          "level" => desired_attributes[:level],
        )
        expect(created_course.is_send?).to be_truthy
        expect(created_course.accrediting_provider).to eq(accredited_body)
        expect(created_course.recruitment_cycle).to eq(current_cycle)
        expect(created_course.sites).to include(site_1, site_3)
        expect(created_course.applications_open_from).to eq(Date.new(last_year, 10, 18))
        expect(created_course.ucas_status).to eq(:new)
      end

      it "creates a new course with an audit with the correct requester" do
        run_new_course_wizard(
          desired_attributes[:title],
          desired_attributes[:qualification],
          desired_attributes[:study_mode],
          desired_attributes[:accredited_body],
          desired_attributes[:start_date],
          desired_attributes[:route],
          desired_attributes[:maths],
          desired_attributes[:english],
          desired_attributes[:science],
          desired_attributes[:age_range_in_years],
          desired_attributes[:level],
          desired_attributes[:course_code],
          "y", # is SEND confirmation
          "[ ] Mathematics", # subject selection
          "continue",
          "y", # confirm creation
          # location selection
          "[ ] #{site_1.location_name}",
          "[ ] #{site_3.location_name}",
          "continue",
          desired_attributes[:application_opening_date],
          "", # enter to finish
          "",
        )

        created_course = provider.courses.find_by!(course_code: desired_attributes[:course_code])

        expect(created_course.audits.last.user).to eq(requester)
      end

      it "creates a new course with sensible defaults when certain steps are left blank" do
        run_new_course_wizard(
          desired_attributes[:title],
          "", # default qualifications
          "", # default study mode
          "", # default start date
          "", # default accredited body
          desired_attributes[:route],
          desired_attributes[:maths],
          desired_attributes[:english],
          desired_attributes[:science],
          desired_attributes[:age_range_in_years],
          desired_attributes[:level],
          desired_attributes[:course_code],
          "n", # is SEND
          desired_attributes[:recruitment_cycle],
          # subject selection
          "[ ] Mathematics",
          "continue",
          "y", # confirm creation
          # location selection
          "[ ] #{site_1.location_name}",
          "[ ] #{site_3.location_name}",
          "continue",
          "", # default application open date
          "", # enter to finish
          "",
        )

        created_course = provider.courses.find_by!(course_code: desired_attributes[:course_code])

        expect(created_course.attributes).to include(
          "qualification" => "pgce_with_qts",
          "study_mode" => "full_time",
          "start_date" => Date.new(current_year, 9, 1),
          "program_type" => desired_attributes[:route],
        )

        expect(created_course.accrediting_provider).to eq(provider)
      end

      it "does not create the course if creation isn't confirmed" do
        output = run_new_course_wizard(
          desired_attributes[:title],
          "", # default qualifications
          "", # default study mode
          "", # default start date
          "", # default accredited body
          desired_attributes[:route],
          desired_attributes[:maths],
          desired_attributes[:english],
          desired_attributes[:science],
          desired_attributes[:age_range_in_years],
          desired_attributes[:level],
          desired_attributes[:course_code],
          "n", # is SEND
          desired_attributes[:recruitment_cycle],
          "[ ] Mathematics",
          "continue",
          "n", # confirm creation
        )[:stdout]

        expect(Course.find_by(course_code: desired_attributes[:course_code])).to be_nil
        expect(output).to include("Aborting")
      end

      it "aborts the wizard if specified course fails validation" do
        output = run_new_course_wizard(
          desired_attributes[:title],
          "", # default qualifications
          "", # default study mode
          "", # default start date
          "", # default accredited body
          desired_attributes[:route],
          desired_attributes[:maths],
          desired_attributes[:english],
          desired_attributes[:science],
          desired_attributes[:age_range_in_years],
          desired_attributes[:level],
          course_code, # a duplicate course code
          "n", # is SEND
          desired_attributes[:recruitment_cycle],
          "[ ] Mathematics",
          "continue",
          "y", # confirm creation
        )[:stdout]

        expect(Course.where(course_code: course_code).count).to eq(1)
        expect(output).to include("Course isn't valid")
        expect(output).to include("Aborting")
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
