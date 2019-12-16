require "mcb_helper"

describe "mcb providers touch" do
  def execute_touch(arguments: [])
    $mcb.run(["providers", "touch", *arguments])
  end

  let(:next_cycle)    { find_or_create :recruitment_cycle, :next }
  let(:current_cycle) { find_or_create :recruitment_cycle }

  let(:provider) { create :provider, updated_at: 1.day.ago, changed_at: 1.day.ago }
  let(:rolled_over_provider) do
    new_provider = provider.dup
    new_provider.update(recruitment_cycle: next_cycle)
    new_provider.save
    new_provider
  end

  context "when the recruitment year is unspecified" do
    it "updates the providers updated_at for the current recruitment cycle" do
      rolled_over_provider

      Timecop.freeze(Time.zone.today + 1) do
        execute_touch(arguments: [provider.provider_code])

        # Use to_i compare seconds since epoch and side-step sub-second
        # differences that show up even with Timecop on certain platforms.
        expect(provider.reload.updated_at.to_i).to eq Time.now.to_i
        expect(rolled_over_provider.reload.updated_at.to_i).not_to eq Time.now.to_i
      end
    end

    it "updates the providers changed_at" do
      rolled_over_provider

      Timecop.freeze(Time.zone.today + 1) do
        execute_touch(arguments: [provider.provider_code])

        expect(provider.reload.changed_at.to_i).to eq Time.now.to_i
        expect(rolled_over_provider.reload.changed_at.to_i).not_to eq Time.now.to_i
      end
    end

    it "adds audit comment" do
      rolled_over_provider

      expect {
        execute_touch(arguments: [provider.provider_code])
      }.to change { provider.reload.audits.count }
             .from(1).to(2)
    end
  end

  context "when the recruitment year is specified" do
    it "updates the providers updated_at" do
      provider

      Timecop.freeze(Time.zone.today + 1) do
        execute_touch(arguments: [rolled_over_provider.provider_code, "-r", next_cycle.year])

        # Use to_i compare seconds since epoch and side-step sub-second
        # differences that show up even with Timecop on certain platforms.
        expect(provider.reload.updated_at.to_i).not_to eq Time.now.to_i
        expect(rolled_over_provider.reload.changed_at.to_i).to eq Time.now.to_i
      end
    end

    it "updates the providers changed_at" do
      provider

      Timecop.freeze(Time.zone.today + 1) do
        execute_touch(arguments: [rolled_over_provider.provider_code, "-r", next_cycle.year])

        expect(provider.reload.changed_at.to_i).not_to eq Time.now.to_i
        expect(rolled_over_provider.reload.changed_at.to_i).to eq Time.now.to_i
      end
    end

    it "adds audit comment" do
      provider

      expect {
        execute_touch(arguments: [rolled_over_provider.provider_code, "-r", next_cycle.year])
      }.to change { rolled_over_provider.reload.audits.count }
             .from(1).to(2)
    end
  end
end
