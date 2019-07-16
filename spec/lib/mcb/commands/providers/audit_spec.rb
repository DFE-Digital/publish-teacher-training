require 'mcb_helper'

describe 'mcb providers audit' do
  let(:recruitment_year1) { create :recruitment_cycle, year: '2018' }
  let(:recruitment_year2) { RecruitmentCycle.current_recruitment_cycle }

  let(:provider) { create :provider, updated_at: 1.day.ago, changed_at: 1.day.ago, recruitment_cycle: recruitment_year1 }
  let(:rolled_over_provider) do
    new_provider = provider.dup
    new_provider.update(recruitment_cycle: recruitment_year2)
    new_provider.save
    new_provider
  end

  def audit(*arguments)
    stderr = nil
    output = with_stubbed_stdout(stdin: "", stderr: stderr) do
      $mcb.run %W[provider audit] + arguments
    end
    { stdout: output, stderr: stderr }
  end

  context 'with an unspecified recruitment year' do
    it 'displays audit for provider for default recruitment year' do
      output = audit(rolled_over_provider.provider_code)[:stdout]
      expect(output).to have_text_table_row('user', 'user email', 'action', 'associated', 'associated', 'changes', 'created_at')
      expect(output).to have_text_table_row('id', '', '', 'id', 'type', '')
      expect(output).to include("\"recruitment_cycle_id\"=>#{recruitment_year2.id}")
    end
  end

  context 'with a specified recruitment year' do
    it 'displays audit for provider for specified recruitment year' do
      output = audit(rolled_over_provider.provider_code, '-r', recruitment_year1.year)[:stdout]

      expect(output).to have_text_table_row('user', 'user email', 'action', 'associated', 'associated', 'changes', 'created_at')
      expect(output).to have_text_table_row('id', '', '', 'id', 'type', '')
      expect(output).to include("\"recruitment_cycle_id\"=>#{recruitment_year1.id}")
    end
  end
end
