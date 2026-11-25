# frozen_string_literal: true

module Publish
  # Lets Support send an admin into a Publish flow and bring them back afterwards.
  #
  # Controllers including this concern must also include a path module (or define):
  # - support_return_path(state)
  # - publish_return_path
  #
  # List/flow state for the Support return trip lives under params[:support_return]
  # so it cannot collide with Publish's own query params (e.g. page).
  # Only flat values pass through; nested hashes and arrays are dropped.
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

    def support_flow_params
      raw = params[:support_return]
      return {} unless raw.is_a?(ActionController::Parameters)

      raw.to_unsafe_h.each_with_object({}) { |(key, value), result|
        next unless flat_support_return_value?(value)

        result[key.to_sym] = value
      }.compact_blank
    end

    def flat_support_return_value?(value)
      !value.is_a?(Hash) && !value.is_a?(Array)
    end

    def support_return_params
      return {} unless returning_to_support?

      flow = support_flow_params
      { return_to: "support" }.tap do |result|
        result[:support_return] = flow if flow.present?
      end
    end

    def return_path
      returning_to_support? ? support_return_path(support_flow_params) : publish_return_path
    end
  end
end
