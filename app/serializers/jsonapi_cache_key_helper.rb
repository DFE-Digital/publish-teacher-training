module JsonapiCacheKeyHelper
  def jsonapi_cache_key(options)
    "#{self.class}/#{@object.cache_key_with_version} " + super(options)
  end
end
