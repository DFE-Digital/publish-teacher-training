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

        APPLICATION_STATUS_LABELS = {
          "open" => { text: "Open", colour: "teal" },
          "closed" => { text: "Closed", colour: "purple" },
        }.freeze

        ENRICHMENT_STATUS_LABELS = {
          "draft" => { text: "Draft", colour: "grey" },
          "published" => { text: "Published", colour: "teal" },
          "rolled_over" => { text: "Rolled over", colour: "yellow" },
          "withdrawn" => { text: "Withdrawn", colour: "red" },
        }.freeze

        attr_reader :change_type, :old_value, :new_value, :created_at, :user, :course

        def self.entries_for(audit:, courses_by_id:, enrichments_by_id:)
          new_entries = []

          ATTRIBUTE_KEYS.each do |change_type, key|
            next unless relevant_for?(audit, change_type)

            old_value, new_value = change_pair(audit, key)
            next if old_value.nil? && new_value.nil?
            next if old_value == new_value
            # Skip create-time values except enrichment status (e.g. rollover sets
            # rolled_over on a new enrichment record).
            next if old_value.nil? && change_type != :enrichment_status

            new_entries << new(
              change_type:,
              old_value:,
              new_value:,
              created_at: audit.created_at,
              user: audit.user,
              course: course_for(audit, courses_by_id, enrichments_by_id),
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
            normalize_application_status(value)
          when "status"
            normalize_enrichment_status(value)
          else
            value.to_s
          end
        end
        private_class_method :normalize

        def self.normalize_application_status(value)
          case value
          when 0, "0", "closed" then "closed"
          when 1, "1", "open" then "open"
          else value.to_s
          end
        end
        private_class_method :normalize_application_status

        def self.normalize_enrichment_status(value)
          case value
          when 0, "0", "draft" then "draft"
          when 1, "1", "published" then "published"
          when 2, "2", "rolled_over" then "rolled_over"
          when 3, "3", "withdrawn" then "withdrawn"
          else value.to_s
          end
        end
        private_class_method :normalize_enrichment_status

        def self.course_for(audit, courses_by_id, enrichments_by_id)
          case audit.auditable_type
          when Course.name
            courses_by_id[audit.auditable_id]
          when CourseEnrichment.name
            enrichment = enrichments_by_id[audit.auditable_id]
            courses_by_id[enrichment.course_id] if enrichment
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
          labels =
            case change_type
            when :application_status then APPLICATION_STATUS_LABELS
            when :enrichment_status then ENRICHMENT_STATUS_LABELS
            else {}
            end

          labels.fetch(value) { { text: value.to_s.humanize, colour: "grey" } }
        end
      end
    end
  end
end
