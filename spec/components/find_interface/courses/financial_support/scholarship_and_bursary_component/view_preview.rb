# frozen_string_literal: true

module FindInterface::Courses::FinancialSupport::ScholarshipAndBursaryComponent
  class ViewPreview < ViewComponent::Preview
    def with_scholarship_early_career_and_scholarship_body
      course = Course.new(subjects: [Subject.new(id: 22, type: "SecondarySubject", subject_code: "F8", subject_name: "Physics", financial_incentive: FinancialIncentive.new(scholarship: 2000,
        bursary_amount: 3000,
        early_career_payments: 2000))])

      render FindInterface::Courses::FinancialSupport::ScholarshipAndBursaryComponent::View.new(course.decorate)
    end

    def without_scholarship_and_scholarship_body
      course = Course.new(subjects: [Subject.new(id: 22, type: "SecondarySubject", subject_code: "F8", subject_name: "Physics", financial_incentive: FinancialIncentive.new(scholarship: 2000,
        bursary_amount: 3000))])

      render FindInterface::Courses::FinancialSupport::ScholarshipAndBursaryComponent::View.new(course.decorate)
    end

    def with_scholarship_only
      course = Course.new(subjects: [Subject.new(id: 22, type: "SecondarySubject", subject_code: "F8", subject_name: "Art", financial_incentive: FinancialIncentive.new(scholarship: 2000,
        bursary_amount: 3000))])

      render FindInterface::Courses::FinancialSupport::ScholarshipAndBursaryComponent::View.new(course.decorate)
    end
  end
end
