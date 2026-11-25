# frozen_string_literal: true

module Support
  module PublishReturnHelper
    # Query params for Support → Publish links that should return here afterwards.
    # List/flow state goes under support_return so it cannot collide with Publish params.
    def publish_return_to_support_params(**support_return)
      { return_to: "support", support_return: support_return.compact_blank }.compact_blank
    end
  end
end
