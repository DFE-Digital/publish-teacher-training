# frozen_string_literal: true

module Support
  class RevertWithdrawalController < SupportController
    def edit
      provider
      course
    end

    def update
      Support::Courses::RevertWithdrawalService.new(course).call

      redirect_to edit_support_recruitment_cycle_provider_course_path(provider.recruitment_cycle_year, provider, course),
                  flash: { success: t('support.flash.updated', resource: 'Course status') }
    end

    private

    def provider
      @provider ||= recruitment_cycle.providers.find(params[:provider_id])
    end

    def course
      @course ||= provider.courses.find(params[:course_id])
    end
  end
end
