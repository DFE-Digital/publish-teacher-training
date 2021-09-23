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
          user_id: user.id,
          provider_code: provider.provider_code,
          provider_name: provider.provider_name,
          provider_type: provider.provider_type,
          first_name: user.first_name,
          last_name: user.last_name,
          email_address: user.email,
          first_login_at: user.first_login_date_utc,
          last_login_at: user.last_login_date_utc,
        }
      end
    end
  end
end
