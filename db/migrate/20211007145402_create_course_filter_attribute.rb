class CreateCourseFilterAttribute < ActiveRecord::Migration[6.1]
  def change
    create_view :course_filter_attribute, materialized: true

    add_index :course_filter_attribute, :id
    add_index :course_filter_attribute, :program_type
    add_index :course_filter_attribute, :qualification
    add_index :course_filter_attribute, :study_mode
    add_index :course_filter_attribute, :is_send
    add_index :course_filter_attribute, :degree_grade
    add_index :course_filter_attribute, :provider_name
    add_index :course_filter_attribute, :can_sponsor_student_visa
    add_index :course_filter_attribute, :can_sponsor_skilled_worker_visa, name: "course_filter_attributes_worker_visa_index"
    add_index :course_filter_attribute, :subject_code
    add_index :course_filter_attribute, :vac_status
    add_index :course_filter_attribute, :publish
    add_index :course_filter_attribute, :status
    add_index :course_filter_attribute, :latitude
    add_index :course_filter_attribute, :longitude
    add_index :course_filter_attribute, :recruitment_cycle_id
  end
end
