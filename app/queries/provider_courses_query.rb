# frozen_string_literal: true

# Builds the ordered, grouped list of courses shown on the publish course list
# page. Owns the database access: a single query joins each course to its
# accredited (ratifying) provider and lets the database do the ordering —
# self-accredited courses first, then case-insensitively by accredited provider
# name, then by course name and code. The pre-ordered rows are chunked into
# groups in Ruby.
#
# A course is self-accredited when it has no accredited provider, or its
# accredited provider is the training provider itself; such courses form a
# single group rendered without a heading.
class ProviderCoursesQuery
  Group = Data.define(:accredited_provider_name, :courses) do
    def self_accredited?
      accredited_provider_name.nil?
    end

    def heading
      accredited_provider_name
    end
  end

  ACCREDITED_PROVIDER_JOIN = <<~SQL.squish
    LEFT OUTER JOIN provider AS accredited_provider
      ON accredited_provider.provider_code = course.accredited_provider_code
      AND accredited_provider.recruitment_cycle_id = :cycle_id
  SQL

  # A course is self-accredited when it has no accredited provider, or the
  # accredited provider is the training provider itself.
  SELF_ACCREDITED = "course.accredited_provider_code IS NULL OR course.accredited_provider_code = :own_code"

  # NULL group name == self-accredited group (rendered without a heading).
  GROUP_NAME = "CASE WHEN (#{SELF_ACCREDITED}) THEN NULL ELSE accredited_provider.provider_name END".freeze

  GROUP_NAME_SELECT = "#{GROUP_NAME} AS group_name".freeze

  # Self-accredited first, then case-insensitive by accredited provider name.
  ORDER_CLAUSE = <<~SQL.squish.freeze
    CASE WHEN (#{SELF_ACCREDITED}) THEN 0 ELSE 1 END,
    LOWER(#{GROUP_NAME}),
    course.name,
    course.course_code
  SQL

  def initialize(provider:)
    @provider = provider
  end

  def groups
    @groups ||= courses
      .chunk_while { |a, b| a[:group_name] == b[:group_name] }
      .map { |chunk| Group.new(accredited_provider_name: chunk.first[:group_name], courses: chunk.map(&:decorate)) }
  end

private

  attr_reader :provider

  def courses
    @courses ||= provider.courses
                         .includes(%i[site_statuses enrichments provider])
                         .joins(sanitize(ACCREDITED_PROVIDER_JOIN, cycle_id: provider.recruitment_cycle_id))
                         .select("course.*", sanitize(GROUP_NAME_SELECT, own_code: provider.provider_code))
                         .order(Arel.sql(sanitize(ORDER_CLAUSE, own_code: provider.provider_code)))
                         .to_a
  end

  def sanitize(sql, **)
    Course.sanitize_sql_array([sql, **])
  end
end
