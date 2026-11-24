# frozen_string_literal: true

# An edit of a saved course through CourseWizard's edit journey, on an in-memory
# repository: `start_edit_of(entry)` is the request that opens the edit, and
# `edit_request(step, params)` builds the wizard for a later request, carrying
# the step the edit opened on as return_to_review, as its URLs do.
RSpec.shared_context "edit_course_wizard" do
  let(:repository) { DfE::Wizard::Repository::InMemory.new }
  let(:provider) { create(:provider) }

  def edit_request(step = nil, params = {})
    CourseWizard.new(
      state_store: CourseWizard::StateStores::CourseWizardStore.new(repository:),
      current_step: step,
      current_step_params: { return_to_review: @opening_step&.to_s }.compact.merge(params),
      journey: :edit,
    ).tap do |wizard|
      wizard.provider_code = provider.provider_code
      wizard.recruitment_cycle_year = provider.recruitment_cycle_year
      wizard.state_key = "edit-key"
      wizard.record = Course.find(course.id) # loaded per request, as the controller does
      wizard.unit = @unit
    end
  end

  # Seeds the edit from the course and returns the step it opens on, as the
  # controller's new action does
  def start_edit_of(entry)
    @unit = CourseWizard.unit_for(entry)
    wizard = edit_request
    wizard.state_store.write(CourseWizard::Mapper.new.to_answers(wizard.record))
    @opening_step = wizard.opening_step(entry)
    wizard.clear_state unless @opening_step
    @opening_step
  end

  # Saves a step as the edit controller does
  def answer(step, answers)
    wizard = edit_request(step, { step => answers })
    raise "#{step} did not save: #{wizard.current_step.errors.full_messages}" unless wizard.save_current_step

    wizard
  end

  def changes?(wizard)
    CourseWizard::Operations::UpdateCourse.new(wizard:).changes?
  end
end
