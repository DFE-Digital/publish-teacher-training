class ConvertAdminUsers < ActiveRecord::Migration[6.0]
  def change
    User.where("email ~ ?", "@(digital\.){0,1}education\.gov\.uk$").update_all(admin: true)
  end
end
