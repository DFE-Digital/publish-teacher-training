module Publish
  module Courses
    module SchoolExperience
      class ExperienceRequiredController < SchoolExperienceController
        def state_store
          if submitted_answer
            # A "yes" answer can't be persisted to the course until the content
            # arrives on the experience_details step, so it's held in the cache.
            SchoolExperienceWizard::StateStores::SchoolExperienceWizardStore.new(
              repository: SchoolExperienceWizard::Repositories::SchoolExperienceCacheRepository.new(
                provider_code: params[:provider_code],
                recruitment_cycle_year: params[:recruitment_cycle_year],
                course_code: params[:course_code],
              ),
            )
          elsif submitted_answer == false || action_name == "new"
            # A "no" answer is written to the course; the new action reads the
            # current value from it to pre-select the answer.
            SchoolExperienceWizard::StateStores::SchoolExperienceWizardStore.new(
              repository: SchoolExperienceWizard::Repositories::SchoolExperienceRepository.new(
                record: @course,
              ),
            )
          else
            # School experience is optional. With no answer there's nothing to
            # save, so we don't load a repository and let the wizard route back
            # to the course.
            SchoolExperienceWizard::StateStores::SchoolExperienceWizardStore.new
          end
        end

        def submitted_answer
          ActiveModel::Type::Boolean.new.cast(params.dig(:experience_required, :experience_required))
        end
      end
    end
  end
end
