RSpec::Matchers.define :have_text_table_row do |*column_values|
  match do |actual|
    actual.match? column_values.join('\s+\|\s+')
  end
end
