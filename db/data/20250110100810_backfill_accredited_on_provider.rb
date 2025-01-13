# frozen_string_literal: true

class BackfillAccreditedOnProvider < ActiveRecord::Migration[7.2]
  def up
    Provider.update_all("accredited = CASE WHEN accrediting_provider = 'Y' THEN TRUE ELSE FALSE END")
  end

  def down
    Provider.update_all(accredited: false)
  end
end
