class RemoveAdminUsersFromOrganisations < ActiveRecord::Migration[6.0]
  def change
    admin_users = User.where("email ~ ?", "@(digital\.){0,1}education\.gov\.uk$")

    admin_users.each do |user|
      user.organisations = []
    end
  end
end
