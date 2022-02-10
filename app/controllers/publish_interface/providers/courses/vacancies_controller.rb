module PublishInterface
  module Providers
    module Courses
      class VacanciesController < PublishInterfaceController
        def edit
          authorize(provider)

          @course_vacancies_form = CourseVacanciesForm.new(course)
          @site_statuses = @course_vacancies_form.running_site_statuses
        end

        def update
          authorize(provider)

          @course_vacancies_form = CourseVacanciesForm.new(course, params: vacancy_params)

          if @course_vacancies_form.save!
            flash[:success] = I18n.t("success.published")

            redirect_to publish_provider_recruitment_cycle_courses_path(
              provider.provider_code,
              recruitment_cycle.year,
            )
          else
            @site_statuses = @course_vacancies_form.running_site_statuses

            render :edit
          end
        end

      private

        def course
          @course ||= provider.courses.find_by!(course_code: params[:code])
        end

        def provider
          @provider ||= recruitment_cycle.providers.find_by(recruitment_cycle: recruitment_cycle, provider_code: params[:provider_code])
        end

        def recruitment_cycle
          cycle_year = params[:recruitment_cycle_year] || Settings.current_recruitment_cycle_year

          @recruitment_cycle ||= RecruitmentCycle.find_by!(year: cycle_year)
        end

        def vacancy_params
          return { change_vacancies_confirmation: nil } if params[:publish_interface_course_vacancies_form].blank?

          params
            .require(:publish_interface_course_vacancies_form)
            .permit(
              CourseVacanciesForm::FIELDS,
              site_statuses_attributes: %i[id vac_status full_time part_time],
            )
        end
      end
    end
  end
end
