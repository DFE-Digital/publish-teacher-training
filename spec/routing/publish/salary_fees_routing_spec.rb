# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Salary fees routing", type: :routing do
  let(:base) { "http://publish.localhost/publish/organisations/ABC/#{year}/courses/X123/salary-fees" }

  context "when the recruitment cycle year is after 2026" do
    let(:year) { 2027 }

    it "routes GET salary-fees to the edit action" do
      expect(get: base).to route_to(
        "publish/courses/salary_fees#edit",
        provider_code: "ABC",
        recruitment_cycle_year: "2027",
        code: "X123",
        host: "publish.localhost",
      )
    end

    it "routes PATCH salary-fees to the update action" do
      expect(patch: base).to route_to(
        "publish/courses/salary_fees#update",
        provider_code: "ABC",
        recruitment_cycle_year: "2027",
        code: "X123",
        host: "publish.localhost",
      )
    end
  end

  context "when the recruitment cycle year is 2026 or earlier" do
    let(:year) { 2026 }

    it "does not route GET salary-fees" do
      expect(get: base).not_to be_routable
    end

    it "does not route PATCH salary-fees" do
      expect(patch: base).not_to be_routable
    end
  end
end
