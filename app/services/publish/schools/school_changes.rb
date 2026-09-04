# frozen_string_literal: true

module Publish
  module Schools
    # What a provider has changed about a course's schools, worked out from the
    # selection alone.
    #
    # The Ruby counterpart of schoolChanges() in
    # app/javascript/publish/schools_changes.js. The attach page works this out
    # in the browser as the provider ticks; the bulk update pages have no ticks
    # to watch and no JavaScript to depend on, so they work it out here. The two
    # have to agree, so this mirrors it case for case - including the
    # asymmetric "all": every school ticked, or none left ticked. It is the end
    # state that decides, not which control got there.
    #
    # Only schools still in the provider's list are named. One taken off it
    # while the provider was deciding is not going to be written either.
    class SchoolChanges
      def initialize(schools:, submitted:, baseline:)
        @schools = schools
        @submitted = Set.new(submitted)
        @baseline = Set.new(baseline)
      end

      def added_names
        @added_names ||= names(schools.reject { |school| baseline.include?(school.uuid) })
      end

      def removed_names
        @removed_names ||= names(schools.select { |school| baseline.include?(school.uuid) }, ticked: false)
      end

      def adding_all?
        schools.any? && schools.all? { |school| submitted.include?(school.uuid) }
      end

      def removing_all?
        schools.any? && schools.none? { |school| submitted.include?(school.uuid) }
      end

      def changed?
        added_names.any? || removed_names.any?
      end

    private

      attr_reader :schools, :submitted, :baseline

      def names(candidates, ticked: true)
        candidates
          .select { |school| submitted.include?(school.uuid) == ticked }
          .map(&:location_name)
      end
    end
  end
end
