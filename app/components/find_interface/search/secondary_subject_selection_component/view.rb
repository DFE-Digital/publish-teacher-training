module FindInterface
  module Search
    class SecondarySubjectSelectionComponent::View < ViewComponent::Base
      attr_reader :form

      def initialize(form)
        super
        @form = form
      end

      def render?
        form.object.age_group == "secondary"
      end

      def secondary_subjects
        form.object.secondary_subjects.map do |subject|
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

          Struct.new(:code, :name, :financial_info).new(subject.subject_code, subject.subject_name, financial_info)
        end
      end
    end
  end
end
