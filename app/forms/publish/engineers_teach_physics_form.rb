module Publish
  class EngineersTeachPhysicsForm < BaseCourseForm
    alias_method :course, :model

    FIELDS = %i[campaign_name subjects_ids skip_languages_goto_confirmation].freeze

    attr_accessor(*FIELDS)

    validates :campaign_name, inclusion: { in: Course.campaign_names.keys }

  private

    def compute_fields
      course.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def fields_to_ignore_before_save
      ["subjects_ids", "skip_languages_goto_confirmation"]
    end

    def assign_subjects_service
      @assign_subjects_service ||= ::Courses::AssignSubjectsService.call(course:, subject_ids: params[:subjects_ids])
    end

    def save_action
      # binding.pry
      assign_attributes_to_model
      if assign_subjects_service.save && model.save!
        after_successful_save_action
        true
      else
        false
      end
    end
  end
end
