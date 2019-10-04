class AddMissingFks < ActiveRecord::Migration[6.0]
  def up
    # there is bad data in prod (3 rows), kill it:
    violations = ProviderUCASPreference.find_by_sql("select * from provider_ucas_preference where provider_id not in (select id from provider)")
    puts "Deleting #{violations.count} orphaned provider_ucas_preference records..."
    violations.each(&:destroy)
    add_foreign_key :provider_ucas_preference, :provider, name: "fk_provider_ucas_preference__provider"

    add_foreign_key :course_subject, :subject, name: "fk_course_subject__subject"
    add_foreign_key :course_subject, :course, name: "fk_course_subject__course"

    add_foreign_key :contact, :provider, name: "fk_contact_provider"
  end

  def down
    remove_foreign_key :contact, :provider, name: "fk_contact_provider"

    remove_foreign_key :course_subject, :course, name: "fk_course_subject__course"
    remove_foreign_key :course_subject, :subject, name: "fk_course_subject__subject"

    remove_foreign_key :provider_ucas_preference, :provider, name: "fk_provider_ucas_preference__provider"
  end
end
