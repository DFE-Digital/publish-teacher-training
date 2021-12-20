namespace :validate_organisation_user_permission do
  task run_validation: :environment do
    User.all.each do |user|
      raise "User #{user.id} has discrepancies with provider relationships" unless user.providers.ids.sort.uniq == user.providers_via_user_permissions.ids.sort.uniq
    end
    puts "There were no discrepancies migrating Providers from OrganisationUser to UserPermission!"
  end
end
