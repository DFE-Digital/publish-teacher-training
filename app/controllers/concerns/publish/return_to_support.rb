# frozen_string_literal: true

module Publish
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

    def support_return_params
      return {} unless returning_to_support?

      { return_to: "support", **support_flow_params }
    end

    # Override in the controller to carry extra params through the Publish flow.
    def support_flow_params
      {}
    end

    def return_path(list_params = nil)
      if returning_to_support?
        support_return_path(**(list_params.nil? ? support_list_params : list_params))
      else
        publish_return_path
      end
    end

    # Override in the controller when returning to a paginated/sorted Support list.
    def support_list_params
      {}
    end

    # Controllers including this concern must implement:
    # - support_return_path(**list_params)
    # - publish_return_path
  end
end
