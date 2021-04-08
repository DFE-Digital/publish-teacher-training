# frozen_string_literal: true

module Support
  module DataExports
    class UsersExport < Base

      def id
        "users"
      end

      def name
        "All users"
      end

      def description
        "The list of all users with columns: provider_code, provider_name, provider_type, first_name, last_name, email_address"
      end

      def data
        result = []
        User.find_each do |u|
          if u.providers.empty?
            result << user_data(u, nil)
          else
            u.providers.each do |p|
              result << user_data(u, p)
            end
          end
        end

        result
      end

      def user_data(u, p)
        {
          provider_code: p&.provider_code,
          provider_name: p&.provider_name,
          provider_type: p&.provider_type,
          first_name: u.first_name,
          last_name: u.last_name,
          email_address: u.email,
        }
      end

    end
  end
end
