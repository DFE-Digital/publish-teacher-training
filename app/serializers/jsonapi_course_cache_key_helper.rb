module JsonapiCourseCacheKeyHelper
  # When a course has sites updated the course's 'changed_at' field is touched
  # We need to add the 'changed_at' value to the cache key so that the cache is refreshed
  def jsonapi_cache_key(options)
    "#{self.class}/#{@object.cache_key_with_version}/#{@object.changed_at} " + super(options)
  end
end
