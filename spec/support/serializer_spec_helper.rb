# https://gist.github.com/roalcantara/6cd4f7d915102f3d50018606bb61d091

module SerializerSpecHelper
  def serialize(obj, opts = {})
    serializer_class = opts.delete(:serializer_class) || "#{obj.class.name}Serializer".constantize
    serializer = serializer_class.send(:new, obj)
    serializer.serializable_hash.with_indifferent_access
  end
end
