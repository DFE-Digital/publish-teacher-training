class ALevelsWizard
  module StateStores
    class ALevel
      include DfE::Wizard::StateStore

      def subjects
        repository.record.a_level_subject_requirements
      end

      def any_a_levels?
        subjects.length.positive?
      end

      def another_a_level_needed?
        add_another_a_level == "yes"
      end

      def subject
        subject_hash = repository.record.find_a_level_subject_requirement!(repository.uuid)

        subject_hash["other_subject"].presence || I18n.t("helpers.label.what_a_level_is_required.subject_options.#{subject_hash.fetch('subject', nil)}")
      end
    end
  end
end
