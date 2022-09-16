module Find
  class SubjectsForm
    include ActiveModel::Model

    attr_accessor :subject_codes, :age_group

    validates :subject_codes, presence: true

    def secondary?
      age_group == "secondary"
    end
  end
end
