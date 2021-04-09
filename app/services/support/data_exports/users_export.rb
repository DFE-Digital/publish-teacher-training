# frozen_string_literal: true

module Support
  module DataExports
    class UsersExport < Base
      def type
        "users"
      end

      def data
        result = []
        RecruitmentCycle.current.providers.find_each do |provider|
          provider.users.find_each do |user|
            result << user_data(user, provider)
          end
        end
        result
      end

      private

      def user_data(user, provider)
        {
          provider_code: provider.provider_code,
          provider_name: provider.provider_name,
          provider_type: provider.provider_type,
          first_name: user.first_name,
          last_name: user.last_name,
          email_address: user.email,
        }
      end
    end
  end
end
