module GIAS
  class EstablishmentsController < GIAS::ApplicationController
    def index
      @pagy, @establishments = pagy(GIASEstablishment.all)
    end

    def show
      @establishment = GIASEstablishment.find_by(urn: params[:urn])

      @matches = GIAS::EstablishmentMatcherService.call(
        establishment: @establishment,
      )
    end
  end
end
