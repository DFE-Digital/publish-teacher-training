module TouchCourse
  extend ActiveSupport::Concern

  included do
    after_save :touch_course
  end

private

  def touch_course
    course.update_changed_at
  end
end
