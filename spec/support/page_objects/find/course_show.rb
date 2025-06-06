# frozen_string_literal: true

module PageObjects
  module Find
    class CourseShow < PageObjects::Base
      set_url "/course/{provider_code}/{course_code}"

      element :page_heading, ".govuk-heading-xl"
      element :sub_title, "[data-qa=course__provider_name]"
      element :extended_qualification_descriptions, "[data-qa=course__extended_qualification_descriptions]"
      element :accredited_provider, "[data-qa=course__ratifying_provider]"
      element :provider_website, "[data-qa=course__provider_website]"
      element :vacancies, "[data-qa=course__vacancies]"
      element :about_course, "[data-qa=course__about_course]"
      element :interview_process, "[data-qa=course__interview_process]"
      element :school_placements, "[data-qa=course__about_schools]"
      element :uk_fees, "[data-qa=course__uk_fees]"
      element :eu_fees, "[data-qa=course__eu_fees]"
      element :fee_details, "[data-qa=course__fee_details]"
      element :international_fees, "[data-qa=course__international_fees]"
      element :salary_details, "#section-salary"
      element :scholarship_amount, "[data-qa=course__scholarship_and_bursary_amount]"
      element :early_career_payment_details, "[data-qa=course__early_career_payment_details]"
      element :financial_support_details, "[data-qa=course__financial_support_details]"
      element :required_qualifications, "[data-qa=course__required_qualifications]"
      element :train_with_us, "[data-qa=course__about_provider]"
      element :about_accrediting_provider, "[data-qa=course__about_accrediting_provider]"
      element :train_with_disability, "[data-qa=course__train_with_disabilities]"
      element :course_advice, "#section-advice"
      element :course_support_and_advice, "#section-support-and-advice"
      element :course_apply, "#section-apply"
      element :back_link, "[data-qa=page-back]"
      element :end_of_cycle_notice, "[data-qa=course__end_of_cycle_notice]"
      element :feedback_link, "[data-qa=feedback-link]"
    end
  end
end
