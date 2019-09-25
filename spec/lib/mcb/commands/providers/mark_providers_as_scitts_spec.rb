require "mcb_helper"

describe "mcb providers mark_providers_as_scitts" do
  let(:output) { execute_command[:stdout] }

  let(:provider_one_current) do
    create(
      :provider,
      provider_name: "Alliance for Learning SCITT",
      provider_type: "lead_school",
    )
  end

  let(:provider_one_next) do
    create(
      :provider,
      :next_recruitment_cycle,
      provider_name: "Alliance for Learning SCITT",
      provider_type: "lead_school",
    )
  end

  context "With a single provider to mark as a SCITT" do
    before do
      provider_one_current
      provider_one_next

      output

      provider_one_current.reload
      provider_one_next.reload
    end

    it "Migrates the provider in the current recruitment cycle" do
      expect(provider_one_current.scitt?).to be true
    end

    it "Migrates the provider in the next recruitment cycle" do
      expect(provider_one_next.scitt?).to be true
    end

    it "Includes the providers in the output" do
      expect(output).to include("Updating #{provider_one_current}")
      expect(output).to include("Updating #{provider_one_next}")
    end
  end

  context "With a multiple providers to mark as a SCITT" do
    let(:provider_two_current) do
      create(
        :provider,
        provider_name: "Astra SCITT",
        provider_type: "university",
      )
    end

    let(:provider_two_next) do
      create(
        :provider,
        :next_recruitment_cycle,
        provider_name: "Astra SCITT",
        provider_type: "university",
      )
    end

    before do
      provider_one_current
      provider_one_next
      provider_two_current
      provider_two_next

      output

      provider_one_current.reload
      provider_one_next.reload
      provider_two_current.reload
      provider_two_next.reload
    end

    it "Migrates the first provider in the current recruitment cycle" do
      expect(provider_one_current.scitt?).to be true
    end

    it "Migrates the second provider in the current recruitment cycle" do
      expect(provider_two_current.scitt?).to be true
    end

    it "Migrates the provider in the next recruitment cycle" do
      expect(provider_one_next.scitt?).to be true
    end

    it "Migrates the second provider in the next recruitment cycle" do
      expect(provider_two_next.scitt?).to be true
    end

    it "Includes the providers in the output" do
      expect(output).to include("Updating #{provider_one_current}")
      expect(output).to include("Updating #{provider_one_next}")

      expect(output).to include("Updating #{provider_two_current}")
      expect(output).to include("Updating #{provider_two_next}")
    end
  end

private

  def execute_command
    with_stubbed_stdout do
      $mcb.run(%w[providers mark_providers_as_scitts])
    end
  end
end
