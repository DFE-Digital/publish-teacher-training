# frozen_string_literal: true

RSpec.shared_context "add_course_wizard" do
  subject(:wizard) do
    CourseWizard.new(
      state_store:,
      current_step:,
      current_step_params: { current_step => current_step_params },
    ).tap do |course_wizard|
      course_wizard.provider_code = provider_code
      course_wizard.recruitment_cycle_year = recruitment_cycle_year
    end
  end

  let(:repository) { DfE::Wizard::Repository::InMemory.new }
  let(:state_store) { CourseWizard::StateStores::CourseWizardStore.new(repository:) }
  let(:current_step) { :level }
  let(:current_step_params) { {} }
  let(:provider_code) { "ABC" }
  let(:recruitment_cycle_year) { 2026 }
end
