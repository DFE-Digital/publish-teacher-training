require 'mcb_helper'

describe MCB::Editor::ProviderEditor, :needs_audit_user do
  def run_editor(*input_cmds)
    with_stubbed_stdout(stdin: input_cmds.join("\n")) do
      subject.run
    end
  end

  let(:provider_code) { 'X12' }
  let(:email) { 'user@education.gov.uk' }
  let(:provider) {
    create(:provider,
           provider_code: provider_code,
           provider_name: 'Original name')
  }

  subject { described_class.new(provider: provider, requester: requester) }

  context 'when an authorised user' do
    let!(:requester) { create(:user, email: email, organisations: provider.organisations) }

    describe 'runs the editor' do
      it 'updates the provider name' do
        expect { run_editor("edit provider name", "ACME SCITT", "exit") }
          .to change { provider.reload.provider_name }
          .from("Original name").to("ACME SCITT")
      end

      it 'creates a provider audit with the correct requester' do
        run_editor("edit provider name", "ACME SCITT", "exit")
        provider.reload

        expect(provider.audits.last.user).to eq(requester)
      end

      describe "(course editing)" do
        let!(:courses) { create(:course, course_code: 'A01X', name: 'Biology', provider: provider) }
        let!(:course2) { create(:course, course_code: 'A02X', name: 'History', provider: provider) }
        let!(:course3) { create(:course, course_code: 'A03X', name: 'Economics', provider: provider) }
        let(:recruitment_cycle_year) { ["-r", provider.recruitment_cycle.year] }

        it 'lists the courses for the given provider' do
          output = run_editor("edit courses", "continue", "exit")[:stdout]
          expect(output).to include(
            "[ ] Biology (#{provider_code}/A01X) [#{provider.recruitment_cycle}]",
            "[ ] History (#{provider_code}/A02X) [#{provider.recruitment_cycle}]",
            "[ ] Economics (#{provider_code}/A03X) [#{provider.recruitment_cycle}]"
          )
        end

        it 'invokes course editing on the selected courses' do
          allow($mcb).to receive(:run)

          run_editor(
            "edit courses", # choose the option
            "[ ] Biology (#{provider_code}/A01X) [#{provider.recruitment_cycle}]", # pick the first course
            "[ ] Economics (#{provider_code}/A03X) [#{provider.recruitment_cycle}]", # pick the second course
            "continue", # finish selecting courses
            "exit" # from the command
          )

          expect($mcb).to have_received(:run).with(
            %w[courses edit X12 A01X A03X] + recruitment_cycle_year
          )
        end

        it 'invokes course editing on courses selected by their course code' do
          allow($mcb).to receive(:run)

          run_editor(
            "edit courses", # choose the option
            "A01X", # pick the first course
            "A03X", # pick the second course
            "continue", # finish selecting courses
            "exit" # from the command
          )

          expect($mcb).to have_received(:run).with(
            %w[courses edit X12 A01X A03X] + recruitment_cycle_year
          )
        end

        it 'allows to easily select all courses' do
          allow($mcb).to receive(:run)

          run_editor("edit courses", "select all", "continue", "exit")

          expect($mcb).to have_received(:run).with(
            %w[courses edit X12 A01X A02X A03X] + recruitment_cycle_year
          )
        end

        context "(run against an Azure environment)" do
          let(:environment) { 'qa' }
          subject { described_class.new(provider: provider, requester: requester, environment: environment) }

          it 'invokes course editing in the environment that the "providers edit" command was invoked' do
            allow($mcb).to receive(:run)

            run_editor(
              "edit courses",
              "[ ] Biology (#{provider_code}/A01X) [#{provider.recruitment_cycle}]",
              "continue",
              "exit"
            )

            expect($mcb).to have_received(:run).with(
              %w[courses edit X12 A01X -E qa] + recruitment_cycle_year
            )
          end
        end
      end

      it 'does nothing upon an immediate exit' do
        expect { run_editor("exit") }.to_not change { provider.reload.provider_name }.
          from("Original name")
      end
    end

    describe 'runs the provider creation wizard' do
      def run_new_provider_wizard(*input_cmds)
        with_stubbed_stdout(stdin: input_cmds.join("\n")) do
          subject.new_provider_wizard
        end
      end
      let(:provider) { RecruitmentCycle.current_recruitment_cycle.providers.build }

      let(:desired_attributes) {
        {
          name: "ACME SCITT",
          code: 'X01',
          type: 'scitt',
          first_location_name: "ACME Primary School",
          address1: '123 Acme Lane',
          town_or_city: 'Acmeton',
          county: '',
          postcode: 'SW13 9AA',
          region_code: 'london',
          contact_name: 'Jane Smith',
          email: 'jsmith@acme-scitt.org.uk',
          telephone: "0123456",
          organisation_name: 'ACME SCITT',
        }
      }

      let(:valid_answers) {
        [
          desired_attributes[:name],
          desired_attributes[:code],
          desired_attributes[:type],
          desired_attributes[:contact_name],
          desired_attributes[:email],
          desired_attributes[:telephone],
          desired_attributes[:first_location_name],
          desired_attributes[:address1],
          desired_attributes[:town_or_city],
          desired_attributes[:county],
          desired_attributes[:postcode],
          desired_attributes[:region_code]
        ]
      }

      let(:expected_provider_attributes) {
        {
          "provider_name" => desired_attributes[:name],
          "provider_code" => desired_attributes[:code],
          "provider_type" => desired_attributes[:type],
          "contact_name" => desired_attributes[:contact_name],
          "email" => desired_attributes[:email],
          "telephone" => desired_attributes[:telephone],
          "address1" => desired_attributes[:address1],
          "address3" => desired_attributes[:town_or_city],
          "address4" => desired_attributes[:county],
          "postcode" => desired_attributes[:postcode],
          "region_code" => desired_attributes[:region_code],
          "scitt" => 'Y',
          "accrediting_provider" => "accredited_body",
        }
      }

      context "when adding a new provider into a completely new organisation" do
        let(:frozen_time) { Time.parse('10:00 20/01/2019').utc }
        let(:created_provider) { RecruitmentCycle.current_recruitment_cycle.providers.find_by!(provider_code: desired_attributes[:code]) }

        before do
          Timecop.freeze(frozen_time)

          @output = run_new_provider_wizard(
            *valid_answers,
            'y', # confirm creation
            # adding the provider into a new organisation
            desired_attributes[:organisation_name],
            "y" # confirm creation of a new org
          )[:stdout]
        end

        after do
          Timecop.return
        end

        it "creates a new provider with the passed parameters and defaults" do
          expect(@output).to include("New provider has been created")

          expect(created_provider.attributes).to include(expected_provider_attributes)
          expect(created_provider.is_a_UCAS_ITT_member?).to be_truthy
          expect(created_provider.year_code).to eq(RecruitmentCycle.current_recruitment_cycle.year)
        end

        it "creates a new Provider with the correct 'changed_at' time" do
          expect(@output).to include("New provider has been created")

          expect(created_provider.changed_at).to eq(frozen_time)
        end

        it "creates a new Provider with an audit with the correct User" do
          expect(created_provider.audits.last.user).to eq(requester)
        end

        it "creates a new organisation with the passed parameters" do
          expect(created_provider.organisations.count).to eq(1)
          expect(created_provider.organisation.name).to eq(desired_attributes[:organisation_name])
        end

        it "creates the first training location with the passed parameters" do
          expect(created_provider.sites.count).to eq(1)

          site = created_provider.sites.first
          expect(site.address1).to eq(desired_attributes[:address1])
          expect(site.address2).to be_nil
          expect(site.address3).to eq(desired_attributes[:town_or_city])
          expect(site.address4).to eq(desired_attributes[:county])
          expect(site.postcode).to eq(desired_attributes[:postcode])
          expect(site.region_code).to eq(desired_attributes[:region_code])
        end
      end

      context "when adding a new provider into an organisation" do
        it "does not accept zero input" do
          output = run_new_provider_wizard(
            *valid_answers,
            'y', # confirm creation
            '', # Empty Org Name
            # adding the provider into a new organisation
            desired_attributes[:organisation_name],
            "y" # confirm creation of a new org
          )[:stdout]

          expect(output).to include('Organisation name cannot be blank.')
        end

        it "does not accept new line" do
          output = run_new_provider_wizard(
            *valid_answers,
            'y', # confirm creation
            "\n", # Empty Org Name
            # adding the provider into a new organisation
            desired_attributes[:organisation_name],
            "y" # confirm creation of a new org
          )[:stdout]

          expect(output).to include('Organisation name cannot be blank.')
        end

        it "does not accept only whitespace" do
          output = run_new_provider_wizard(
            *valid_answers,
            'y', # confirm creation
            "   ", # Empty Org Name
            # adding the provider into a new organisation
            desired_attributes[:organisation_name],
            "y" # confirm creation of a new org
          )[:stdout]

          expect(output).to include('Organisation name cannot be blank.')
        end
      end

      context "when adding a new provider into an existing organisation" do
        let!(:existing_organisation) { create(:organisation, name: desired_attributes[:organisation_name]) }

        it "creates a new provider into the existing organisation with the passed parameters" do
          output = run_new_provider_wizard(
            *valid_answers,
            'y', # confirm creation
            desired_attributes[:organisation_name], # adding the provider into an existing organisation
          )[:stdout]

          expect(output).to include("New provider has been created")

          provider = RecruitmentCycle.current_recruitment_cycle.providers.find_by!(provider_code: desired_attributes[:code])
          expect(provider.organisation).to eq(existing_organisation)

          # no other orgs should have been created
          expect(Organisation.count).to eq(1)
        end

        it "creates a new provider into the existing organisation, even if the user makes and then corrects a typo in the org name" do
          output = run_new_provider_wizard(
            *valid_answers,
            'y', # confirm creation
            "ACCCCME SCITT", # mistyped organisation name
            "no", # don't create the mistyped org
            desired_attributes[:organisation_name], # try typing in the org name again
          )[:stdout]

          expect(output).to include("New provider has been created")

          provider = RecruitmentCycle.current_recruitment_cycle.providers.find_by!(provider_code: desired_attributes[:code])
          expect(provider.organisation).to eq(existing_organisation)

          # no other orgs should have been created
          expect(Organisation.count).to eq(1)
        end
      end

      context "when there are later recruitment cycles after the one that's been added to" do
        let!(:next_recruitment_cycle) { create :recruitment_cycle, :next }
        let!(:one_after_next_recruitment_cycle) { create :recruitment_cycle, year: next_recruitment_cycle.year.to_i + 1 }

        it "clones the provider into all subsequent recruitment cycles" do
          run_new_provider_wizard(
            *valid_answers,
            'y', # confirm creation
            desired_attributes[:organisation_name],
            "yes"
          )

          expect(next_recruitment_cycle.providers.count).to eq(1)
          expect(next_recruitment_cycle.providers.first.attributes).to include(expected_provider_attributes)

          expect(one_after_next_recruitment_cycle.providers.count).to eq(1)
          expect(one_after_next_recruitment_cycle.providers.first.attributes).to include(expected_provider_attributes)
        end
      end

      it "does not create a Provider if creation isn't confirmed" do
        output = run_new_provider_wizard(
          *valid_answers,
          'n' # Do not confirm creation
        )[:stdout]

        expect(Provider.find_by(provider_code: desired_attributes[:provider_code])).to be_nil
        expect(output).to include("Aborting")
      end

      it "does not create a Provider when the provider is not valid" do
        expect(provider).to receive(:valid?).and_return(false)

        output = run_new_provider_wizard(
          *valid_answers,
          'y' # confirm creation
        )[:stdout]

        expect(Provider.find_by(provider_code: desired_attributes[:provider_code])).to be_nil
        expect(output).to include("Provider isn't valid")
        expect(output).to include("Aborting")
      end
    end
  end

  context 'for an unauthorised user' do
    let!(:requester) { create(:user, email: email, organisations: []) }

    it 'raises an error' do
      expect { subject }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
