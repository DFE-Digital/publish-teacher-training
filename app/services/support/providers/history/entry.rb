# frozen_string_literal: true

module Support
  module Providers
    module History
      class Entry
        ATTRIBUTE_KEYS = {
          provider_name: "provider_name",
          provider_code: "provider_code",
          course_name: "name",
          application_status: "application_status",
          enrichment_status: "status",
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
          new_entries = []

          ATTRIBUTE_KEYS.each do |change_type, key|
            next unless relevant_for?(audit, change_type)

            old_value, new_value = change_pair(audit, key)
            next if old_value.nil? && new_value.nil?
            next if old_value == new_value
            # Enrichment creates (e.g. rollover) have no old value and are shown;
            # provider/course creates are excluded upstream in HistoryQuery.
            next if old_value.nil? && change_type != :enrichment_status

            new_entries << new(
              change_type:,
              old_value:,
              new_value:,
              created_at: audit.created_at,
              user: audit.user,
              course: course_for(audit, courses_by_id),
            )
          end

          new_entries
        end

        def self.relevant_for?(audit, change_type)
          case change_type
          when :provider_name, :provider_code
            audit.auditable_type == Provider.name
          when :course_name, :application_status
            audit.auditable_type == Course.name
          when :enrichment_status
            audit.auditable_type == CourseEnrichment.name
          else
            false
          end
        end
        private_class_method :relevant_for?

        def self.change_pair(audit, key)
          raw = audit.audited_changes[key] || audit.audited_changes[key.to_sym]
          return [nil, nil] if raw.nil?

          if raw.is_a?(Array)
            [normalize(key, raw[0]), normalize(key, raw[1])]
          else
            [nil, normalize(key, raw)]
          end
        end
        private_class_method :change_pair

        def self.normalize(key, value)
          return if value.nil?

          case key
          when "application_status"
            normalize_enum(Course.application_statuses, value)
          when "status"
            normalize_enum(CourseEnrichment.statuses, value)
          else
            value.to_s
          end
        end
        private_class_method :normalize

        def self.normalize_enum(enum_mapping, value)
          string_value = value.to_s
          return string_value if enum_mapping.key?(string_value)

          enum_mapping.key(value.is_a?(Integer) ? value : string_value.to_i)&.to_s || string_value
        end
        private_class_method :normalize_enum

        def self.course_for(audit, courses_by_id)
          case audit.auditable_type
          when Course.name
            courses_by_id[audit.auditable_id]
          when CourseEnrichment.name
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
          change_type.in?(%i[course_name application_status enrichment_status])
        end

        def status_change?
          change_type.in?(%i[application_status enrichment_status])
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
