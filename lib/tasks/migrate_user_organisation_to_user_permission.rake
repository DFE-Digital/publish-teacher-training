namespace :organisation_user_migrate do
  task migrate_organisation_user_to_user_permission: :environment do
    total_bm = Benchmark.measure do
      UserPermission.insert_all(
        OrganisationUser.includes(:user, organisation: [providers: [:recruitment_cycle]]).all.flat_map do |organisation_user|
          organisation_user.organisation.providers.ids.map do |id|
            {
              user_id: organisation_user.user.id,
              provider_id: id,
              updated_at: Time.current,
              created_at: Time.current,
            }
          end
        end, unique_by: :index_user_permission_on_user_id_and_provider_id
      )
    end
    puts total_bm.real
  end
end
