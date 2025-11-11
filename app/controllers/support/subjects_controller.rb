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

      DataHub::Subjects::AddMatchSynonyms.new(subject: @subject, synonyms:).call

      redirect_to support_subject_path(@subject),
        success: t("support.flash.updated", resource: Subject.name)
    end

    def synonyms
      params.dig(:subject, :match_synonyms_text).permit
    end
  end
end
