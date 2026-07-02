# frozen_string_literal: true

RSpec.shared_context "school_experience_wizard" do
  subject(:wizard) do
    SchoolExperienceWizard.new(
      state_store:,
      current_step:,
      current_step_params: { current_step => current_step_params },
    ).tap do |school_experience_wizard|
      school_experience_wizard.recruitment_cycle_year = course.recruitment_cycle_year
      school_experience_wizard.provider_code = course.provider.provider_code
      school_experience_wizard.course_code = course.course_code
    end
  end

  let(:school_experience_required) { nil }
  let(:school_experience_required_content) { nil }
  let(:course) do
    create(
      :course,
      school_experience_required:,
      school_experience_required_content:,
    )
  end
  let(:repository) { SchoolExperienceWizard::Repositories::SchoolExperienceRepository.new(record: course) }
  let(:state_store) { SchoolExperienceWizard::StateStores::SchoolExperienceWizardStore.new(repository:) }
  let(:current_step) { :experience_required }
  let(:current_step_params) { {} }
end
