# frozen_string_literal: true

module DfESignInUsers
  class Update
    include ServicePattern

    attr_reader :user, :successful

    alias_method :successful?, :successful

    def initialize(user:, dfe_sign_in_user:)
      @user = user

      attributes = {
        last_login_date_utc: Time.zone.now,
        email: dfe_sign_in_user.email,
        sign_in_user_id: dfe_sign_in_user.sign_in_user_id,
      }

      attributes[:first_name] = dfe_sign_in_user.first_name if dfe_sign_in_user.first_name.present?
      attributes[:last_name] = dfe_sign_in_user.last_name if dfe_sign_in_user.last_name.present?

      @user.assign_attributes(attributes)
    end

    def call
      @successful = user.valid? && user.save!

      self
    end
  end
end
