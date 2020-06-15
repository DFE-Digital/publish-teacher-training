class AdminUserReset < ActiveRecord::Migration[6.0]
  def up
    User.admins.each do |user|
      OrganisationUser.where(user_id: user.id).destroy_all
      UserNotification.where(user_id: user.id).destroy_all
    end
  end

  def down
    # There is no going back.
  end
end
