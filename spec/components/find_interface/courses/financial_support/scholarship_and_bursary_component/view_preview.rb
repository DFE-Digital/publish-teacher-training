# frozen_string_literal: true

module Find::Courses::FinancialSupport::ScholarshipAndBursaryComponent
  class ViewPreview < ViewComponent::Preview
    def physic_with_scholarship_early_career_and_scholarship_body
      course = Course.new(subjects: [Subject.new(id: 22, type: "SecondarySubject", subject_code: "F3", subject_name: "Physics", financial_incentive: FinancialIncentive.new(scholarship: 2000,
        bursary_amount: 3000,
        early_career_payments: 2000))])

      render Find::Courses::FinancialSupport::ScholarshipAndBursaryComponent::View.new(course.decorate)
    end

    def chemistry_with_scholarship_early_career_and_scholarship_body
      course = Course.new(subjects: [Subject.new(id: 22, type: "SecondarySubject", subject_code: "F3", subject_name: "Chemistry", financial_incentive: FinancialIncentive.new(scholarship: 2000,
        bursary_amount: 3000,
        early_career_payments: 2000))])

      render Find::Courses::FinancialSupport::ScholarshipAndBursaryComponent::View.new(course.decorate)
    end

    def computing_with_scholarship_early_career_and_scholarship_body
      course = Course.new(subjects: [Subject.new(id: 22, type: "SecondarySubject", subject_code: "11", subject_name: "Computing", financial_incentive: FinancialIncentive.new(scholarship: 2000,
        bursary_amount: 3000,
        early_career_payments: 2000))])

      render Find::Courses::FinancialSupport::ScholarshipAndBursaryComponent::View.new(course.decorate)
    end

    def maths_with_scholarship_early_career_and_scholarship_body
      course = Course.new(subjects: [Subject.new(id: 22, type: "SecondarySubject", subject_code: "G1", subject_name: "Maths", financial_incentive: FinancialIncentive.new(scholarship: 2000,
        bursary_amount: 3000,
        early_career_payments: 2000))])

      render Find::Courses::FinancialSupport::ScholarshipAndBursaryComponent::View.new(course.decorate)
    end

    def french_with_scholarship_early_career_and_scholarship_body
      course = Course.new(subjects: [Subject.new(id: 22, type: "SecondarySubject", subject_code: "15", subject_name: "French", financial_incentive: FinancialIncentive.new(scholarship: 2000,
        bursary_amount: 3000,
        early_career_payments: 2000))])

      render Find::Courses::FinancialSupport::ScholarshipAndBursaryComponent::View.new(course.decorate)
    end

    def german_with_scholarship_early_career_and_scholarship_body
      course = Course.new(subjects: [Subject.new(id: 22, type: "SecondarySubject", subject_code: "17", subject_name: "German", financial_incentive: FinancialIncentive.new(scholarship: 2000,
        bursary_amount: 3000,
        early_career_payments: 2000))])

      render Find::Courses::FinancialSupport::ScholarshipAndBursaryComponent::View.new(course.decorate)
    end

    def spanish_with_scholarship_early_career_and_scholarship_body
      course = Course.new(subjects: [Subject.new(id: 22, type: "SecondarySubject", subject_code: "22", subject_name: "Spanish", financial_incentive: FinancialIncentive.new(scholarship: 2000,
        bursary_amount: 3000,
        early_career_payments: 2000))])

      render Find::Courses::FinancialSupport::ScholarshipAndBursaryComponent::View.new(course.decorate)
    end

    def without_scholarship_and_scholarship_body
      course = Course.new(subjects: [Subject.new(id: 22, type: "SecondarySubject", subject_code: "F8", subject_name: "Physics", financial_incentive: FinancialIncentive.new(scholarship: 2000,
        bursary_amount: 3000))])

      render Find::Courses::FinancialSupport::ScholarshipAndBursaryComponent::View.new(course.decorate)
    end

    def with_scholarship_only
      course = Course.new(subjects: [Subject.new(id: 22, type: "SecondarySubject", subject_code: "F8", subject_name: "Art", financial_incentive: FinancialIncentive.new(scholarship: 2000,
        bursary_amount: 3000))])

      render Find::Courses::FinancialSupport::ScholarshipAndBursaryComponent::View.new(course.decorate)
    end
  end
end
