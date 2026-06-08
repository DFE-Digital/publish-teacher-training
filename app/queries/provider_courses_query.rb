# frozen_string_literal: true

# Builds the ordered, grouped list of courses shown on the publish course list
# page. Owns the database access: it loads a provider's courses eagerly, resolves
# their accredited (ratifying) providers in a single batched query, and arranges
# them into groups for display.
#
# Courses with no accredited provider (or whose accredited provider is the
# provider itself) form a single self-accredited group, ordered first and
# rendered without a heading. The remaining groups follow, ordered
# case-insensitively by accredited provider name.
class ProviderCoursesQuery
  Group = Data.define(:accredited_provider, :courses) do
    def self_accredited?
      accredited_provider.nil?
    end

    def heading
      accredited_provider&.provider_name
    end
  end

  def initialize(provider:)
    @provider = provider
  end

  def groups
    @groups ||= build_groups
  end

private

  attr_reader :provider

  def build_groups
    courses
      .group_by { |course| accredited_provider_for(course) }
      .sort_by { |accredited_provider, _courses| group_order(accredited_provider) }
      .map { |accredited_provider, grouped| Group.new(accredited_provider:, courses: grouped.map(&:decorate)) }
  end

  def group_order(accredited_provider)
    return [0, ""] if accredited_provider.nil? # self-accredited group first

    [1, accredited_provider.provider_name.downcase]
  end

  def courses
    @courses ||= provider.courses
                         .includes(%i[site_statuses enrichments provider])
                         .order(:name, :course_code)
                         .to_a
  end

  def accredited_provider_for(course)
    code = course.accredited_provider_code
    return nil if code.blank? || code == provider.provider_code

    accredited_providers_by_code[code]
  end

  def accredited_providers_by_code
    @accredited_providers_by_code ||=
      Provider.where(recruitment_cycle_id: provider.recruitment_cycle_id, provider_code: accredited_provider_codes)
              .index_by(&:provider_code)
  end

  def accredited_provider_codes
    courses.filter_map(&:accredited_provider_code).uniq
  end
end
