# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Salary routing", type: :routing do
  let(:base) { "http://publish.localhost/publish/organisations/ABC/#{year}/courses/X123/salary" }

  context "when the recruitment cycle year is 2026 or earlier" do
    let(:year) { 2026 }

    it "routes GET salary to the edit action" do
      expect(get: base).to route_to(
        "publish/courses/salary#edit",
        provider_code: "ABC",
        recruitment_cycle_year: "2026",
        code: "X123",
        host: "publish.localhost",
      )
    end

    it "routes PATCH salary to the update action" do
      expect(patch: base).to route_to(
        "publish/courses/salary#update",
        provider_code: "ABC",
        recruitment_cycle_year: "2026",
        code: "X123",
        host: "publish.localhost",
      )
    end
  end

  context "when the recruitment cycle year is after 2026" do
    let(:year) { 2027 }

    it "does not route GET salary" do
      expect(get: base).not_to be_routable
    end

    it "does not route PATCH salary" do
      expect(patch: base).not_to be_routable
    end
  end
end
