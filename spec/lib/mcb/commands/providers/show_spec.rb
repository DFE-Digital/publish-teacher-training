require "mcb_helper"

describe "mcb providers list" do
  def execute_show(arguments: [], input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(["providers", "show", *arguments])
    end
  end

  let(:recruitment_year1) { find_or_create(:recruitment_cycle, year: "2020") }
  let(:recruitment_year2) { RecruitmentCycle.current_recruitment_cycle }

  let(:provider) { create :provider, recruitment_cycle: recruitment_year1 }
  let(:rolled_over_provider) do
    new_provider = provider.dup
    new_provider.update(recruitment_cycle: recruitment_year2)
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

      output = execute_show(arguments: [provider.provider_code, "-r", recruitment_year1.year])[:stdout]
      expect(output).to have_text_table_row("id", provider.id.to_s)
      expect(output).to have_text_table_row("provider_code", provider.provider_code)
    end
  end
end
