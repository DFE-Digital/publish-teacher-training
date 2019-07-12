class ChangeCourseAccreditingProviderIdToCode < ActiveRecord::Migration[5.2]
  class Course < ApplicationRecord
    belongs_to :accrediting_provider, class_name: 'Provider', optional: true
  end

  def change
    add_column :course, :accrediting_provider_code, :text
    add_index :course, :accrediting_provider_code

    reversible do |dir|
      say_with_time 'updating accrediting provider on courses' do
        Course.all.each do |course|
          dir.up {
            course.update accrediting_provider_code:
                            course.accrediting_provider&.provider_code
          }
          # manage_courses_backend_development=# select count(*) from course where accrediting_provider_id is null;
          #   count
          # -------
          #   3403

          # manage_courses_backend_development=# select count(*) from course where accrediting_provider_code is null;
          #   count
          # -------
          #   3403
          dir.down {
            course.update accrediting_provider_id:
                            course.accrediting_provider&.id
          }
        end
      end
    end

    revert do
      add_column :course, :accrediting_provider_id, :integer
      add_foreign_key :course,
                      :provider,
                      column: :accrediting_provider_id,
                      name: "FK_course_provider_accrediting_provider_id"
      add_index :course, %w[accrediting_provider_id],
                name: "IX_course_accrediting_provider_id"
    end
  end
end
