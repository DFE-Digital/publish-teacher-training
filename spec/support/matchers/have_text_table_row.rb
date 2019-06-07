RSpec::Matchers.define :have_text_table_row do |*column_values|
  match do |actual|
    escaped_column_values = column_values.map do |val|
      val.is_a?(Regexp) ? val : Regexp.quote(val.to_s)
    end

    actual.match?('(^\s*|\|\s+)' +
                  escaped_column_values.join('\s+\|\s+') +
                  '(\s+\||\s*$)')
  end

  failure_message do |output|
    <<~EOMESSAGE
      expected the columns:

      #{column_values.join(' | ')}

      To be in the output:

      #{output}
    EOMESSAGE
  end
end
