require 'mcb_helper'

describe 'mcb providers touch' do
  let(:touch) { MCBCommand.new('providers', 'touch') }

  let(:recruitment_year1) { create :recruitment_cycle, year: '2018' }
  let(:recruitment_year2) { find_or_create :recruitment_cycle, year: '2019' }

  let(:provider) { create :provider, updated_at: 1.day.ago, changed_at: 1.day.ago, recruitment_cycle: recruitment_year1 }
  let(:rolled_over_provider) do
    new_provider = provider.dup
    new_provider.update(recruitment_cycle: recruitment_year2)
    new_provider.save
    new_provider
  end

  context 'when the recruitment year is unspecified' do
    it 'updates the providers updated_at for the current recruitment cycle' do
      rolled_over_provider

      Timecop.freeze(Date.today + 1) do
        touch.execute(arguments: [rolled_over_provider.provider_code])

        # Use to_i compare seconds since epoch and side-step sub-second
        # differences that show up even with Timecop on certain platforms.
        expect(provider.reload.updated_at.to_i).to eq Time.now.to_i
        expect(rolled_over_provider.reload.updated_at.to_i).not_to eq Time.now.to_i
      end
    end

    it 'updates the providers changed_at' do
      rolled_over_provider

      Timecop.freeze(Date.today + 1) do
        touch.execute(arguments: [rolled_over_provider.provider_code])

        expect(provider.reload.changed_at.to_i).to eq Time.now.to_i
        expect(rolled_over_provider.reload.changed_at.to_i).not_to eq Time.now.to_i
      end
    end

    it 'adds audit comment' do
      rolled_over_provider

      expect {
        touch.execute(arguments: [rolled_over_provider.provider_code])
      }.to change { provider.reload.audits.count }
             .from(1).to(2)
    end
  end

  context 'when the recruitment year is specified' do
    it 'updates the providers updated_at' do
      rolled_over_provider

      Timecop.freeze(Date.today + 1) do
        touch.execute(arguments: [provider.provider_code, '-r', recruitment_year1.year])

        # Use to_i compare seconds since epoch and side-step sub-second
        # differences that show up even with Timecop on certain platforms.
        expect(provider.reload.updated_at.to_i).to eq Time.now.to_i
        expect(rolled_over_provider.reload.changed_at.to_i).not_to eq Time.now.to_i
      end
    end

    it 'updates the providers changed_at' do
      rolled_over_provider

      Timecop.freeze(Date.today + 1) do
        touch.execute(arguments: [provider.provider_code, '-r', recruitment_year1.year])

        expect(provider.reload.changed_at.to_i).to eq Time.now.to_i
        expect(rolled_over_provider.reload.changed_at.to_i).not_to eq Time.now.to_i
      end
    end

    it 'adds audit comment' do
      rolled_over_provider

      expect {
        touch.execute(arguments: [provider.provider_code, '-r', recruitment_year1.year])
      }.to change { provider.reload.audits.count }
             .from(1).to(2)
    end
  end
end
