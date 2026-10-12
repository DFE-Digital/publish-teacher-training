# frozen_string_literal: true

RSpec.shared_examples "a Solid Queue job" do |queue:|
  it "runs on Solid Queue's #{queue} queue" do
    production_queues = YAML.safe_load(
      ERB.new(Rails.root.join("config/queue.yml").read).result,
      aliases: true,
    ).fetch("production").fetch("workers").flat_map { |worker| Array(worker.fetch("queues")) }

    expect(described_class.new.queue_name).to eq(queue)
    expect(production_queues).to include(queue)
  end
end
