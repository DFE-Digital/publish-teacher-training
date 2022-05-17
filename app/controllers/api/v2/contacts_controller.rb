module API
  module V2
    class ContactsController < API::V2::ApplicationController
      deserializable_resource :contact, class: API::V2::DeserializableContact

      def show
        authorize contact

        render jsonapi: contact, include: params[:include], status: :ok
      end

      def update
        authorize contact

        if contact.update(contact_params)
          render jsonapi: contact, status: :ok
        else
          render jsonapi_errors: contact.errors, status: :unprocessable_entity
        end
      end

    private

      def contact
        @contact ||= Contact.find(params[:id])
      end

      def contact_params
        params.require(:contact)
          .permit(
            :name,
            :email,
            :telephone,
            :permission_given,
          )
      end
    end
  end
end
