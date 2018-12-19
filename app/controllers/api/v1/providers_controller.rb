module Api
  module V1
    class ProvidersController < ApplicationController
      before_action :set_provider, only: %i[show update destroy]

      # GET /providers
      def index
        @providers = Provider.all

        paginate json: @providers
      end

      # GET /providers/1
      def show
        render json: @provider
      end

      # POST /providers
      def create
        @provider = Provider.new(provider_params)

        if @provider.save
          render json: @provider, status: :created, location: @provider
        else
          render json: @provider.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /providers/1
      def update
        if @provider.update(provider_params)
          render json: @provider
        else
          render json: @provider.errors, status: :unprocessable_entity
        end
      end

      # DELETE /providers/1
      def destroy
        @provider.destroy
      end

    private

        # Use callbacks to share common setup or constraints between actions.
      def set_provider
        @provider = Provider.find(params[:id])
      end

        # Only allow a trusted parameter "white list" through.
      def provider_params
        params.require(:provider).permit(:address4, :provider_name, :scheme_member, :contact_name, :year_code, :provider_code, :provider_type, :postcode, :scitt, :url, :address1, :address2, :address3, :email, :telephone)
      end
    end
  end
end
