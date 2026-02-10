# # frozen_string_literal: true

class ALevelsWizard
  module Steps
    class ALevelEquivalencies
      include DfE::Wizard::Step

      attribute :accept_a_level_equivalency, :string
      attribute :additional_a_level_equivalencies, :string

      MAXIMUM_ADDITIONAL_A_LEVEL_EQUIVALENCY_WORDS = 250
      validates :accept_a_level_equivalency, presence: true
      validates :accept_a_level_equivalency, inclusion: { in: %w[yes no] }

      validates :additional_a_level_equivalencies,
                words_count: {
                  maximum: MAXIMUM_ADDITIONAL_A_LEVEL_EQUIVALENCY_WORDS,
                  message: ->(object, error) { object.words_count_error_message(error) },
                },
                if: :accept_a_level_equivalency?,
                allow_blank: true

      def self.permitted_params
        %i[accept_a_level_equivalency additional_a_level_equivalencies]
      end

      def words_count_error_message(error)
        word_count = error[:value].scan(/\S+/).size
        excess_words = word_count - MAXIMUM_ADDITIONAL_A_LEVEL_EQUIVALENCY_WORDS

        I18n.t(
          "activemodel.errors.models.a_levels_wizard/steps/a_level_equivalencies.attributes.additional_a_level_equivalencies.too_long",
          maximum: MAXIMUM_ADDITIONAL_A_LEVEL_EQUIVALENCY_WORDS,
          count: excess_words,
        )
      end

      def accept_a_level_equivalency?
        accept_a_level_equivalency == "yes"
      end
    end
  end
end
