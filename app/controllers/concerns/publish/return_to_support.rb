# frozen_string_literal: true

module Publish
  # Lets Support send an admin into a Publish flow and bring them back afterwards.
  #
  # Controllers including this concern must implement:
  # - support_return_path
  # - publish_return_path
  #
  # List/flow state for the Support return trip lives under params[:support_return]
  # so it cannot collide with Publish's own query params (e.g. page).
  module ReturnToSupport
    extend ActiveSupport::Concern

    included do
      helper_method :returning_to_support?,
                    :support_return_params,
                    :return_path
    end

  private

    def returning_to_support?
      params[:return_to] == "support" && current_user.admin?
    end

    # Keys permitted inside params[:support_return]. Override per flow.
    def support_return_param_keys
      []
    end

    # Override when the nested bag needs shaping beyond permit + compact.
    def support_flow_params
      permitted_support_return_params
    end

    def permitted_support_return_params
      raw = params[:support_return]
      return {} if raw.blank?

      permitted = if raw.respond_to?(:permit)
                    raw.permit(*support_return_param_keys)
                  else
                    ActionController::Parameters.new(raw).permit(*support_return_param_keys)
                  end

      permitted.to_h.compact_blank.symbolize_keys
    end

    def support_return_params
      return {} unless returning_to_support?

      flow = support_flow_params
      { return_to: "support" }.tap do |result|
        result[:support_return] = flow if flow.present?
      end
    end

    def return_path
      returning_to_support? ? support_return_path : publish_return_path
    end
  end
end
