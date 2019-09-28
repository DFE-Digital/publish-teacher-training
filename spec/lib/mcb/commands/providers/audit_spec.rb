require "mcb_helper"

describe "mcb providers audit" do
  let(:current_cycle) { find_or_create :recruitment_cycle }
  let(:next_cycle) { find_or_create :recruitment_cycle, :next }

  let(:provider) { create :provider, updated_at: 1.day.ago, changed_at: 1.day.ago, recruitment_cycle: current_cycle }
  let(:rolled_over_provider) do
    new_provider = provider.dup
    new_provider.update(recruitment_cycle: next_cycle)
    new_provider.save
    new_provider
  end

  def execute_audit(arguments: [], input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(["providers", "audit", *arguments])
    end
  end

  context "with an unspecified recruitment year" do
    it "displays audit for provider for default recruitment year" do
      output = parse_text_table(
        execute_audit(arguments: [rolled_over_provider.provider_code])[:stdout],
      )

      expect(output[0]).to eq(%w[userid useremail action associatedid associatedtype changes created_at])
      expect(output[1][5]).to include("\"recruitment_cycle_id\"=>#{current_cycle.id}")
    end
  end

  context "with a specified recruitment year" do
    it "displays audit for provider for specified recruitment year" do
      output = parse_text_table(
        execute_audit(
          arguments: [rolled_over_provider.provider_code, "-r", next_cycle.year],
        )[:stdout],
      )

      expect(output[0]).to eq(%w[userid useremail action associatedid associatedtype changes created_at])
      expect(output[1][5]).to include("\"recruitment_cycle_id\"=>#{next_cycle.id}")
    end
  end
end
