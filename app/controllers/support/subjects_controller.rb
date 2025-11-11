# frozen_string_literal: true

module Support
  class SubjectsController < ApplicationController
    before_action :assign_subject, only: %i[show edit update]

    def index
      @pagy, @subjects = pagy(filtered_subjects)
    end

    def show; end

    def edit; end

    def update
      DataHub::Subjects::AddMatchSynonyms.new(subject: @subject, synonyms:).call

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
  end
end
