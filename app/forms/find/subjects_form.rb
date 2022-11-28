module Find
  class SubjectsForm
    include ActiveModel::Model

    attr_accessor :subjects, :age_group

    validates :subjects, presence: true

    def primary?
      age_group == "primary"
    end

    def secondary?
      age_group == "secondary"
    end
  end
end
