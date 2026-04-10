# frozen_string_literal: true

class BackfillMainSiteUrns < ActiveRecord::Migration[8.1]
  TAG = "[BackfillMainSiteUrns]"

  def up
    updated = []
    no_match = []
    ambiguous = []

    RecruitmentCycle.current.sites
      .kept
      .where(site_type: :school, urn: nil)
      .find_each do |site|
        normalized = site.postcode.to_s.gsub(/\s+/, "").upcase
        if normalized.blank?
          no_match << site
          next
        end

        matches = GiasSchool.available
          .where("REPLACE(UPPER(postcode), ' ', '') = ?", normalized)
          .pluck(:urn)

        case matches.size
        when 0
          no_match << site
        when 1
          site.update_column(:urn, matches.first)
          updated << [site, matches.first]
        else
          ambiguous << [site, matches]
        end
      end

    say "#{TAG} updated=#{updated.size}, no_match=#{no_match.size}, ambiguous=#{ambiguous.size}"

    if no_match.any?
      say "#{TAG} UNRESOLVED (no_match):"
      no_match.each do |site|
        say "  provider_code=#{site.provider_code} site_id=#{site.id} location=#{site.location_name.inspect} postcode=#{site.postcode.inspect}"
      end
    end

    if ambiguous.any?
      say "#{TAG} UNRESOLVED (ambiguous):"
      ambiguous.each do |site, urns|
        say "  provider_code=#{site.provider_code} site_id=#{site.id} location=#{site.location_name.inspect} postcode=#{site.postcode.inspect} matches=#{urns.inspect}"
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
