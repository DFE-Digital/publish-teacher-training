# frozen_string_literal: true

module DataHub
  module DuplicateSchools
    # A shape of duplicate. Subclasses declare how to recognise themselves, what
    # to say about themselves, and which flags matter to the decision they need.
    # Splitting a shape in two later is a new subclass, not a new branch.
    class Kind
      # Matching order is precedence, declared rather than left to the order
      # Zeitwerk happens to load the subclasses in: a '-' row paired with an
      # identical clone is still a main site collision, and DivergentNameTwin is
      # the terminal fallback.
      ORDER = %w[MainSiteCollision Clone SplitCodeTwin DivergentNameTwin].freeze

      class << self
        def for(group)
          ORDER.lazy.map { |name| const_get(name).new(group) }.find(&:matches?)
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
    end
  end
end
