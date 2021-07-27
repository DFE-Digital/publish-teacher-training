if AuthenticationService.persona?
  class PersonasController < ActionController::Base
    layout "application"

    def index; end
  end
end
