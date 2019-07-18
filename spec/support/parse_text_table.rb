#Issues to be mindful of when using this function
# It is coupled to the border styling
# All whitespace is discarded
# Rows containing entirely dashes and/or plusses will be interpretted as the
# beginning of a new row
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
