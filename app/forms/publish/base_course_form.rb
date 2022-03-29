module Publish
  class BaseCourseForm < BaseModelForm
    alias_method :course, :model

    def save!
      if valid?
        save_action
      else
        false
      end
    end

  private

    def after_successful_save_action
      NotificationService::CourseUpdated.call(course: course)
    end

    def save_action
      assign_attributes_to_model
      if model.save!
        after_successful_save_action
        true
      else
        false
      end
    end
  end
end
