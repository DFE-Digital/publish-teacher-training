# frozen_string_literal: true

module Publish
  module Schools
    module BulkUpdate
      # A placement school change that has been chosen but not yet applied.
      #
      # The attach page no longer writes: it records what the provider ticked and
      # hands the draft on to the bulk update pages, which apply it once the
      # provider has said which courses it is for.
      #
      # The baseline travels with the selection rather than being read back from
      # the course. The pages play back a diff and the apply writes that same
      # diff, so both have to be measured against the schools that were attached
      # when the provider was looking at them - not against whatever the course
      # holds by the time they press the button.
      class Draft
        EXPIRES_IN = 24.hours

        attr_reader :course, :state_key

        class << self
          def create(course:, school_uuids:, baseline_uuids:)
            new(course:, state_key: SecureRandom.uuid).tap do |draft|
              draft.write(
                school_uuids: Array(school_uuids),
                baseline_uuids: Array(baseline_uuids),
              )
            end
          end

          def find(course:, state_key:)
            return if state_key.blank?

            draft = new(course:, state_key:)
            draft if draft.exists?
          end
        end

        def initialize(course:, state_key:)
          @course = course
          @state_key = state_key
        end

        def school_uuids
          Array(data[:school_uuids])
        end

        def baseline_uuids
          Array(data[:baseline_uuids])
        end

        def scope
          data[:scope]
        end

        def added_uuids
          school_uuids - baseline_uuids
        end

        def removed_uuids
          baseline_uuids - school_uuids
        end

        def changed?
          added_uuids.any? || removed_uuids.any?
        end

        def update(**attributes)
          write(**attributes)
        end

        def write(**attributes)
          repository.write(attributes)
          @data = nil

          self
        end

        delegate :exists?, to: :repository

        def delete
          repository.clear
          @data = nil
        end

      private

        def data
          @data ||= repository.read
        end

        def repository
          @repository ||= Repository.new(course:, state_key:, expires_in: EXPIRES_IN)
        end
      end
    end
  end
end
