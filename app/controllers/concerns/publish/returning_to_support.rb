# frozen_string_literal: true

module Publish
  module ReturningToSupport
    extend ActiveSupport::Concern

    included do
      helper_method :returning_to_support?,
                    :support_return_params,
                    :publish_or_support_schools_path
    end

  private

    def returning_to_support?
      params[:return_to] == "support"
    end

    def support_return_params
      return {} unless returning_to_support?

      { return_to: "support", **support_list_page_params }
    end

    def support_list_page_params
      params[:page].present? ? { page: params[:page] } : {}
    end

    def support_schools_path
      support_recruitment_cycle_provider_schools_path(
        provider.recruitment_cycle_year,
        provider,
        **support_list_page_params,
      )
    end

    def publish_or_support_schools_path
      if returning_to_support?
        support_schools_path
      else
        publish_provider_recruitment_cycle_schools_path
      end
    end
  end
end
