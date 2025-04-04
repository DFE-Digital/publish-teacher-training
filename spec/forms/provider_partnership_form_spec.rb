# frozen_string_literal: true

require "rails_helper"

describe ProviderPartnershipForm, type: :model do
  subject { described_class.new(user, model) }

  let(:user) { create(:user) }
  let(:provider) { create(:provider) }
  let(:model) { create(:provider_partnership, training_provider: provider) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:description) }

    context "word count" do
      before do
        subject.description = Faker::Lorem.sentence(word_count: 251)
        subject.valid?
      end

      it "validates the word count for the description" do
        expect(subject).not_to be_valid
        expect(subject.errors[:description])
          .to include(I18n.t("activemodel.errors.models.provider_partnership_form.attributes.description.too_long"))
      end
    end
  end

  describe "#stash" do
    subject { described_class.new(user, model, params:).stash }

    let(:accredited_provider) { create(:provider, :accredited_provider) }
    let(:params) do
      {
        accredited_provider_id: accredited_provider.id,
        description: "Foo",
      }
    end

    it { is_expected.to be_truthy }
  end

  describe "#accredited_provider" do
    subject { described_class.new(user, model, params:).accredited_provider }

    let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
    let(:next_recruitment_cycle) { create(:recruitment_cycle, :next) }
    let(:model) { create(:provider_partnership) }
    let(:accredited_provider) { create(:provider, :accredited_provider) }
    let(:params) do
      {
        accredited_provider_id: accredited_provider.id,
        description: "Foo",
      }
    end

    it "returns the accredited provider" do
      expect(subject).to eq(accredited_provider)
    end

    context "when accredited provider is in the next recruitment cycle" do
      let(:accredited_provider_in_next_cycle) { create(:provider, :accredited_provider, recruitment_cycle: next_recruitment_cycle) }
      let(:params) do
        {
          accredited_provider_id: accredited_provider_in_next_cycle.id,
          description: "Foo",
        }
      end

      before do
        allow(RecruitmentCycle).to receive(:current).and_return(next_recruitment_cycle)
      end

      it "returns the accredited provider from the next cycle" do
        expect(subject).to eq(accredited_provider_in_next_cycle)
      end
    end
  end

  describe "#save!" do
    subject { described_class.new(user, model, params:) }

    let(:accredited_provider) { create(:provider, :accredited_provider, users: [create(:user)]) }
    let(:params) do
      {
        accredited_provider_id: accredited_provider.id,
        description: "Foo",
      }
    end

    context "when no partnership exists" do
      it "correctly sets the enrichment structure" do
        expect { subject.save! }
          .to change(model, :description).to(params[:description])
      end
    end

    context "when provider has existing accredited provider enrichments" do
      let(:accredited_provider) { create(:accredited_provider) }
      let(:model) { create(:provider_partnership, training_provider: provider, accredited_provider:, description: "Existing") }

      it "updates the provider with the new accredited provider information" do
        subject.save!

        expect(model.accredited_provider.provider_code).to eq(accredited_provider.provider_code)
        expect(model.description).to eq("Foo")
      end
    end
  end
end
