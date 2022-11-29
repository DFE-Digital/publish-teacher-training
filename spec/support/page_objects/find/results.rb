# frozen_string_literal: true

module PageObjects
  module Find
    class Results < PageObjects::Base
      set_url "/find/results{?query*}"

      class Courses < SitePrism::Section
        element :provider_name, '[data-qa="course__provider_name"]'
        element :course_name, '[data-qa="course__name"]'
        element :study_mode, '[data-qa="course__study_mode"]'
        # TODO: nearest_location?
        element :qualification, '[data-qa="course__qualification"]'
        element :funding_options, '[data-qa="course__funding_options"]'
        element :degree_required, '[data-qa="course__degree_required"]'
        element :visa_sponsorship, '[data-qa="course__visa_sponsorship"]'
      end

      class Send < SitePrism::Section
        element :checkbox, 'input[name="send_courses"]'
      end

      class Vacancies < SitePrism::Section
        element :checkbox, 'input[name="has_vacancies"]'
      end

      class StudyType < SitePrism::Section
        element :full_time, '[data-qa="full_time"]'
        element :part_time, '[data-qa="part_time"]'
      end

      class Qualifications < SitePrism::Section
        element :qts, '[data-qa="qts_only"]'
        element :pgce_with_qts, '[data-qa="pgde_pgce_with_qts"]'
        element :other, '[data-qa="other"]'
      end

      class DegreeGrade < SitePrism::Section
        element :show_all_courses, '[data-qa="show_all_courses"]'
        element :two_two, '[data-qa="two_two"]'
        element :third_class, '[data-qa="third_class"]'
        element :not_required, '[data-qa="not_required"]'
      end

      class Visa < SitePrism::Section
        element :checkbox, 'input[name="can_sponsor_visa"]'
      end

      class EngineersTeachPhysics < SitePrism::Section
        element :legend, "legend"
        element :checkbox, 'input[name="engineers_teach_physics"]'
      end

      class Funding < SitePrism::Section
        element :checkbox, 'input[name="funding"]'
      end

      sections :courses, Courses, '[data-qa="course"]'
      section :send, Send, '[data-qa="filters__send"]'
      section :vacancies, Vacancies, '[data-qa="filters__vacancies"]'
      section :study_type, StudyType, '[data-qa="filters__study_type"]'
      section :qualifications, Qualifications, '[data-qa="filters__qualifications"]'
      section :degree_grade, DegreeGrade, '[data-qa="filters__degree_required"]'
      section :visa, Visa, '[data-qa="filters__visa"]'
      section :engineers_teach_physics_filter, EngineersTeachPhysics, '[data-qa="filters__engineers_teach_physics"]'
      section :funding, Funding, '[data-qa="filters__funding"]'

      element :apply_filters_button, '[data-qa="apply-filters"]'
    end
  end
end
