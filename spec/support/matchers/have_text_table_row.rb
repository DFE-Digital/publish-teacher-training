RSpec::Matchers.define :have_text_table_row do |*column_values|
  match do |actual|
    actual.match? '(^\s*|\|\s+)' + column_values.join('\s+\|\s+') + '(\s+\||\s*$)'
  end
end
