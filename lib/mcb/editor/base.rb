module MCB
  module Editor
    class Base
      attr_reader :provider

      def initialize(provider:, requester:)
        @provider = provider
        @requester = requester

        setup_cli
        check_authorisation
      end

    protected

      def setup_cli
        raise NotImplementedError, "Needs to be implemented in Child Class"
      end

      def check_authorisation
        raise NotImplementedError, "Needs to be implemented in Child Class"
      end

      def audit
        Audited.audit_class.as_user(@requester) do
          yield
        end
      end
    end
  end
end
