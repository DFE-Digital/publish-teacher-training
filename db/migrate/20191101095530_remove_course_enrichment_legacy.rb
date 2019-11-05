class RemoveCourseEnrichmentLegacy < ActiveRecord::Migration[6.0]
  def change
    remove_column :course_enrichment, :ucas_course_code
    remove_column :course_enrichment, :provider_code
  end
end
