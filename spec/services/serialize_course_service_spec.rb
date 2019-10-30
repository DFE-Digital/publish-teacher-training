describe SerializeCourseService do
  let(:serializers_stub) { { ClassToRender: double } }
  let(:serializers_service_spy) { spy(execute: serializers_stub) }
  let(:rendered_stub) { double }
  let(:renderer_spy) { spy(render: rendered_stub) }
  let(:service) do
    described_class.new(
      serializers_service: serializers_service_spy,
      renderer: renderer_spy,
    )
  end

  let(:object_to_serialize) { spy }
  it "calls the serializer service" do
    service.execute(object: object_to_serialize)
    expect(serializers_service_spy).to have_received(:execute).with(no_args)
  end

  it "calls the renderer" do
    service.execute(object: object_to_serialize)
    expect(renderer_spy).to have_received(:render).with(object_to_serialize, class: serializers_stub)
  end

  it "returns the result of the renderer" do
    expect(service.execute(object: object_to_serialize)[:serialized]).to eq(rendered_stub)
  end
end
