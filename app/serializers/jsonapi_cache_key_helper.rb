# frozen_string_literal: true

module JsonapiCacheKeyHelper
  def jsonapi_cache_key(options)
    "#{self.class}/#{@object.cache_key_with_version} " + super
  end
end
