module Publish
  class TermsController < ApplicationController
    skip_before_action :authenticate

    def edit
      @accept_terms_form = Interruption::AcceptTermsForm.new(current_user)
    end

    def update
      @accept_terms_form = Interruption::AcceptTermsForm.new(current_user, params: accept_term_params)

      if @accept_terms_form.save!
        redirect_to publish_root_path
      else
        render :edit
      end
    end

  private

    def accept_term_params
      params.require(:publish_interruption_accept_terms_form).permit(*Interruption::AcceptTermsForm::FIELDS)
    end
  end
end
