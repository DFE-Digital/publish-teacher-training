class FeatureFlag
  class << self
    def active?(feature_name)
      feature = RedisClient.current.get("feature_flags_#{feature_name}")

      return false unless feature

      JSON.parse(feature)["state"]
    end

    def activate(feature_name)
      raise UnknownFeatureError unless feature_name.in?(features)

      sync_with_redis(feature_name, true)
    end

    def deactivate(feature_name)
      raise UnknownFeatureError unless feature_name.in?(features)

      sync_with_redis(feature_name, false)
    end

    def features
      FeatureFlags.all.to_h do |name, description, owner|
        [name, FeatureFlag.new(name:, description:, owner:)]
      end.with_indifferent_access
    end

    def last_updated(feature_name)
      feature = RedisClient.current.get("feature_flags_#{feature_name}")

      return unless feature

      JSON.parse(feature)["updated_at"]
    end

  private

    def sync_with_redis(feature_name, feature_state)
      RedisClient.current.set(
        "feature_flags_#{feature_name}", { state: feature_state, updated_at: Time.zone.now }.to_json
      )
    end
  end

  attr_accessor :name, :description, :owner, :type

  def initialize(name:, description:, owner:)
    self.name = name
    self.description = description
    self.owner = owner
  end

  class UnknownFeatureError < StandardError; end
end
