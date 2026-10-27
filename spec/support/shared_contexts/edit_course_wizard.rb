# frozen_string_literal: true

# An edit of a saved course through EditCourseWizard, on an in-memory
# repository: `start_edit_of(entry)` is the request that opens the edit, and
# `edit_request(step, params)` builds the wizard for a later request.
RSpec.shared_context "edit_course_wizard" do
  let(:repository) { DfE::Wizard::Repository::InMemory.new }
  let(:provider) { create(:provider) }

  def edit_request(step = nil, params = {})
    EditCourseWizard.new(
      state_store: CourseWizard::StateStores::CourseWizardStore.new(repository:),
      current_step: step,
      current_step_params: params,
    ).tap do |wizard|
      wizard.provider_code = provider.provider_code
      wizard.recruitment_cycle_year = provider.recruitment_cycle_year
      wizard.state_key = "edit-key"
      wizard.record = Course.find(course.id) # loaded per request, as the controller does
    end
  end

  def start_edit_of(entry)
    edit_request.start(entry:, caller: "/course")
  end

  # Saves a step as the edit controller does
  def answer(step, answers)
    wizard = edit_request(step, { step => answers })
    raise "#{step} did not save: #{wizard.current_step.errors.full_messages}" unless wizard.save_current_step

    wizard.track_review_step
    wizard.clear_off_path_answers
    wizard
  end
end
