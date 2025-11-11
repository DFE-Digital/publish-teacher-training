# frozen_string_literal: true

module Support
  class SubjectsController < ApplicationController
    def index
      @pagy, @subjects = pagy(Subject.order(subject_name: :asc))
    end

    def show
      @subject = Subject.find(params[:id])
    end

    def edit
      @subject = Subject.find(params[:id])
    end

    def update
      @subject = Subject.find(params[:id])

      if synonyms.present?
        DataHub::Subjects::AddMatchSynonyms.new(subject: @subject, synonyms:).call
      end

      redirect_to support_subject_path(@subject),
                  success: t("support.flash.updated", resource: Subject.name)
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
