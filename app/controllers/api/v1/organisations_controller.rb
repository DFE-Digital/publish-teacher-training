module Api
  module V1
    class OrganisationsController < ApplicationController
      before_action :set_organisation, only: %i[show update destroy]

      # GET /organisations
      def index
        @organisations = Organisation.all

        paginate json: @organisations
      end

      # GET /organisations/1
      def show
        render json: @organisation
      end

      # POST /organisations
      def create
        @organisation = Organisation.new(organisation_params)

        if @organisation.save
          render json: @organisation, status: :created, location: @organisation
        else
          render json: @organisation.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /organisations/1
      def update
        if @organisation.update(organisation_params)
          render json: @organisation
        else
          render json: @organisation.errors, status: :unprocessable_entity
        end
      end

      # DELETE /organisations/1
      def destroy
        @organisation.destroy
      end

    private

        # Use callbacks to share common setup or constraints between actions.
      def set_organisation
        @organisation = Organisation.find(params[:id])
      end

        # Only allow a trusted parameter "white list" through.
      def organisation_params
        params.require(:organisation).permit(:name, :org_id)
      end
    end
  end
end
