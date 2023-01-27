# frozen_string_literal: true

class ComponentPreviewsController < ViewComponentsController
  include Authentication
  helper_method :current_user
end
