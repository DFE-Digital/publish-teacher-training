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
  let!(:mathematics) { find_or_create(:subject, :mathematics) }
  let!(:biology) { find_or_create(:subject, subject_name: "Biology") }
  let!(:secondary) { find_or_create(:subject, :secondary) }
  let(:current_cycle) { RecruitmentCycle.current_recruitment_cycle }
  let!(:next_cycle) { find_or_create(:recruitment_cycle, year: "2020") }
  let(:is_send) { false }
  let!(:course) {
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
           start_date: Date.new(2019, 8, 1),
           age_range: "secondary",
           subjects: [secondary, biology],
           applications_open_from: Date.new(2018, 10, 9),
           is_send: is_send)
  }
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

      describe "(maths)" do
        it "updates the maths setting when that is valid" do
          expect { run_editor("edit maths", "equivalence_test", "exit") }.to change { course.reload.maths }.
            from("must_have_qualification_at_application_time").to("equivalence_test")
        end

        it "doesn't change the setting if the user exits" do
          expect { run_editor("edit maths", "exit", "exit") }.to_not change { course.reload.maths }.
            from("must_have_qualification_at_application_time")
        end
      end

      describe "(english)" do
        it "updates the english setting when that is valid" do
          expect { run_editor("edit english", "must_have_qualification_at_application_time", "exit") }.to change { course.reload.english }.
            from("equivalence_test").to("must_have_qualification_at_application_time")
        end

        it "doesn't change the setting if the user exits" do
          expect { run_editor("edit english", "exit", "exit") }.to_not change { course.reload.english }.
            from("equivalence_test")
        end
      end

      describe "(science)" do
        it "updates the science setting when that is valid" do
          expect { run_editor("edit science", "equivalence_test", "exit") }.to change { course.reload.science }.
            from("not_required").to("equivalence_test")
        end

        it "doesn't change the setting if the user exits" do
          expect { run_editor("edit science", "exit", "exit") }.to_not change { course.reload.science }.
            from("not_required")
        end
      end

      describe "(route)" do
        it "updates the route/program type setting when that is valid" do
          expect { run_editor("edit route", "school_direct_training_programme", "exit") }.to change { course.reload.program_type }.
            from("pg_teaching_apprenticeship").to("school_direct_training_programme")
        end

        it "doesn't change the setting if the user exits" do
          expect { run_editor("edit route", "exit", "exit") }.to_not change { course.reload.program_type }.
            from("pg_teaching_apprenticeship")
        end
      end

      describe "(qualifications)" do
        it "updates the qualifications setting when that is valid" do
          expect { run_editor("edit qualifications", "pgde_with_qts", "exit") }.to change { course.reload.qualification }.
            from("qts").to("pgde_with_qts")
        end

        it "updates the qualifications setting to pgce_with_qts by default" do
          expect { run_editor("edit qualifications", "", "exit") }.to change { course.reload.qualification }.
            from("qts").to("pgce_with_qts")
        end
      end

      describe "(study mode)" do
        it "updates the study mode setting when that is valid" do
          expect { run_editor("edit study mode", "full_time_or_part_time", "exit") }.to change { course.reload.study_mode }.
            from("part_time").to("full_time_or_part_time")
        end

        it "updates the study mode setting to full-time by default" do
          expect { run_editor("edit study mode", "", "exit") }.to change { course.reload.study_mode }.
            from("part_time").to("full_time")
        end
      end

      describe "(accredited body)" do
        it "updates the accredited body for an existing accredited body" do
          expect { run_editor("edit accredited body", another_accredited_body.provider_code, "exit") }.
            to change { course.reload.accrediting_provider }.
            from(accredited_body).to(another_accredited_body)
        end

        it "upper-cases the accredited body code before looking it up" do
          expect { run_editor("edit accredited body", another_accredited_body.provider_code.downcase, "exit") }.
            to change { course.reload.accrediting_provider }.
            from(accredited_body).to(another_accredited_body)
        end

        it "updates the accredited body to self-accredited when no accredited body is specified" do
          expect { run_editor("edit accredited body", "", "exit") }.to change { course.reload.accrediting_provider }.
            from(accredited_body).to(provider)
        end

        it "asks the accredited body again if the user provides a non-existent code" do
          expect { run_editor("edit accredited body", "ABCDE", "XYZ", "", "exit") }.to change { course.reload.accrediting_provider }.
            from(accredited_body).to(provider)
        end
      end

      describe "(start date)" do
        it "updates the course start date when that is valid" do
          expect { run_editor("edit start date", "October 2019", "exit") }.
            to change { course.reload.start_date }.
            from(Date.new(2019, 8, 1)).to(Date.new(2019, 10, 1))
        end

        it "updates the start date to September of the recruitment cycle start year, when no start date is given" do
          expect { run_editor("edit start date", "", "exit") }.to change { course.reload.start_date }.
            from(Date.new(2019, 8, 1)).to(Date.new(2019, 9, 1))
        end
      end

      describe "(application opening date)" do
        let(:sites) { create_list(:site, 2) }

        before do
          sites.collect do |site|
            course.site_statuses.create(site: site,
                                        status: :running,
                                        vac_status: :part_time_vacancies,
                                        publish: :published,
                                        applications_accepted_from: Date.new(2018, 10, 9))
          end
        end

        it 'updates the "applications open from" when that is valid' do
          expect { run_editor("edit application opening date", "1 October 2018", "exit") }.
            to change { Date.parse(course.reload.applications_open_from.to_s) }.
            from(Date.new(2018, 10, 9)).to(Date.new(2018, 10, 1))
        end

        it "updates the application opening date to today by default" do
          Timecop.freeze(Time.utc(2019, 6, 1, 12, 0, 0)) do
            expect { run_editor("edit application opening date", "", "exit") }.
              to change { Date.parse(course.reload.applications_open_from.to_s) }.
              from(Date.new(2018, 10, 9)).to(Date.new(2019, 6, 1))
          end
        end
      end

      describe "(age range)" do
        it "updates the course age range when that is valid" do
          expect { run_editor("edit age range", "primary", "exit") }.
            to change { course.reload.age_range }.
            from("secondary").to("primary")
        end
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

      describe "(subjects)" do
        it "attaches new subjects" do
          expect { run_editor("edit subjects", "[ ] Mathematics", "continue", "exit") }.
            to change { course.subjects.reload.sort_by(&:subject_name) }.
            from([biology, secondary]).to([biology, mathematics, secondary])
        end

        it "removes existing subjects" do
          expect { run_editor("edit subjects", "[x] Biology", "continue", "exit") }.
            to change { course.subjects.reload.sort_by(&:subject_name) }.
            from([biology, secondary]).to([secondary])
        end

        context "when more than 1 course is being edited" do
          let(:another_course) { create(:course, provider: provider) }
          let(:course_codes) { [course_code, another_course.course_code] }

          it "does not allow editing subjects" do
            output, = run_editor("exit")
            expect(output).to_not include("edit subjects")
          end
        end
      end

      describe "(training locations)" do
        let!(:site_1) { create(:site, location_name: "ACME school", provider: provider) }
        let!(:site_2) { create(:site, location_name: "Zebra school", provider: provider) }
        let!(:site_1_status) {
          create(:site_status, :running, :published, :part_time_vacancies, course: course, site: site_1)
        }

        it "adds new training locations" do
          expect { run_editor("edit training locations", "[ ] Zebra school", "continue", "exit") }.
            to change { course.sites.reload.sort_by(&:location_name) }.
            from([site_1]).to([site_1, site_2])
        end

        it "removes existing training locations" do
          expect { run_editor("edit training locations", "[x] ACME school", "continue", "exit") }.
            to change { course.reload.sites }.
            from([site_1]).to([])
        end

        context "when more than 1 course is being edited" do
          let(:another_course) { create(:course, provider: provider) }
          let(:course_codes) { [course_code, another_course.course_code] }

          it "does not allow editing training locations" do
            output, = run_editor("exit")
            expect(output).to_not include("edit training locations")
          end
        end
      end

      describe "(is_send)" do
        context "when course is not SEND" do
          it 'turns "yes" into true boolean on Course' do
            expect { run_editor("edit is SEND", "yes", "exit") }.
              to change { course.reload.is_send? }.
              from(is_send).to(true)
          end
        end

        context "when course is SEND" do
          let(:is_send) { true }

          it 'turns "no" into false sboolean on Course' do
            expect { run_editor("edit is SEND", "no", "exit") }.
              to change { course.reload.is_send? }.
              from(is_send).to(false)
          end
        end
      end

      context "when syncing to Find" do
        let!(:another_course) { create(:course, provider: provider) }
        let(:course_codes) { [course_code, another_course.course_code] }

        let!(:manage_api_request1) {
          stub_request(:post, "#{Settings.manage_api.base_url}/api/Publish/internal/course/#{provider_code}/#{course_code}")
            .with { |req| req.body == { "email": email }.to_json }
            .to_return(
              status: 200,
              body: '{ "result": true }',
            )
        }
        let!(:manage_api_request2) {
          stub_request(:post, "#{Settings.manage_api.base_url}/api/Publish/internal/course/#{provider_code}/#{another_course.course_code}")
            .with { |req| req.body == { "email": email }.to_json }
            .to_return(
              status: 200,
              body: '{ "result": true }',
            )
        }

        it "syncs courses to Find" do
          run_editor("sync course(s) to Find", "exit")

          expect(manage_api_request1).to have_been_made
          expect(manage_api_request2).to have_been_made
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
        Timecop.freeze(Time.utc(2018, 11, 1))
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
          start_date: "1 September 2019",
          route: "pg_teaching_apprenticeship",
          maths: "equivalence_test",
          english: "equivalence_test",
          science: "not_required",
          age_range: "secondary",
          course_code: "1X2B",
          recruitment_cycle: "2", # the 2nd option should always be the current recruitment cycle
          application_opening_date: "18 October 2018",
          is_send: true,
        }
      }

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
          desired_attributes[:age_range],
          desired_attributes[:course_code],
          "y", # is SEND confirmation
          desired_attributes[:recruitment_cycle],
          "y", # confirm creation
          # subject selection
          "Biology",
          "Secondary",
          "continue",
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
          "start_date" => Date.new(2019, 9, 1),
          "program_type" => desired_attributes[:route],
          "maths" => desired_attributes[:maths],
          "english" => desired_attributes[:english],
          "science" => desired_attributes[:science],
          "age_range" => desired_attributes[:age_range],
        )
        expect(created_course.is_send?).to be_truthy
        expect(created_course.accrediting_provider).to eq(accredited_body)
        expect(created_course.recruitment_cycle).to eq(current_cycle)
        expect(created_course.sites).to include(site_1, site_3)
        expect(created_course.applications_open_from).to eq(Date.new(2018, 10, 18))
        expect(created_course.ucas_status).to eq(:new)
      end

      it "creates a new course with an Aduit with the correct requester" do
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
          desired_attributes[:age_range],
          desired_attributes[:course_code],
          "y", # is SEND confirmation
          desired_attributes[:recruitment_cycle],
          "y", # confirm creation
          # subject selection
          "Biology",
          "Secondary",
          "continue",
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
          desired_attributes[:age_range],
          desired_attributes[:course_code],
          "n", # is SEND
          desired_attributes[:recruitment_cycle],
          "y", # confirm creation
          # subject selection
          "Biology",
          "Secondary",
          "continue",
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
          "start_date" => Date.new(2019, 9, 1),
          "program_type" => desired_attributes[:route],
        )
        expect(created_course.accrediting_provider).to eq(provider)
        expect(created_course.site_statuses.map(&:applications_accepted_from).uniq).to eq([Date.new(2018, 11, 1)])
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
          desired_attributes[:age_range],
          desired_attributes[:course_code],
          "n", # is SEND
          desired_attributes[:recruitment_cycle],
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
          desired_attributes[:age_range],
          course_code, # a duplicate course code
          "n", # is SEND
          desired_attributes[:recruitment_cycle],
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
