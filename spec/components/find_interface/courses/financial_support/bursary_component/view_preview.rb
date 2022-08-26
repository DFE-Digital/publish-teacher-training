# frozen_string_literal: true

module FindInterface::Courses::FinancialSupport::BursaryComponent
  class ViewPreview < ViewComponent::Preview
    def default
      course = Course.new(course_code: "FIND",
        provider: Provider.new(provider_code: "DFE"),
        program_type: "higher_education_programme",
        level: "further_education",
        subjects: [Subject.new(id: 49, type: "SecondarySubject", subject_code: "C7", subject_name: "Physical education with an EBacc subject", financial_incentive: FinancialIncentive.new(bursary_amount: 3000))])
      render FindInterface::Courses::FinancialSupport::BursaryComponent::View.new(course)
    end
  end
end
