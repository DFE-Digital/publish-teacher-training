# frozen_string_literal: true

module Find
  class UniversityDegreeStatusForm
    include ActiveModel::Model
    attr_accessor :university_degree_status

    validates :university_degree_status, presence: true
  end
end
