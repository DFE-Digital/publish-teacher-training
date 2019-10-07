class AddMissingFks < ActiveRecord::Migration[6.0]
  def up
    # there is bad data in prod (3 rows), kill it:
    pref_violations = ProviderUCASPreference.find_by_sql("select * from provider_ucas_preference where provider_id not in (select id from provider)")
    puts "Deleting #{pref_violations.count} orphaned provider_ucas_preference records..."
    pref_violations.each(&:destroy)
    add_foreign_key :provider_ucas_preference, :provider, name: "fk_provider_ucas_preference__provider"

    csb_violations = CourseSubject.find_by_sql("select * from course_subject where subject_id not in (select id from subject)")
    puts "Deleting #{csb_violations.count} orphaned course_subject.subject_id records..."
    csb_violations.each(&:destroy)
    add_foreign_key :course_subject, :subject, name: "fk_course_subject__subject"

    csc_violations = CourseSubject.find_by_sql("select * from course_subject where course_id not in (select id from course)")
    puts "Deleting #{csc_violations.count} orphaned course_subject.course_id records..."
    csc_violations.each(&:destroy)
    add_foreign_key :course_subject, :course, name: "fk_course_subject__course"

    contact_violations = Contact.find_by_sql("select * from contact where provider_id not in (select id from provider)")
    puts "Deleting #{contact_violations.count} orphaned contact records..."
    contact_violations.each(&:destroy)
    add_foreign_key :contact, :provider, name: "fk_contact_provider"
  end

  def down
    remove_foreign_key :contact, :provider, name: "fk_contact_provider"

    remove_foreign_key :course_subject, :course, name: "fk_course_subject__course"
    remove_foreign_key :course_subject, :subject, name: "fk_course_subject__subject"

    remove_foreign_key :provider_ucas_preference, :provider, name: "fk_provider_ucas_preference__provider"
  end
end
