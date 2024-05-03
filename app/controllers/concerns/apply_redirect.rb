# frozen_string_literal: true

module ApplyRedirect
  extend ActiveSupport::Concern

  def apply
    course = RecruitmentCycle.current
                             .providers.case_insensitive_search(params[:provider_code])
                             .courses.case_insensitive_search(course_code_param).first!
    if find?
      Rails.logger.info("Course apply conversion. Provider: #{course.provider.provider_code}. Course: #{course.course_code}")
    else
      authorize course
    end

    redirect_to "#{Settings.apply_base_url}/candidate/apply?providerCode=#{course.provider.provider_code}&courseCode=#{course.course_code}", allow_other_host: true
  end

  private

  def course_code_param
    if find?
      params[:course_code]
    else
      params[:code]
    end
  end

  def find?
    self.class.module_parent == Find
  end
end
