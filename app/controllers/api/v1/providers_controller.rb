module Api
  module V1
    class ProvidersController < ApplicationController
      def index
        recruitment_cycle_year = params[:recruitment_cycle_year]
        if recruitment_cycle_year.present?
          if recruitment_cycle_year == "2019"
            @providers = Provider.all
          else
            return render plain: "providers for year '#{recruitment_cycle_year}' not found", status: :not_found
          end
        else
          @providers = Provider.all
        end
        paginate json: @providers
      end
    end
  end
end
