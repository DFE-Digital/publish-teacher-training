# frozen_string_literal: true

module Support
  module Providers
    module History
      class Entry
        # One place to add a new history change type: audit key, which model it
        # belongs to, optional enum mapping, and whether creates are shown.
        CHANGE_TYPES = {
          provider_name: {
            key: "provider_name",
            auditable_type: "Provider",
          },
          provider_code: {
            key: "provider_code",
            auditable_type: "Provider",
          },
          course_name: {
            key: "name",
            auditable_type: "Course",
            course: true,
          },
          application_status: {
            key: "application_status",
            auditable_type: "Course",
            course: true,
            status: true,
            enum: -> { Course.application_statuses },
          },
          enrichment_status: {
            key: "status",
            auditable_type: "CourseEnrichment",
            course: true,
            status: true,
            enum: -> { CourseEnrichment.statuses },
            allow_create: true,
          },
        }.freeze

        # Colours match ApplicationDecorator status tags where the statuses overlap.
        STATUS_COLOURS = {
          "open" => "teal",
          "closed" => "purple",
          "draft" => "grey",
          "published" => "teal",
          "rolled_over" => "yellow",
          "withdrawn" => "red",
        }.freeze

        attr_reader :change_type, :old_value, :new_value, :created_at, :user, :course

        def self.entries_for(audit:, courses_by_id:)
          CHANGE_TYPES.filter_map do |change_type, definition|
            next unless audit.auditable_type == definition[:auditable_type]

            old_value, new_value = change_pair(audit, definition)
            next if old_value.nil? && new_value.nil?
            next if old_value == new_value
            # Enrichment creates (e.g. rollover) have no old value and are shown;
            # provider/course creates are excluded upstream in HistoryQuery.
            next if old_value.nil? && !definition[:allow_create]

            new(
              change_type:,
              old_value:,
              new_value:,
              created_at: audit.created_at,
              user: audit.user,
              course: course_for(audit, courses_by_id),
            )
          end
        end

        def self.change_pair(audit, definition)
          key = definition[:key]
          raw = audit.audited_changes[key] || audit.audited_changes[key.to_sym]
          return [nil, nil] if raw.nil?

          if raw.is_a?(Array)
            [normalize(definition, raw[0]), normalize(definition, raw[1])]
          else
            [nil, normalize(definition, raw)]
          end
        end
        private_class_method :change_pair

        def self.normalize(definition, value)
          return if value.nil?
          return value.to_s if definition[:enum].blank?

          normalize_enum(definition[:enum].call, value)
        end
        private_class_method :normalize

        def self.normalize_enum(enum_mapping, value)
          string_value = value.to_s
          return string_value if enum_mapping.key?(string_value)

          integer_value = integer_enum_value(value)
          return string_value if integer_value.nil?

          enum_mapping.key(integer_value)&.to_s || string_value
        end
        private_class_method :normalize_enum

        def self.integer_enum_value(value)
          return value if value.is_a?(Integer)
          return value.to_i if value.is_a?(String) && value.match?(/\A\d+\z/)

          nil
        end
        private_class_method :integer_enum_value

        def self.course_for(audit, courses_by_id)
          case audit.auditable_type
          when "Course"
            courses_by_id[audit.auditable_id]
          when "CourseEnrichment"
            courses_by_id[audit.associated_id]
          end
        end
        private_class_method :course_for

        def initialize(change_type:, old_value:, new_value:, created_at:, user:, course:)
          @change_type = change_type
          @old_value = old_value
          @new_value = new_value
          @created_at = created_at
          @user = user
          @course = course
        end

        def course_change?
          CHANGE_TYPES.fetch(change_type).fetch(:course, false)
        end

        def status_change?
          CHANGE_TYPES.fetch(change_type).fetch(:status, false)
        end

        def admin?
          user&.admin?
        end

        def user_name
          user&.full_name.presence || I18n.t("support.providers.history.index.system_user")
        end

        def formatted_time
          "#{created_at.to_fs(:govuk_date)} #{created_at.to_fs(:govuk_time)}"
        end

        def status_label(value)
          {
            text: I18n.t(
              "support.providers.history.status_labels.#{value}",
              default: value.to_s.humanize,
            ),
            colour: STATUS_COLOURS.fetch(value, "grey"),
          }
        end
      end
    end
  end
end
