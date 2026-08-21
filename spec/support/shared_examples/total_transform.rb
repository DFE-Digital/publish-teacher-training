# frozen_string_literal: true

RSpec.shared_examples "a total transform" do
  let(:expected_to_drop) { [] }

  it "accounts for every input" do
    expected = input_keys.uniq - expected_to_drop
    actual = output_keys.uniq

    silently_dropped = expected - actual
    unmatched_output = actual - input_keys.uniq

    aggregate_failures do
      expect(silently_dropped).to be_empty, lambda {
        "#{silently_dropped.length} input(s) produced no output and were not named " \
        "in expected_to_drop: #{silently_dropped.inspect}"
      }
      expect(unmatched_output).to be_empty, lambda {
        "output carries #{unmatched_output.length} key(s) with no matching input: #{unmatched_output.inspect}"
      }
    end
  end
end
