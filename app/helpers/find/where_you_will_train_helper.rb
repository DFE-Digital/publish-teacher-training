module Find
  module WhereYouWillTrainHelper
    def published_where_you_will_train_present?(course)
      course.published_placement_selection_criteria.present? && course.published_duration_per_school.present?
    end

    def where_you_will_train_present?(course)
      course.placement_selection_criteria.present? && course.duration_per_school.present?
    end
  end
end
