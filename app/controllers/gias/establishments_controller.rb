module GIAS
  class EstablishmentsController < GIAS::ApplicationController
    def index
      @pagy, @establishments = pagy(GIASEstablishment.all)
    end
  end
end
