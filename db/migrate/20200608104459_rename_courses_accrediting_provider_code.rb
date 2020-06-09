class RenameCoursesAccreditingProviderCode < ActiveRecord::Migration[6.0]
  def change
    rename_column :course, :accrediting_provider_code, :accredited_body_code
  end
end
