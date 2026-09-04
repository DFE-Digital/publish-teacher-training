# frozen_string_literal: true

module Publish
  module Schools
    # The schools a provider is adding to a course and taking off it, played
    # back on the bulk update pages.
    #
    # The same summary ChangesSummaryComponent shows on the attach page, and the
    # same wording, but rendered here rather than filled in by the browser: by
    # this point the ticking is over, and these pages ask the provider to commit
    # to what it says.
    #
    # A long list is worth collapsing, and both halves collapse together - one
    # open beside one closed reads as though the closed half mattered less.
    class ChangesListComponent < ViewComponent::Base
      DETAILS_AFTER = 9

      Half = Data.define(:kind, :names, :all) do
        def show?
          names.any?
        end
      end

      def initialize(changes:)
        @changes = changes

        super()
      end

      def halves
        [
          Half.new(kind: "adding", names: changes.added_names, all: changes.adding_all?),
          Half.new(kind: "removing", names: changes.removed_names, all: changes.removing_all?),
        ].select(&:show?)
      end

      def collapse?
        halves.map { |half| half.names.size }.max.to_i >= DETAILS_AFTER
      end

      def heading(half)
        t(
          "publish.schools.changes.#{half.kind}_#{half.names.one? ? 'one' : 'other'}",
          count: half.names.size,
        )
      end

      def summary(half)
        t(
          "publish.schools.changes.#{half.kind}_summary_#{half.names.one? ? 'one' : 'other'}",
          count: half.names.size,
        )
      end

      def message(half)
        t("publish.schools.changes.#{half.kind}_all")
      end

      delegate :changed?, to: :changes

    private

      attr_reader :changes
    end
  end
end
