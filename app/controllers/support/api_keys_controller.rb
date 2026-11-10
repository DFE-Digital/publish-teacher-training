# frozen_string_literal: true

module Support
  class APIKeysController < ApplicationController
    before_action :set_api_key, only: %i[revoke destroy]

    def index
      @text_search = params.permit(:text_search, :page)[:text_search]
      @pagy, @api_keys = pagy(APIKey.active.search(@text_search).order(created_at: :desc))
    end

    def new
      @api_key = APIKey.new(submission_token: SecureRandom.uuid)
    end

    def create
      @api_key = APIKeys::Creator.call(name: api_key_params[:name], email: api_key_params[:email], submission_token: params[:submission_token])

      if @api_key.persisted?
        no_store
        render :show, status: :created
      elsif @api_key.errors.of_kind?(:submission_token, :taken)
        render :already_created, status: :conflict
      else
        render :new, status: :unprocessable_content
      end
    end

    def revoke; end

    def destroy
      @api_key.revoke!
      redirect_to support_api_keys_path, flash: { success: t(".revoked") }
    end

  private

    def set_api_key
      @api_key = APIKey.active.find(params[:id])
    end

    def api_key_params
      params.expect(api_key: %i[name email])
    end
  end
end
