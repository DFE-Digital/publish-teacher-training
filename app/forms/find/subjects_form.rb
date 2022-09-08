module Find
  class SubjectsForm
    include ActiveModel::Model

    attr_accessor :subject_codes

    validates :subject_codes, presence: true

    def primary_subjects
      primary_subjects = subject_areas.find { |sa| sa.id == "PrimarySubject" }.subjects

      primary_subjects.map do |subject|
        Struct.new(:code, :name).new(subject.subject_code, subject.subject_name)
      end
    end

  private

    def subject_areas
      @subject_areas ||= SubjectArea.includes(:subjects).all
    end
  end
end
