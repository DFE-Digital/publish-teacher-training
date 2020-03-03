class RemoveSelfAccreditingProviderOnCourse < ActiveRecord::Migration[6.0]
  def up
    say_with_time "remove accrediting provider code" do
      ids = Course.find_by_sql("
      SELECT c.* FROM course AS c
      INNER JOIN provider AS p
        ON p.id = c.provider_id
        AND c.accrediting_provider_code = p.provider_code").map(&:id)

      Course.where(id: ids).update_all(accrediting_provider_code: nil)
    end
  end

  def down
    # There no going back
  end
end
