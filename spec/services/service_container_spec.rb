describe ServiceContainer do
  it "Allows you to register services" do
    service_spy = spy
    container = ServiceContainer.new

    container.define(:test, :one) do
      service_spy
    end

    container.get(:test, :one).execute(cat: "Meow")

    expect(service_spy).to have_received(:execute).with(cat: "Meow")
  end
end
