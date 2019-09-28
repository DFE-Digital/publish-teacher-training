require "mcb_helper"

describe "mcb providers list" do
  def execute_show(arguments: [], input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(["providers", "show", *arguments])
    end
  end

  let(:next_cycle)    { find_or_create :recruitment_cycle, :next }
  let(:current_cycle) { find_or_create :recruitment_cycle }

  let(:provider) { create :provider, recruitment_cycle: next_cycle }
  let(:rolled_over_provider) do
    new_provider = provider.dup
    new_provider.update(recruitment_cycle: current_cycle)
    new_provider.save
    new_provider
  end

  context "when recruitment cycle is unspecified" do
    it "shows information for the provider with the default recruitment cycle" do
      output = execute_show(arguments: [rolled_over_provider.provider_code])[:stdout]

      expect(output).to have_text_table_row("id", rolled_over_provider.id.to_s)
      expect(output).to have_text_table_row("provider_code", rolled_over_provider.provider_code)
    end
  end

  context "when recruitment cycle is specified" do
    it "shows information for the provider with the default recruitment cycle" do
      rolled_over_provider

      output = execute_show(arguments: [provider.provider_code, "-r", next_cycle.year])[:stdout]
      expect(output).to have_text_table_row("id", provider.id.to_s)
      expect(output).to have_text_table_row("provider_code", provider.provider_code)
    end
  end
end
