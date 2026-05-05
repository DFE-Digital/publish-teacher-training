# frozen_string_literal: true

module Support
  class SubjectsController < ApplicationController
    FINANCIAL_INCENTIVE_TEXT_FIELDS = %i[bursary_amount scholarship].freeze
    FINANCIAL_INCENTIVE_BOOLEAN_FIELDS = %i[
      subject_knowledge_enhancement_course_available
      non_uk_bursary_eligible
      non_uk_scholarship_eligible
    ].freeze
    FINANCIAL_INCENTIVE_FIELDS = (FINANCIAL_INCENTIVE_TEXT_FIELDS + FINANCIAL_INCENTIVE_BOOLEAN_FIELDS).freeze

    before_action :assign_subject, only: %i[show edit update]

    def index
      @pagy, @subjects = pagy(filtered_subjects)
    end

    def show
      @financial_incentive = @subject.financial_incentive
    end

    def edit
      @financial_incentive = @subject.financial_incentive || @subject.build_financial_incentive
    end

    def update
      Subject.transaction do
        update_match_synonyms
        update_financial_incentive if should_update_financial_incentive?
      end

      redirect_to support_subject_path(@subject),
                  flash: { success: t("support.flash.updated", resource: Subject.name) }
    end

  private

    def assign_subject
      @subject = Subject.find(params[:id])
    end

    def filtered_subjects
      scope = Subject.order(subject_name: :asc).includes(:subject_group)

      if filter_params[:text_search].present?
        search_term = "%#{filter_params[:text_search]}%"
        scope = scope.where("subject_name ILIKE ?", search_term)
      end

      scope
    end

    def filter_params
      @filter_params ||= params.permit(:text_search, :page)
    end

    def match_synonyms_text
      @match_synonyms_text ||= params.dig(:subject, :match_synonyms_text)
    end

    def synonyms
      return [] if match_synonyms_text.blank?

      match_synonyms_text.split(/[\r\n]+/)
                    .map(&:strip)
                    .reject(&:blank?)
    end

    def update_match_synonyms
      DataHub::Subjects::UpdateMatchSynonyms.new(subject: @subject, synonyms:).call
    end

    def update_financial_incentive
      (@subject.financial_incentive || @subject.build_financial_incentive).update!(financial_incentive_attributes)
    end

    def should_update_financial_incentive?
      financial_incentive_params_present? &&
        (@subject.financial_incentive.present? || financial_incentive_details_provided?)
    end

    def financial_incentive_details_provided?
      financial_incentive_attributes.slice(*FINANCIAL_INCENTIVE_TEXT_FIELDS).values.any?(&:present?) ||
        financial_incentive_attributes.slice(*FINANCIAL_INCENTIVE_BOOLEAN_FIELDS).values.any?
    end

    def financial_incentive_attributes
      @financial_incentive_attributes ||= begin
        attributes = permitted_financial_incentive_params.to_h.symbolize_keys

        FINANCIAL_INCENTIVE_TEXT_FIELDS.each do |field|
          attributes[field] = attributes[field].presence
        end

        FINANCIAL_INCENTIVE_BOOLEAN_FIELDS.each do |field|
          value = attributes[field]
          value = value.last if value.is_a?(Array)
          attributes[field] = ActiveModel::Type::Boolean.new.cast(value) || false
        end

        attributes
      end
    end

    def financial_incentive_params_present?
      params.dig(:subject, :financial_incentive).present?
    end

    def permitted_financial_incentive_params
      params
        .fetch(:subject, ActionController::Parameters.new)
        .fetch(:financial_incentive, ActionController::Parameters.new)
        .permit(*FINANCIAL_INCENTIVE_FIELDS)
    end
  end
end
