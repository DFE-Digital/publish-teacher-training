# frozen_string_literal: true

RSpec.shared_context "a_levels_wizard" do
  subject(:wizard) do
    ALevelsWizard.new(
      state_store:,
      current_step:,
      current_step_params: { current_step => current_step_params },
    )
  end

  let(:course) { create(:course, a_level_subject_requirements:) }
  let(:a_level_subject_requirements) { [] }
  let(:repository) { ALevelsWizard::Repositories::ALevelRepository.new(record: course) }
  let(:state_store) { ALevelsWizard::StateStores::ALevelStore.new(repository:) }
  let(:current_step) { :add_a_level_to_a_list }
  let(:current_step_params) { {} }
end
