# frozen_string_literal: true

class CourseWizard
  module StateStores
    class CourseWizardStore
      include DfE::Wizard::StateStore

      def further_education_level?
        level == "further_education"
      end

      def primary_level?
        level == "primary"
      end

      def fee_based?
        funding_type == "fee"
      end

      # Employment-based funding types are salary and apprenticeship.
      def salary_based?
        funding_type.in?(%w[salary apprenticeship])
      end

      def undergraduate_degree_with_qts?
        qualification == "undergraduate_degree_with_qts"
      end

      def visa_sponsorship_required?
        ActiveModel::Type::Boolean.new.cast(can_sponsor_student_visa)
      end

      def skilled_worker_visa_sponsorship_required?
        ActiveModel::Type::Boolean.new.cast(can_sponsor_skilled_worker_visa)
      end

      def deadline_for_application_visa_sponsorship_required?
        ActiveModel::Type::Boolean.new.cast(visa_sponsorship_application_deadline_required)
      end

      def design_technology_specialisms?
        secondary_subject_selected?(SecondarySubject.design_technology&.id)
      end

      def physics_specialisms?
        secondary_subject_selected?(SecondarySubject.physics&.id)
      end

      def modern_languages_specialisms?
        secondary_subject_selected?(SecondarySubject.modern_languages&.id)
      end

      # The answers as the course takes them, with the defaults of a TDA
      # course, which has no funding type, study pattern or skilled worker
      # visa question. For check answers and for creating the course.

      def tda?
        undergraduate_degree_with_qts?
      end

      # A TDA course is an apprenticeship
      def funding
        return "apprenticeship" if tda? && funding_type.blank?

        funding_type
      end

      # Salary or apprenticeship, with the TDA default. salary_based? reads
      # the funding type as answered, for the graph.
      def employment_based?
        funding.in?(%w[salary apprenticeship])
      end

      # A TDA course is full time
      def study_modes
        patterns = Array(study_pattern).compact_blank
        return %w[full_time] if patterns.empty? && tda?

        patterns
      end

      # A TDA course cannot sponsor skilled worker visas
      def can_sponsor_skilled_worker_visa_or_default
        return false if tda? && can_sponsor_skilled_worker_visa.nil?

        can_sponsor_skilled_worker_visa
      end

      # The age range, with an "other" range as "14_to_19"
      def age_range
        return age_range_in_years unless age_range_in_years == "other"
        return age_range_in_years if course_age_range_in_years_other_from.blank? || course_age_range_in_years_other_to.blank?

        "#{course_age_range_in_years_other_from}_to_#{course_age_range_in_years_other_to}"
      end

      def master_subject_id
        return if further_education_level?

        primary_level? ? primary_master_subject_id : secondary_master_subject_id
      end

      # The subjects, with each secondary subject's specialisms below it
      def subject_ids
        return [] if further_education_level?
        return [primary_master_subject_id].compact_blank if primary_level?

        [secondary_master_subject_id, subordinate_subject_id].compact_blank.each_with_object([]) { |parent_id, ids|
          ids << parent_id
          ids.concat(specialism_ids_for(parent_id))
        }.uniq
      end

      def selected_school_uuids
        Array(school_uuids).compact_blank
      end

      # Nil when the study sites question was not answered
      def study_site_ids
        return if study_sites_ids.nil?

        Array(study_sites_ids).compact_blank
      end

      def visa_deadline
        CourseWizard::Draft::VisaDeadline.wrap(visa_sponsorship_application_deadline_at)
      end

    private

      def specialism_ids_for(parent_id)
        ids = []
        ids.concat(Array(language_ids)) if modern_languages_specialisms? && parent_id.to_s == SecondarySubject.modern_languages&.id.to_s
        ids.concat(Array(design_technology_ids)) if design_technology_specialisms? && parent_id.to_s == SecondarySubject.design_technology&.id.to_s
        ids.compact_blank
      end

      def secondary_subject_selected?(subject_id)
        return false if subject_id.blank?

        selected_secondary_subject_ids.include?(subject_id.to_s)
      end

      def selected_secondary_subject_ids
        [secondary_master_subject_id, subordinate_subject_id].compact_blank.map(&:to_s)
      end
    end
  end
end
