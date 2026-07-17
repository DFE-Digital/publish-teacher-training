# frozen_string_literal: true

module Rollover
  module Schools
    class DualCourseCopier
      def initialize(legacy_copier:, new_copier:)
        @legacy_copier = legacy_copier
        @new_copier = new_copier
      end

      def call(course:, new_provider:, new_course:)
        legacy_copier.call(course:, new_provider:, new_course:)
        new_copier.call(course:, new_provider:, new_course:)
      end

    private

      attr_reader :legacy_copier, :new_copier
    end
  end
end
