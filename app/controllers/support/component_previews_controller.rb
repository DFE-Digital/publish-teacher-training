# frozen_string_literal: true

module Support
  class ComponentPreviewsController < ViewComponentsController
    include Authentication
    helper_method :current_user
  end
end
