require "mcb_helper"

describe "mcb providers edit" do
  def execute_edit(arguments: [], input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(["providers", "edit", *arguments])
    end
  end

  let(:email) { "user@education.gov.uk" }

  let(:next_cycle)    { find_or_create :recruitment_cycle, :next }
  let(:current_cycle) { find_or_create :recruitment_cycle }

  let(:provider) do
    create :provider,
           provider_name: "Z",
           updated_at: 1.day.ago,
           changed_at: 1.day.ago,
           recruitment_cycle: next_cycle,
           accrediting_provider: accrediting_provider
  end

  let(:rolled_over_provider) do
    new_provider = provider.dup
    new_provider.update(recruitment_cycle: current_cycle)
    new_provider.update(organisations: provider.organisations)
    new_provider.update(provider_name: "A")
    new_provider.save
    new_provider
  end
  let(:accrediting_provider) { "N" }

  before do
    allow(MCB).to receive(:config).and_return(email: email)
    rolled_over_provider
  end

  context "for an authorised user" do
    context "with an unspecified recruitment cycle" do
      let!(:requester) { create(:user, email: email, organisations: rolled_over_provider.organisations) }

      it "updates the name of the provider for the default recruitment cycle" do
        expect { execute_edit(arguments: [rolled_over_provider.provider_code], input: ["edit provider name", "B", "exit"]) }
          .to change { rolled_over_provider.reload.provider_name }
          .from("A").to("B")
      end

      describe "trying to edit a course on a nonexistent provider" do
        it "raises an error" do
          expect { execute_edit(arguments: %w[ABC]) }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Provider/)
        end
      end

      describe "trying to access the provider editor with multiple providers" do
        it "raises an error" do
          expect { execute_edit(arguments: %w[ABC DEF]) }.to raise_error("You cannot access the provider editor with multiple providers")
        end
      end
    end

    context "with a specified recruitment cycle" do
      let!(:requester) { create(:user, email: email, organisations: provider.organisations) }

      it "updates the name of the provider" do
        expect { execute_edit(arguments: [provider.provider_code, "-r", next_cycle.year], input: ["edit provider name", "Y", "exit"]) }
          .to change { provider.reload.provider_name }
          .from("Z").to("Y")
      end
    end

    context "with the --accrediting-provider option" do
      before do
        execute_edit(arguments: [rolled_over_provider.provider_code, "--accrediting-provider"])
      end

      it "updates the providers accredited provider to accredited_body" do
        expect(rolled_over_provider.reload.accrediting_provider).to eq "accredited_body"
      end
    end

    context "with the --not-accrediting-provider option" do
      let(:accrediting_provider) { "Y" }
      before do
        execute_edit(arguments: [rolled_over_provider.provider_code, "--not-accrediting-provider"])
      end

      it "updates the providers accredited provider to accredited_body" do
        expect(rolled_over_provider.reload.accrediting_provider).to eq "not_an_accredited_body"
      end
    end
  end

  context "when a non-existent user tries to edit a course" do
    let!(:requester) { create(:user, email: "someother@email.com") }

    it "raises an error" do
      expect { execute_edit(arguments: [rolled_over_provider.provider_code]) }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find User/)
    end
  end
end
