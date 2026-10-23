# frozen_string_literal: true

# An edit of a saved course through CourseWizard, on an in-memory
# repository: `start_edit_of(unit)` is the entry point request, and
# `edit_request(step)` builds the wizard for a later request.
RSpec.shared_context "edit_course_wizard" do
  let(:repository) { DfE::Wizard::Repository::InMemory.new }
  let(:provider) { create(:provider) }

  def edit_request(step = nil, params = {})
    CourseWizard.new(
      state_store: CourseWizard::StateStores::CourseWizardStore.new(repository:),
      current_step: step,
      current_step_params: params,
      record: course,
    ).tap do |wizard|
      wizard.provider_code = provider.provider_code
      wizard.recruitment_cycle_year = provider.recruitment_cycle_year
      wizard.state_key = "edit-key"
    end
  end

  def start_edit_of(unit)
    edit_request.start_edit(unit:, caller: "/course")
  end
end
