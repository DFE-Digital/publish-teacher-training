module Find
  module SubjectHelper

    def primary_subject_options(subjects = primary_subjects)
      subjects.map do |subject|
        PrimarySubjectInput.new(subject.subject_code, subject.subject_name)
      end
    end

    def secondary_subject_options(subjects = secondary_subjects)
      subjects.map do |subject|
        financial_incentive = subject.financial_incentive
        financial_info = nil
        if Settings.find_features.bursaries_and_scholarships_announced == true && financial_incentive.present?
          if financial_incentive.scholarship.present? && financial_incentive.bursary_amount.present?
            financial_info = "Scholarships of £#{number_with_delimiter(financial_incentive.scholarship, delimiter: ',')} and bursaries of £#{number_with_delimiter(financial_incentive.bursary_amount, delimiter: ',')} are available"
          elsif financial_incentive.scholarship.present?
            financial_info = "Scholarships of £#{number_with_delimiter(financial_incentive.scholarship, delimiter: ',')} are available"
          elsif financial_incentive.bursary_amount.present?
            financial_info = "Bursaries of £#{number_with_delimiter(financial_incentive.bursary_amount, delimiter: ',')} available"
          end
        end

        SecondarySubjectInput.new(subject.subject_code, subject.subject_name, financial_info)
      end
    end

  private

    # These subjects don’t currently match any courses, and so can be dropped.
    IGNORED_SUBJECTS = ["Philosophy", "Modern Languages", "Ancient Hebrew", "Ancient Greek"].freeze
    SecondarySubjectInput = Struct.new(:code, :name, :financial_info)

    def secondary_subjects
      Subject.includes(:financial_incentive)
             .where(type: %w[SecondarySubject ModernLanguagesSubject])
             .where.not(subject_name: IGNORED_SUBJECTS)
             .order(:subject_name)
    end
  end
end
