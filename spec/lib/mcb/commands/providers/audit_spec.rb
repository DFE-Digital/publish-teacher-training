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
      output = parse_text_table(audit(rolled_over_provider.provider_code)[:stdout])

      expect(output[0]).to eq(%w[userid useremail action associatedid associatedtype changes created_at])
      expect(output[1][5]).to include("\"recruitment_cycle_id\"=>#{recruitment_year2.id}")
    end
  end

  context 'with a specified recruitment year' do
    it 'displays audit for provider for specified recruitment year' do
      output = parse_text_table(audit(rolled_over_provider.provider_code, '-r', recruitment_year1.year)[:stdout])

      expect(output[0]).to eq(%w[userid useremail action associatedid associatedtype changes created_at])
      expect(output[1][5]).to include("\"recruitment_cycle_id\"=>#{recruitment_year1.id}")
    end
  end
end

#Issues to be mindful of when using this function
# It is coupled to the border styling
# All whitespace is discarded
# Rows containing entirely dashes will be interpretted as the beginning of a new row
def parse_text_table(text_table)
  cells = parse_cells(text_table)

  output_rows = [[]]
  cells.each do |cell|
    if cell == "\n"
      output_rows.append([])
    else
      output_rows.last.append(cell)
    end
  end

  grouped_rows = []
  output_rows.each do |row|
    if is_a_row_delimeter?(row)
      grouped_rows.append([])
    else
      grouped_rows.last.append(row)
    end
  end

  real_rows = []
  grouped_rows.each do |group|
    real_rows.append([])

    group.each do |row|
      row.each_with_index do |cell, index|
        real_rows.last[index] = "" if real_rows.last[index].nil?
        real_rows.last[index] += cell
      end

      real_rows.last.map! do |cell|
        cell.gsub(/\s/, '')
      end
    end
  end

  real_rows
end

def parse_cells(text_table)
  cell_delimeters = /\||\+/
  text_table.split(cell_delimeters).reject(&:empty?)
end

def is_a_row_delimeter?(row)
  contains_only_dashes = /^\-+$/
  row.join("").match?(contains_only_dashes)
end
