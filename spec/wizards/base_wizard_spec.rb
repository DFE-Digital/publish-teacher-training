# frozen_string_literal: true

require "rails_helper"

RSpec.describe BaseWizard do
  let(:state_key) { "spec-state-key" }
  let(:context) { { year: "2027" } }

  before do
    stub_const("BaseWizardSpecFirst", Class.new do
      include DfE::Wizard::Step

      attribute :name, :string
      validates :name, presence: true

      def self.permitted_params = %i[name]
    end)

    stub_const("BaseWizardSpecSecond", Class.new do
      include DfE::Wizard::Step

      attribute :colour, :string
      validates :colour, presence: true

      def self.permitted_params = %i[colour]
    end)

    stub_const("BaseWizardSpecCommit", Class.new do
      def initialize(repository:, step:) # rubocop:disable Lint/UnusedMethodArgument
        @wizard = step.wizard
      end

      def execute
        @wizard.committed = true
        { success: true }
      end
    end)

    stub_const("BaseWizardSpecWizard", Class.new(described_class) do
      step :first, BaseWizardSpecFirst
      step :second, BaseWizardSpecSecond
      commit_with BaseWizardSpecCommit

      attr_accessor :committed

      def build_step_path(_helpers, step_id, **options)
        ["/wizard/#{state_key}/#{step_id}", options.to_query.presence].compact.join("?")
      end

      def build_exit_path(_helpers) = "/exit"
    end)
  end

  after { Rails.cache.clear }

  def wizard_on(step, params = {})
    BaseWizardSpecWizard.new(
      state_key:,
      context:,
      current_step: step,
      current_step_params: ActionController::Parameters.new(params),
    )
  end

  def save(step, attributes)
    expect(wizard_on(step, step => attributes).save_current_step).to be(true)
  end

  describe ".start" do
    it "starts a new journey on the first step" do
      wizard = BaseWizardSpecWizard.start(context:)

      expect(wizard.current_step_name).to eq(:first)
      expect(wizard.state_key).to be_present
      expect(wizard.current_step_path).to eq("/wizard/#{wizard.state_key}/first")
    end
  end

  describe "the step order" do
    it "goes through the form steps, then check answers, then exit" do
      expect(wizard_on(:first).next_step).to eq(:second)
      expect(wizard_on(:second).next_step).to eq(:check_answers)
      expect(wizard_on(:check_answers).next_step).to eq(:exit)
    end

    it "goes back through the steps, then to the fallback" do
      expect(wizard_on(:check_answers).previous_step_path(fallback: "/exit")).to eq("/wizard/#{state_key}/second")
      expect(wizard_on(:second).previous_step_path(fallback: "/exit")).to eq("/wizard/#{state_key}/first")
      expect(wizard_on(:first).previous_step_path(fallback: "/exit")).to eq("/exit")
    end
  end

  describe "#final_step?" do
    it "is true only on check answers" do
      expect(wizard_on(:second)).not_to be_final_step
      expect(wizard_on(:check_answers)).to be_final_step
    end
  end

  describe "after a Change link" do
    it "links to the step with return_to_review" do
      expect(wizard_on(:check_answers).change_path(:second)).to eq("/wizard/#{state_key}/second?return_to_review=second")
    end

    it "links to the first step by default" do
      expect(wizard_on(:check_answers).change_path).to eq("/wizard/#{state_key}/first?return_to_review=first")
    end

    it "continues to check answers when every step is saved" do
      save(:first, name: "Ada")
      save(:second, colour: "blue")

      expect(wizard_on(:first, return_to_review: "first").next_step).to eq(:check_answers)
    end

    it "continues to the next step when a later step is not saved" do
      save(:first, name: "Ada")

      expect(wizard_on(:first, return_to_review: "first").next_step).to eq(:second)
    end

    it "goes back to check answers" do
      expect(wizard_on(:second, return_to_review: "second").previous_step_path(fallback: "/exit"))
        .to eq("/wizard/#{state_key}/check_answers")
    end
  end

  describe "#save_current_step" do
    it "keeps answers for the next request" do
      save(:first, name: "Ada")

      expect(wizard_on(:second).step(:first).name).to eq("Ada")
    end

    it "does not save an answer that is not valid" do
      expect(wizard_on(:first, first: { name: "" }).save_current_step).to be(false)
    end

    it "runs the commit operation on check answers, which posts no step params" do
      wizard = wizard_on(:check_answers)

      expect(wizard.save_current_step).to be(true)
      expect(wizard.committed).to be(true)
    end
  end

  describe "#exit_path" do
    it "is the path the subclass builds" do
      expect(wizard_on(:first).exit_path).to eq("/exit")
    end
  end

  describe ".repository_for" do
    it "keys answers by wizard class, context and state key" do
      repository = BaseWizardSpecWizard.repository_for(state_key:, context:)

      expect(repository.cache_key).to eq("base_wizard_spec_wizard_2027_spec-state-key")
    end

    it "keeps journeys with different state keys apart" do
      save(:first, name: "Ada")

      other = BaseWizardSpecWizard.new(state_key: "other", context:, current_step: :second)

      expect(other.step(:first).name).to be_nil
    end
  end
end
