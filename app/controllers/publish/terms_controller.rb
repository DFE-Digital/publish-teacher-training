# frozen_string_literal: true

module Publish
  class TermsController < ApplicationController
    skip_before_action :check_interrupt_redirects
    skip_before_action :authorize_provider
    skip_after_action :verify_authorized

    def edit
      @accept_terms_form = Interruption::AcceptTermsForm.new(current_user)
    end

    def update
      @accept_terms_form = Interruption::AcceptTermsForm.new(current_user, params: accept_term_params)

      if @accept_terms_form.save!
        redirect_to after_accept_terms_path
      else
        render :edit
      end
    end

  private

    def accept_term_params
      params.expect(publish_interruption_accept_terms_form: [*Interruption::AcceptTermsForm::FIELDS])
    end

    def after_accept_terms_path
      path = session.delete(:redirect_back_to)
      return publish_root_path unless internal_redirect_path?(path)

      path
    end
  end
end
