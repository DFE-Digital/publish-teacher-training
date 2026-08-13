# frozen_string_literal: true

require "csv"

# Read-only classification of providers holding the same school twice.
#
#   DuplicateSchoolsReport.call
#
# A provider can hold one GIAS school under several rows, which the schools list
# and the course school pickers then show side by side. The shapes have
# different causes and different safe answers, so this reports them separately
# rather than merging anything: see DuplicateSchoolsReport::Kind's subclasses.
#
# Deliberately excluded from the grouping key: `code`. The query this replaces
# filtered `code <> '-'`, which hid the largest shape - a provider's main site
# colliding with the same school added again as a placement school.
class DuplicateSchoolsReport
  YEARS = %w[2026].freeze

  def self.call(years: YEARS, io: $stdout)
    new(years:, io:).call
  end

  def initialize(years: YEARS, io: $stdout)
    @years = Array(years).map(&:to_s)
    @io = io
  end

  def call
    Reporter.new(groups:, years:, io:).call
    groups
  end

  def groups
    @groups ||= build_groups
  end

private

  attr_reader :years, :io

  def build_groups
    keys = duplicate_keys
    return [] if keys.empty?

    sites = sites_for(keys).group_by { |site| [site.provider_id, site.urn] }
    gias_schools = GiasSchool.where(urn: keys.map(&:last).uniq).index_by(&:urn)
    provider_schools = provider_schools_for(keys.map(&:first).uniq, gias_schools.values)

    keys.filter_map do |key|
      group_sites = sites[key]
      next if group_sites.blank?

      provider = group_sites.first.provider
      gias_school = gias_schools[key.last]

      Group.new(
        year: provider.recruitment_cycle.year,
        provider:,
        urn: key.last,
        sites: group_sites.sort_by(&:id),
        gias_school:,
        provider_schools: provider_schools[[provider.id, gias_school&.id]].to_a,
      )
    end
  end

  # The (provider, urn) pairs held by more than one live school site.
  def duplicate_keys
    Site.kept
        .school
        .where.not(urn: [nil, ""])
        .joins(provider: :recruitment_cycle)
        .where(provider: { discarded_at: nil }, recruitment_cycle: { year: years })
        .group(:provider_id, :urn)
        .having("COUNT(*) > 1")
        .pluck(:provider_id, :urn)
  end

  def sites_for(keys)
    Site.kept
        .school
        .where(provider_id: keys.map(&:first).uniq, urn: keys.map(&:last).uniq)
        .includes(:site_statuses, provider: :recruitment_cycle)
        .select { |site| keys.include?([site.provider_id, site.urn]) }
  end

  def provider_schools_for(provider_ids, gias_schools)
    Provider::School
      .where(provider_id: provider_ids, gias_school_id: gias_schools.map(&:id))
      .includes(:course_schools)
      .group_by { |provider_school| [provider_school.provider_id, provider_school.gias_school_id] }
  end

  # One provider's live school sites sharing a urn, with the GIAS record they
  # all point at and the Provider::School rows they became.
  Group = Struct.new(:year, :provider, :urn, :sites, :gias_school, :provider_schools, keyword_init: true) do
    def self.normalise(value)
      value.to_s.strip.downcase.squeeze(" ")
    end

    def kind
      @kind ||= Kind.for(self)
    end

    def codes
      sites.map(&:code).uniq
    end

    def names
      sites.map { |site| Group.normalise(site.location_name) }.uniq
    end

    def gias_name
      Group.normalise(gias_school&.name)
    end

    def main_site
      sites.find { |site| site.code == Provider::School::MAIN_SITE_CODE }
    end

    # What DataHub::Sites::Deduplication::Deduplicator#pick_primary_site would
    # keep, so the report can say whose row that heuristic would discard.
    def legacy_primary
      sites.max_by { |site| [course_ids(site).size, -site.id] }
    end

    def course_ids(site)
      site.site_statuses.map(&:course_id).uniq
    end

    def unique_course_ids(site)
      course_ids(site) - sites.reject { |other| other == site }.flat_map { |other| course_ids(other) }
    end

    def sites_with_courses
      sites.count { |site| course_ids(site).any? }
    end

    def surplus
      sites.size - 1
    end

    def provider_school_surplus
      [provider_schools.size - 1, 0].max
    end
  end

  # A shape of duplicate. Subclasses declare how to recognise themselves, what
  # to say about themselves, and which flags matter to the decision they need;
  # registry order is the matching order, so the more specific shapes come
  # first. Splitting one shape in two later is a new subclass, not a new branch.
  class Kind
    class << self
      def registry
        @registry ||= []
      end

      def inherited(subclass)
        super
        Kind.registry << subclass
      end

      def for(group)
        registry.lazy.map { |kind| kind.new(group) }.find(&:matches?)
      end

      def matches(&block)
        define_method(:matches?, &block)
      end

      def headline(text)
        define_method(:headline) { text }
      end

      def action(text)
        define_method(:suggested_action) { text }
      end

      def flag(name, &block)
        declared_flags << name
        define_method(:"#{name}?", &block)
      end

      def declared_flags
        @declared_flags ||= []
      end

      def flags
        inherited_flags = superclass.respond_to?(:flags) ? superclass.flags : []
        inherited_flags + declared_flags
      end
    end

    attr_reader :group

    delegate :codes, :names, :sites, :main_site, :gias_school, :gias_name,
             :legacy_primary, :sites_with_courses, :provider, :urn, to: :group

    def initialize(group)
      @group = group
    end

    def label
      self.class.name.demodulize.underscore
    end

    def flags
      self.class.flags.index_with { |name| public_send(:"#{name}?") }
    end

    def raised_flags
      flags.select { |_name, raised| raised }.keys
    end

    flag(:gias_closed) { gias_school.nil? || gias_school.closed? }

    # The provider's main site and the same school added again as a placement
    # school - the shape the original query's `code <> '-'` filter hid. Which
    # row should survive is a policy decision, so nothing here assumes one.
    class MainSiteCollision < Kind
      matches { codes.include?(Provider::School::MAIN_SITE_CODE) }
      headline "the provider's main site and the same school added again as a placement school"
      action "decide the policy: keep '-' and move courses onto it, or keep the named row"

      flag(:main_site_at_risk) { legacy_primary.code != Provider::School::MAIN_SITE_CODE }
      flag(:courses_on_both_sides) { sites_with_courses > 1 }
    end

    # The same school added repeatedly under one code. Provider::School's unique
    # (provider_id, gias_school_id, site_code) index already collapsed these, so
    # they are legacy litter rather than anything a provider can see.
    class Clone < Kind
      matches { codes.one? && names.one? }
      headline "the same school added repeatedly under one code"
      action "safe to merge unattended - no user-visible duplicate to remove"
    end

    # One school under two codes: two Provider::School rows, so the provider
    # sees the same name twice with its courses split between them.
    class SplitCodeTwin < Kind
      matches { names.one? }
      headline "one school held under two codes - listed twice, courses split"
      action "merge onto the code holding more courses, moving the rest across"

      flag(:courses_on_both_sides) { sites_with_courses > 1 }
    end

    # Same urn, two names a provider wrote. Often deliberate labelling rather
    # than an accident, so it needs asking rather than merging.
    class DivergentNameTwin < Kind
      matches { true }
      headline "one urn under two provider-written names"
      action "ask the provider which name they meant before merging"

      # A name that is neither the GIAS name nor the generic main site label is
      # one the provider typed for themselves, so it carries meaning worth
      # asking about - "Main site Secondary- one of our partner schools" counts,
      # a plain "Main Site" does not.
      flag(:provider_authored_name) do
        names.any? { |name| name != gias_name && name != Site::MAIN_SITE }
      end
      flag(:courses_on_both_sides) { sites_with_courses > 1 }
    end
  end

  # Prints the counts a merge policy gets chosen from, then the evidence for
  # every group, then the same thing as CSV to paste into a sheet.
  class Reporter
    CSV_HEADERS = %w[
      year
      provider_code
      provider_name
      urn
      kind
      flags
      site_id
      code
      location_name
      created_at
      added_via
      courses
      unique_courses
      uuid
      gias_name
      gias_status
      provider_school_id
      provider_school_code
      course_schools
    ].freeze

    def initialize(groups:, years:, io:)
      @groups = groups
      @years = years
      @io = io
    end

    def call
      print_counts
      print_groups
      print_csv
    end

  private

    attr_reader :groups, :years, :io

    def by_kind
      @by_kind ||= groups.group_by { |group| group.kind.label }.sort_by { |_label, found| -found.size }
    end

    def print_counts
      io.puts "Duplicate provider schools - #{years.join(', ')}"
      io.puts "=" * 96
      io.puts "#{groups.size} groups, #{groups.sum(&:surplus)} surplus site rows, " \
              "#{groups.sum(&:provider_school_surplus)} surplus provider_school rows"
      io.puts

      by_kind.each do |label, found|
        io.puts sprintf(
          "%-22s groups %-5d surplus sites %-5d surplus provider_school %-5d  %s",
          label,
          found.size,
          found.sum(&:surplus),
          found.sum(&:provider_school_surplus),
          flag_tally(found),
        )
      end
      io.puts
    end

    def flag_tally(found)
      found
        .flat_map { |group| group.kind.raised_flags }
        .tally
        .map { |name, count| "#{name}=#{count}" }
        .join(" ")
    end

    def print_groups
      by_kind.each do |label, found|
        found.sort_by { |group| [-group.sites.size, group.provider.provider_code] }.each do |group|
          print_group(label, group)
        end
      end
    end

    def print_group(label, group)
      kind = group.kind
      io.puts "-" * 96
      io.puts "[#{label}] #{group.provider.provider_code} #{group.provider.provider_name} - urn #{group.urn}"
      io.puts "  gias: #{group.gias_school&.name.inspect} (#{group.gias_school&.status_code || 'no gias record'})"
      io.puts "  #{kind.headline}"
      io.puts "  -> #{kind.suggested_action}"
      io.puts "  flags: #{kind.raised_flags.join(', ').presence || 'none'}"

      group.sites.each { |site| print_site(group, site) }
      print_provider_schools(group)
    end

    def print_site(group, site)
      io.puts sprintf(
        "  site %-10s code %-4s %-46s created %s  %-18s courses %-4d unique %-4d %s",
        site.id,
        site.code,
        site.location_name.to_s.truncate(44).inspect,
        site.created_at.to_date,
        site.added_via,
        group.course_ids(site).size,
        group.unique_course_ids(site).size,
        site.uuid,
      )
    end

    def print_provider_schools(group)
      described = group.provider_schools.map do |provider_school|
        "#{provider_school.id} code #{provider_school.site_code.inspect} " \
          "course_schools #{provider_school.course_schools.size}"
      end

      io.puts "  provider_school: #{described.join(' | ').presence || 'none'}"
    end

    def print_csv
      io.puts
      io.puts "-" * 96
      io.puts "CSV"
      io.puts CSV.generate_line(CSV_HEADERS)
      groups.each { |group| group.sites.each { |site| io.print csv_row(group, site) } }
    end

    def csv_row(group, site)
      provider_school = group.provider_schools.find { |candidate| candidate.site_code == site.code }

      CSV.generate_line([
        group.year,
        group.provider.provider_code,
        group.provider.provider_name,
        group.urn,
        group.kind.label,
        group.kind.raised_flags.join(" "),
        site.id,
        site.code,
        site.location_name,
        site.created_at.to_date,
        site.added_via,
        group.course_ids(site).size,
        group.unique_course_ids(site).size,
        site.uuid,
        group.gias_school&.name,
        group.gias_school&.status_code,
        provider_school&.id,
        provider_school&.site_code,
        provider_school&.course_schools&.size,
      ])
    end
  end
end
