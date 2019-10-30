class SerializeCourseService
  def initialize(serializers_service: CourseSerializersService.new, renderer: JSONAPI::Serializable::Renderer.new)
    @serializers_service = serializers_service
    @renderer = renderer
  end

  def execute(object:)
    { serialized: @renderer.render(object, class: @serializers_service.execute) }
  end
end
