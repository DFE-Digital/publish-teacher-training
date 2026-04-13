# frozen_string_literal: true

class BackfillMainSiteUrns < ActiveRecord::Migration[8.1]
  TAG = "[BackfillMainSiteUrns]"

  def up
    updated = []
    no_match = []
    ambiguous = []

    sites_missing_urn.find_each do |site|
      matches = matching_schools_for(site)

      case resolve_urn(site, matches)
      in [:updated, urn]
        site.update_column(:urn, urn)
        updated << [site, urn]
      in :no_match
        no_match << site
      in [:ambiguous, urns]
        ambiguous << [site, urns]
      end
    end

    report(updated:, no_match:, ambiguous:)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

private

  def sites_missing_urn
    RecruitmentCycle.current.sites
      .kept
      .where(site_type: :school)
      .where("site.urn IS NULL OR TRIM(site.urn) = ''")
  end

  def matching_schools_for(site)
    postcode = normalize_postcode(site.postcode)
    return GiasSchool.none if postcode.blank?

    GiasSchool.available.where("REPLACE(UPPER(postcode), ' ', '') = ?", postcode)
  end

  def resolve_urn(site, matches)
    case matches.size
    when 0
      :no_match
    when 1
      [:updated, matches.first.urn]
    else
      urn = disambiguate(site, matches)
      urn ? [:updated, urn] : [:ambiguous, matches.pluck(:urn)]
    end
  end

  def disambiguate(site, matches)
    urn_by_ukprn(site, matches) || urn_by_location_name(site, matches)
  end

  def urn_by_ukprn(site, matches)
    ukprn = site.provider&.ukprn
    return if ukprn.blank?

    urns = matches.where(ukprn:).pluck(:urn)
    urns.first if urns.size == 1
  end

  def urn_by_location_name(site, matches)
    name = site.location_name.to_s.strip
    return if name.blank?

    urns = matches.where("LOWER(name) = ?", name.downcase).pluck(:urn)
    urns.first if urns.size == 1
  end

  def normalize_postcode(postcode)
    postcode.to_s.gsub(/\s+/, "").upcase
  end

  def report(updated:, no_match:, ambiguous:)
    say "#{TAG} updated=#{updated.size}, no_match=#{no_match.size}, ambiguous=#{ambiguous.size}"

    log_unresolved("no_match", no_match) { |site| describe_site(site) }
    log_unresolved("ambiguous", ambiguous) do |(site, urns)|
      "#{describe_site(site)} matches=#{urns.inspect}"
    end
  end

  def log_unresolved(label, entries)
    return if entries.empty?

    say "#{TAG} UNRESOLVED (#{label}):"
    entries.each { |entry| say "  #{yield(entry)}" }
  end

  def describe_site(site)
    "provider_code=#{site.provider_code} site_id=#{site.id} " \
      "location=#{site.location_name.inspect} postcode=#{site.postcode.inspect}"
  end
end
