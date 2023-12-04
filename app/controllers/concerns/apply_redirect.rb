# frozen_string_literal: true

module ApplyRedirect
  extend ActiveSupport::Concern

  def apply
    course = RecruitmentCycle.current
                             .providers.find_by(provider_code: params[:provider_code])
                             .courses.find_by(course_code: params[:"#{'course_' if find?}code"])

    if find?
      Rails.logger.info("Course apply conversion. Provider: #{course.provider.provider_code}. Course: #{course.course_code}")
    else
      authorize course
    end

    redirect_to "#{Settings.apply_base_url}/candidate/apply?providerCode=#{course.provider.provider_code}&courseCode=#{course.course_code}", allow_other_host: true
  end

  private

  def find?
    self.class.module_parent == Find
  end
end
