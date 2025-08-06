# frozen_string_literal: true

module Publish
  class TrainingWithDisabilitiesForm < BaseProviderForm
    include Rails.application.routes.url_helpers

    validates :train_with_disability, presence: { message: "Enter details about training with disabilities" }, if: :training_with_disabilities_changed?

    validates :train_with_disability, words_count: { maximum: 250, message: "Reduce the word count for your disabilities" }

    def initialize(model, params: {}, redirect_params: {}, course_code: nil)
      super(model, params:)
      @redirect_params = redirect_params
      @course_code = course_code
    end

    FIELDS = %i[
      train_with_disability
    ].freeze

    attr_accessor(*FIELDS)
    attr_reader :redirect_params, :course_code

    def update_success_path
      case redirection_key
      when "goto_preview"
        preview_publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          provider.recruitment_cycle_year,
          course_code,
        )
      when "goto_provider"
        provider_publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          provider.recruitment_cycle_year,
          course_code,
        )
      when "goto_about_us"
        training_with_disabilities_publish_provider_recruitment_cycle_course_path(
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

    def training_with_disabilities_changed?
      public_send(:train_with_disability) != provider.public_send(:train_with_disability)
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
  end
end
