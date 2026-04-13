# frozen_string_literal: true

class BackfillMainSiteUrns < ActiveRecord::Migration[8.1]
  TAG = "[BackfillMainSiteUrns]"

  def up
    updated = []
    no_match = []
    ambiguous = []

    RecruitmentCycle.current.sites
      .kept
      .where(site_type: :school)
      .where("site.urn IS NULL OR TRIM(site.urn) = ''")
      .find_each do |site|
        normalized = site.postcode.to_s.gsub(/\s+/, "").upcase
        if normalized.blank?
          no_match << site
          next
        end

        postcode_matches = GiasSchool.available
          .where("REPLACE(UPPER(postcode), ' ', '') = ?", normalized)

        resolved_urn =
          case postcode_matches.size
          when 0
            nil
          when 1
            postcode_matches.first.urn
          else
            disambiguate(site, postcode_matches)
          end

        if resolved_urn
          site.update_column(:urn, resolved_urn)
          updated << [site, resolved_urn]
        elsif postcode_matches.empty?
          no_match << site
        else
          ambiguous << [site, postcode_matches.pluck(:urn)]
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

  private

  def disambiguate(site, postcode_matches)
    provider_ukprn = site.provider&.ukprn
    if provider_ukprn.present?
      by_ukprn = postcode_matches.where(ukprn: provider_ukprn).pluck(:urn)
      return by_ukprn.first if by_ukprn.size == 1
    end

    location_name = site.location_name.to_s.strip
    if location_name.present?
      by_name = postcode_matches.where("LOWER(name) = ?", location_name.downcase).pluck(:urn)
      return by_name.first if by_name.size == 1
    end

    nil
  end
end
