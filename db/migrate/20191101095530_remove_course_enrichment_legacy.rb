# rubocop:disable Rails/ReversibleMigration
class RemoveCourseEnrichmentLegacy < ActiveRecord::Migration[6.0]
  def change
    change_table :course_enrichment, bulk: true do |t|
      t.remove :ucas_course_code
      t.remove :provider_code
    end
  end
end
# rubocop:enable Rails/ReversibleMigration
