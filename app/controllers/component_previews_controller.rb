class ComponentPreviewsController < ViewComponentsController
  include Authentication
  helper_method :current_user
end
