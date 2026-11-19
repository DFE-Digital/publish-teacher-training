# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sandbox::ImportReport do
  subject(:report) { described_class.new }

  it "starts empty" do
    expect(described_class::FIELDS.map { |field| report.public_send(field) }).to all(eq([]))
  end

  describe "#merge!" do
    it "adds another report's entries to this one" do
      report.created << "RX41"
      report.missing_accredited_providers << "A01"
      other = described_class.new
      other.created << "2B9P"
      other.missing_accredited_providers << "A01"

      report.merge!(other)

      expect(report).to have_attributes(created: %w[RX41 2B9P], missing_accredited_providers: %w[A01])
    end
  end
end
