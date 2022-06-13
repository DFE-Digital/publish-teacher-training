class PersonasController < ApplicationController
  layout "application"

  skip_before_action :authenticate

  def index; end
end
