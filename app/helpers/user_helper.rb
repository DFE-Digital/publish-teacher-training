# frozen_string_literal: true

module UserHelper
  def full_name(user)
    [user.first_name, user.last_name].join(" ")
  end

  def user_details(user)
    "#{user[:first_name]} #{user[:last_name]} <#{user[:email]}>"
  end

  def email_changed?(user_form)
    user_form.email.downcase != User.find(params[:user_id]).email
  end
end
