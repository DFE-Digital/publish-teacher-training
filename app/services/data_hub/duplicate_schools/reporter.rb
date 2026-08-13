# frozen_string_literal: true

require "csv"

module DataHub
  module DuplicateSchools
    # Prints the counts a merge policy gets chosen from, then the evidence for
    # every group, then the same thing as CSV to paste into a sheet. The
    # persisted process summary holds all of this too; this is for reading the
    # run as it happens.
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

        CSV.generate_line(
          [
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
          ],
        )
      end
    end
  end
end
