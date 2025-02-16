# frozen_string_literal: true

module Find
  module Analytics
    class ApplicationEvent
      include ActiveModel::Model

      attr_accessor :request

      def initialize(attributes = {})
        @event = DfE::Analytics::Event.new

        super
      end

      def send_event
        DfE::Analytics::SendEvents.do(
          [
            @event
              .with_type(event_name)
              .with_request_details(request)
              .with_data(event_data)
          ]
        )
      end
    end
  end
end
