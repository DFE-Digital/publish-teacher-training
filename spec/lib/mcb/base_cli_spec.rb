require 'mcb_helper'

describe MCB::BaseCLI do
  def run_with_input_commands(*input_cmds)
    stderr = nil
    output = with_stubbed_stdout(stdin: input_cmds.join("\n"), stderr: stderr) do
      yield
    end
    [output, stderr]
  end

  subject { described_class.new }

  describe "#multiselect" do
    let(:initial_items) { ["option A", "option C"] }
    let(:possible_items) { ["option A", "option B", "option C"] }

    def run_multiselect(select_all_option: false, hidden_label: nil)
      subject.multiselect(
        initial_items: initial_items,
        possible_items: possible_items,
        select_all_option: select_all_option,
        hidden_label: hidden_label
      )
    end

    it "shows the initial values" do
      output, = run_with_input_commands("continue") { run_multiselect }

      expect(output).to include("[x] option A")
      expect(output).to include("[ ] option B")
      expect(output).to include("[x] option C")
      expect(output.scan(/option/).count).to eq(3)
    end

    context "without modifications" do
      it "returns a result that matches the initial items" do
        result = nil
        run_with_input_commands("continue") { result = run_multiselect }

        expect(result).to eq(initial_items)
      end
    end

    context "with modifications" do
      it "shows the updates once an item has been selected or deselected" do
        output, = run_with_input_commands("[x] option A", "[ ] option B", "continue") { run_multiselect }

        expect(output).to include("[ ] option A")
        expect(output).to include("[x] option B")
        expect(output).to include("[x] option C")
      end

      it "returns the actual updated values once run" do
        result = nil
        run_with_input_commands("[x] option A", "[ ] option B", "continue") {
          result = run_multiselect
        }

        expect(result.sort).to eq(["option B", "option C"])
      end

      it "supports an optional 'select all' option" do
        result = nil
        run_with_input_commands("select all", "continue") {
          result = run_multiselect(select_all_option: true)
        }

        expect(result.sort).to eq(["option A", "option B", "option C"])
      end

      it "supports an optional hidden alias for each option" do
        result = nil
        run_with_input_commands("A", "B", "continue") { # unselect A, select B
          result = run_multiselect(hidden_label: ->(option) { option.split[1] })
        }

        expect(result.sort).to eq(["option B", "option C"])
      end
    end
  end
end
