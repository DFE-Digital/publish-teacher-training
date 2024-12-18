# frozen_string_literal: true

module Publish
  class AboutYourOrganisationForm < BaseProviderForm
    include Rails.application.routes.url_helpers

    validates :train_with_us, presence: { message: 'Enter details about training with you' }, if: :train_with_us_changed?
    validates :train_with_disability, presence: { message: 'Enter details about training with a disability' }, if: :train_with_disability_changed?

    validates :train_with_us, words_count: { maximum: 250, message: 'Reduce the word count for training with you' }
    validates :train_with_disability, words_count: { maximum: 250, message: 'Reduce the word count for training with disabilities and other needs' }

    def initialize(model, params: {}, redirect_params: {}, course_code: nil)
      super(model, params:)
      @redirect_params = redirect_params
      @course_code = course_code
    end

    FIELDS = %i[
      train_with_us
      train_with_disability
    ].freeze

    attr_accessor(*FIELDS)
    attr_reader :redirect_params, :course_code

    def update_success_path
      case redirection_key
      when 'goto_preview'
        preview_publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          provider.recruitment_cycle_year,
          course_code
        )
      when 'goto_provider'
        provider_publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          provider.recruitment_cycle_year,
          course_code
        )
      when 'goto_training_with_disabilities'
        training_with_disabilities_publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          provider.recruitment_cycle_year,
          course_code
        )
      else
        details_publish_provider_recruitment_cycle_path(
          provider.provider_code,
          provider.recruitment_cycle_year
        )
      end
    end
    alias back_path update_success_path

    private

    def train_with_us_changed?
      changed?(:train_with_us)
    end

    def train_with_disability_changed?
      changed?(:train_with_disability)
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
      redirect_params.select { |_k, v| v == 'true' }&.keys&.first
    end
  end
end
