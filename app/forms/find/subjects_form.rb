module Find
  class SubjectsForm
    include ActiveModel::Model

    attr_accessor :subjects, :age_group

    validate :subjects_have_been_selected

    def subjects_have_been_selected
      if subjects.blank? && age_group.present?
        errors.add(:subjects, :"#{age_group}_subject")
      elsif subjects.blank?
        errors.add(:subjects, :blank)
      end
    end

    def primary?
      age_group == "primary"
    end

    def secondary?
      age_group == "secondary"
    end
  end
end
