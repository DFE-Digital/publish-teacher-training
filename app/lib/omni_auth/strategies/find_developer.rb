module OmniAuth
  module Strategies
    class FindDeveloper < OmniAuth::Strategies::Developer
      def request_phase
        if Rails.env.production? || Rails.env.test?
          super
        else
          mock_request_call
        end
      end

      uid { 23 }

      info do
        {
          sub: "dev-1",
          name: "developer",
          email: "candidateemail@example.com",
        }
      end

      credentials do
        {
          token: "abc123",              # the OAuth access token
          refresh_token: "xyz456",      # used to refresh the access token (optional)
          expires_at: 1_650_000_000, # Unix timestamp for expiration (optional)
          expires: true, # whether the token expires (boolean)
        }
      end
    end
  end
end
