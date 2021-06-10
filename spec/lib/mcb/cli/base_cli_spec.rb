require "mcb_helper"

describe MCB::Cli::BaseCli do
  def run_with_input_commands(*input_cmds, &block)
    with_stubbed_stdout(stdin: input_cmds.join("\n"), &block)
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
        hidden_label: hidden_label,
      )
    end

    it "shows the initial values" do
      outputs = run_with_input_commands("continue") { run_multiselect }
      output = outputs[:stdout]

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
        outputs = run_with_input_commands("[x] option A", "[ ] option B", "continue") { run_multiselect }
        output = outputs[:stdout]

        expect(output).to include("[ ] option A")
        expect(output).to include("[x] option B")
        expect(output).to include("[x] option C")
      end

      it "returns the actual updated values once run" do
        result = nil
        run_with_input_commands("[x] option A", "[ ] option B", "continue") do
          result = run_multiselect
        end

        expect(result.sort).to eq(["option B", "option C"])
      end

      it "supports an optional 'select all' option" do
        result = nil
        run_with_input_commands("select all", "continue") do
          result = run_multiselect(select_all_option: true)
        end

        expect(result.sort).to eq(["option A", "option B", "option C"])
      end

      it "supports an optional hidden alias for each option" do
        result = nil
        run_with_input_commands("A", "B", "continue") do # unselect A, select B
          result = run_multiselect(hidden_label: ->(option) { option.split[1] })
        end

        expect(result.sort).to eq(["option B", "option C"])
      end
    end
  end
end
