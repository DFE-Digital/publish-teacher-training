# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class WhatALevelIsRequiredController < ALevelRequirementsController
        before_action :load_a_level_subject_requirement, :verify_maximum_a_level_subject_requirements

        def edit
          render :new
        end

      private

        def state_store
          ALevelsWizard::StateStores::ALevelStore.new(
            repository: ALevelsWizard::Repositories::ALevelSubjectRepository.new(
              record: @course,
              uuid: params[:uuid],
            ),
          )
        end

        def add_flash_message
          flash[:success] = t("course.#{@wizard.current_step.model_name.i18n_key}.success_message")
        end

        def verify_maximum_a_level_subject_requirements
          return unless maximum_a_level_subject_requirements? && no_uuid?

          redirect_to publish_provider_recruitment_cycle_course_a_levels_add_a_level_to_a_list_path(
            provider.provider_code,
            provider.recruitment_cycle_year,
            @course.course_code,
          )
        end

        def maximum_a_level_subject_requirements?
          Array(@course.a_level_subject_requirements).size >= ALevelsWizard::Steps::AddALevelToAList::MAXIMUM_NUMBER_OF_A_LEVEL_SUBJECTS
        end

        def no_uuid?
          params[:uuid].blank? && params.dig(current_step_name, :uuid).blank?
        end
      end
    end
  end
end
