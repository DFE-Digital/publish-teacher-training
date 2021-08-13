module BigQuery
  class EntityEvent
    EVENT_TYPES = %w[create_entity update_entity].freeze

    def initialize
      @event_hash = {
        environment: Rails.env,
        occurred_at: Time.zone.now.iso8601,
      }
      yield self if block_given?
    end

    delegate :as_json, to: :event_hash

    def with_type(type)
      raise "Invalid analytics event type" unless EVENT_TYPES.include?(type.to_s)

      @event_hash.merge!(
        event_type: type,
      )
    end

    def with_entity_table_name(table_name)
      @event_hash.merge!(
        entity_table_name: table_name,
      )
    end

    def with_data(hash)
      @event_hash.deep_merge!({
        data: hash_to_kv_pairs(hash),
      })
    end

  private

    attr_reader :event_hash

    def hash_to_kv_pairs(hash)
      hash.map do |(key, value)|
        if value.in? [true, false]
          value = value.to_s
        end

        { "key" => key, "value" => Array.wrap(value) }
      end
    end
  end
end
