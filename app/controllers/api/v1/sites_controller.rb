module Api
  module V1
    class SitesController < ApplicationController
      before_action :set_site, only: %i[show update destroy]

      # GET /sites
      def index
        @sites = Site.all

        paginate json: @sites
      end

      # GET /sites/1
      def show
        render json: @site
      end

      # POST /sites
      def create
        @site = Site.new(site_params)

        if @site.save
          render json: @site, status: :created, location: @site
        else
          render json: @site.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /sites/1
      def update
        if @site.update(site_params)
          render json: @site
        else
          render json: @site.errors, status: :unprocessable_entity
        end
      end

      # DELETE /sites/1
      def destroy
        @site.destroy
      end

    private

        # Use callbacks to share common setup or constraints between actions.
      def set_site
        @site = Site.find(params[:id])
      end

        # Only allow a trusted parameter "white list" through.
      def site_params
        params.require(:site).permit(:address2, :address3, :address4, :code, :location_name, :postcode, :address1, :provider_id)
      end
    end
  end
end
