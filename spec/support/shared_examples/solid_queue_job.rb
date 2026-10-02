# frozen_string_literal: true

RSpec.shared_examples "a Solid Queue job" do |queue:|
  it "runs on Solid Queue's #{queue} queue" do
    expect(described_class.queue_adapter_name).to eq("solid_queue")
    expect(described_class.new.queue_name).to eq(queue)
  end
end
