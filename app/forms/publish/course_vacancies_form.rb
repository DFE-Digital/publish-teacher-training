module Publish
  class CourseVacanciesForm < BaseCourseForm
    FIELDS = %i[
      site_statuses
      change_vacancies_confirmation
      has_vacancies
    ].freeze

    attr_accessor(*FIELDS)

    delegate :recruitment_cycle_year, :provider_code, :running_site_statuses, :name, to: :course

    validate :vacancies_confirmation

    def initialize(model, params: {})
      @site_statuses = []
      super
    end

    def site_statuses_attributes=(attributes)
      @site_statuses = attributes.values
    end

  private

    def after_successful_save_action
      NotificationService::CourseVacanciesUpdated.call(
        course:,
        vacancy_statuses:,
      )
    end

    def vacancy_statuses
      if course.has_multiple_running_sites_or_study_modes?
        statuses_attributes.values.map do |value|
          {
            id: value[:id],
            status: value[:vac_status],
          }
        end
      else
        [
          {
            id: statuses_attributes[:id],
            status: statuses_attributes[:vac_status],
          },
        ]
      end
    end

    def compute_fields
      course
        .attributes
        .symbolize_keys
        .slice(*FIELDS)
        .merge(new_attributes)
        .merge(has_vacancies: course.has_vacancies?)
    end

    def assign_attributes_to_model
      model.assign_attributes(model_attributes)
    end

    def model_attributes
      fields
        .symbolize_keys
        .except(*fields_to_ignore_before_save)
        .deep_merge(attributes_for_site_statuses)
    end

    def fields_to_ignore_before_save
      FIELDS
    end

    def attributes_for_site_statuses
      { site_statuses_attributes: statuses_attributes }
    end

    def vacancies_confirmation
      return if change_vacancies_confirmation.present? || params[:site_statuses_attributes].present?

      errors.add(:change_vacancies_confirmation, vacancies_confirmation_error_message)
    end

    def vacancies_confirmation_error_message
      course.has_vacancies? ? :confirm_close_application : :confirm_reopen_application
    end

    def statuses_attributes
      if course.has_multiple_running_sites_or_study_modes?
        attributes_for_multiple_site_statuses
      else
        attributes_for_single_site_status
      end
    end

    def attributes_for_single_site_status
      running_site_statuses.first.attributes.merge(vac_status: single_site_status_vacancy).with_indifferent_access
    end

    def attributes_for_multiple_site_statuses
      params[:site_statuses_attributes].transform_values do |site_status_params|
        site_status_params.except(:full_time, :part_time).merge(vac_status: site_status_vacancy(site_status_params))
      end
    end

    def single_site_status_vacancy
      case params[:change_vacancies_confirmation]

      when "no_vacancies_confirmation"
        "no_vacancies"
      when "has_vacancies_confirmation"
        course.full_time? ? "full_time_vacancies" : "part_time_vacancies"
      end
    end

    def site_status_vacancy(site_status_params)
      return "no_vacancies" if params[:has_vacancies] == "false"

      VacancyStatusDeterminationService.call(
        vacancy_status_full_time: site_status_params[:full_time],
        vacancy_status_part_time: site_status_params[:part_time],
        course:,
      )
    end
  end
end
