# frozen_string_literal: true

class BackfillUserAuthenticationsFromSignInUserId < ActiveRecord::Migration[8.0]
  def up
    User.where.not(sign_in_user_id: nil).find_each do |user|
      Authentication.find_or_create_by!(
        authenticable: user,
        provider: :dfe_signin,
      ) do |auth|
        auth.subject_key = user.sign_in_user_id
      end
    end
  end

  def down
    Authentication.where(authenticable_type: "User", provider: :dfe_signin).delete_all
  end
end
