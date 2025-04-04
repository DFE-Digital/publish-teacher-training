# frozen_string_literal: true

module UserSessions
  class Update
    include ServicePattern

    attr_reader :user, :successful

    alias_method :successful?, :successful

    def initialize(user:, user_session:)
      @user = user

      attributes = {
        last_login_date_utc: Time.zone.now,
        email: user_session.email,
        sign_in_user_id: user_session.sign_in_user_id,
      }

      attributes[:first_name] = user_session.first_name if user_session.first_name.present?
      attributes[:last_name] = user_session.last_name if user_session.last_name.present?

      @user.assign_attributes(attributes)
    end

    def call
      @successful = user.valid? && user.save!

      self
    end
  end
end
