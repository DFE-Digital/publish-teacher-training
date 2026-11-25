# frozen_string_literal: true

module Publish
  # Lets Support send an admin into a Publish flow and bring them back afterwards.
  #
  # Controllers including this concern must implement:
  # - support_return_path
  # - publish_return_path
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

    # Override to carry extra params through the Publish flow.
    def support_flow_params
      {}
    end

    def support_return_params
      return {} unless returning_to_support?

      { return_to: "support", **support_flow_params }
    end

    def return_path
      returning_to_support? ? support_return_path : publish_return_path
    end
  end
end
