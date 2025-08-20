# frozen_string_literal: true

module Publish
  class WhyTrainWithUsForm < BaseProviderForm
    include Rails.application.routes.url_helpers

    validate :about_us_present
    validates :value_proposition, presence: true, if: :value_proposition_changed?

    validate :about_us_word_count
    validates :value_proposition, words_count: { maximum: 100, message: :too_many_words }

    def initialize(model, params: {}, redirect_params: {}, course_code: nil)
      super(model, params:)
      @redirect_params = redirect_params
      @course_code = course_code
    end

    FIELDS = %i[
      value_proposition
      about_us
    ].freeze

    attr_accessor(*FIELDS)
    attr_reader :redirect_params, :course_code

    def update_success_path
      case redirection_key
      when "goto_provider"
        provider_publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          provider.recruitment_cycle_year,
          course_code,
        )
      else
        details_publish_provider_recruitment_cycle_path(
          provider.provider_code,
          provider.recruitment_cycle_year,
        )
      end
    end
    alias_method :back_path, :update_success_path

  private

    def value_proposition_changed?
      changed?(:value_proposition)
    end

    def about_us_changed?
      changed?(:about_us)
    end

    def changed?(attribute)
      public_send(attribute) != provider.public_send(attribute)
    end

    def compute_fields
      provider.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def new_attributes
      params
    end

    def redirection_key
      redirect_params.select { |_k, v| v == "true" }&.keys&.first
    end

    def about_us_present
      return unless about_us_changed?

      if about_us.blank?
        errors.add(:about_us, :blank, provider_name: provider.provider_name)
      end
    end

    def about_us_word_count
      return unless about_us_changed? && about_us.present?

      if about_us.split.size > 100
        errors.add(:about_us, :too_many_words, provider_name: provider.provider_name)
      end
    end
  end
end
