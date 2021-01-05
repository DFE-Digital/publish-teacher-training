class GIAS::ApplicationController < ActionController::Base
  include Pagy::Backend

  layout "application"
end
