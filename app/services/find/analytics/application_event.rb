# frozen_string_literal: true

module Find
  module Analytics
    class ApplicationEvent
      include ActiveModel::Model

      attr_accessor :request

      def initialize(attributes = {})
        super

        @event = DfE::Analytics::Event.new
      end

      def send_event
        DfE::Analytics::SendEvents.do(
          [
            @event
              .with_type(event_name)
              .with_request_details(request)
              .with_user(current_user)
              .with_namespace(namespace)
              .with_data(event_data),
          ],
        )
      end

      def current_user
        Current.user
      end
    end
  end
end
