# frozen_string_literal: true

class StripSiteLocationName < ActiveRecord::Migration[8.0]
  def up
    Site.where("location_name ~ '\s$'").find_each do |site|
      site.skip_geocoding = true
      site.location_name = site.location_name.strip
      site.save!(validate: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
