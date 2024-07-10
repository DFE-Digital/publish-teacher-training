# frozen_string_literal: true

module PageObjects
  module Publish
    class CoursePreview < PageObjects::Base
      set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/preview'

      element :sub_title, '[data-qa=course__provider_name]'
      element :description, '[data-qa=course__description]'
      element :accredited_provider, '[data-qa=course__accredited_provider]'
      element :provider_website, '[data-qa=course__provider_website]'
      element :vacancies, '[data-qa=course__vacancies]'
      element :about_course, '[data-qa=course__about_course]'
      element :interview_process, '[data-qa=course__interview_process]'
      element :school_placements, '[data-qa="course__about_schools"]'
      element :uk_fees, '[data-qa=course__uk_fees]'
      element :fee_details, '[data-qa=course__fee_details]'
      element :international_fees, '[data-qa=course__international_fees]'
      element :loan_details, '[data-qa=course__loan_details]'
      element :scholarship_and_bursary_details, '[data-qa=course__scholarship_and_bursary_details]'
      element :scholarship_amount, '[data-qa=course__scholarship_amount]'
      element :bursary_details, '[data-qa=course__bursary_details]'
      element :bursary_amount, '[data-qa=course__bursary_amount]'
      element :early_career_payment_details, '[data-qa=course__early_career_payment_details]'
      element :financial_support_details, '[data-qa=course__financial_support_details]'
      element :required_qualifications, '[data-qa=course__required_qualifications]'
      element :train_with_us, '[data-qa=course__about_provider]'
      element :about_accrediting_provider, '[data-qa=course__about_accrediting_provider]'
      element :train_with_disability, '[data-qa=course__train_with_disabilities]'
      element :course_advice, '#section-advice'
      element :course_apply, '#section-apply'
      element :study_sites_table, '#course_study_sites'
      element :school_placements_table, '#course_school_placements'
      element :salary_details, '[data-qa=course__salary_details]'
    end
  end
end
