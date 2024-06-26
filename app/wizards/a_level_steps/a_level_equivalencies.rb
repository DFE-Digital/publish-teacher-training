# frozen_string_literal: true

module ALevelSteps
  class ALevelEquivalencies < DfE::Wizard::Step
    delegate :exit_path, to: :wizard
    attr_accessor :accept_a_level_equivalencies, :additional_a_level_equivalencies

    MAXIMUM_ADDITIONAL_A_LEVEL_EQUIVALENCY_WORDS = 250
    validates :accept_a_level_equivalencies, presence: true

    validates :additional_a_level_equivalencies,
              words_count: {
                maximum: MAXIMUM_ADDITIONAL_A_LEVEL_EQUIVALENCY_WORDS,
                message: ->(object, error) { object.words_count_error_message(error) }
              },
              if: :accept_a_level_equivalencies?,
              allow_blank: true

    def self.permitted_params
      %i[accept_a_level_equivalencies additional_a_level_equivalencies]
    end

    def next_step
      :exit
    end

    def words_count_error_message(error)
      word_count = error[:value].scan(/\S+/).size
      excess_words = word_count - MAXIMUM_ADDITIONAL_A_LEVEL_EQUIVALENCY_WORDS

      I18n.t(
        'activemodel.errors.models.a_level_equivalencies.attributes.additional_a_level_equivalencies.too_long',
        maximum: MAXIMUM_ADDITIONAL_A_LEVEL_EQUIVALENCY_WORDS,
        count: excess_words
      )
    end

    def accept_a_level_equivalencies?
      accept_a_level_equivalencies == 'yes'
    end
  end
end
