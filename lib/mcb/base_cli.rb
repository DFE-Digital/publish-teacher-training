module MCB
  class BaseCLI
    def initialize
      @cli = HighLine.new
    end

    def multiselect(initial_items:, possible_items:, select_all_option: false, hidden_label: nil)
      selected_items = initial_items
      finished = false
      until finished do
        @cli.choose do |menu|
          menu.choice("continue") { finished = true }
          menu.choice("select all") { selected_items = possible_items.to_a.dup } if select_all_option
          define_choices_for_each_possible_item(
            menu: menu,
            selected_items: selected_items,
            possible_items: possible_items,
            hidden_label: hidden_label
          )
        end
      end
      selected_items
    end

    def ask_multiple_choice(prompt:, choices:, default: nil)
      @cli.choose do |menu|
        menu.prompt = prompt + "  "
        menu.choice("exit") { nil }
        menu.choices(*choices)
        menu.default = default if default.present?
      end
    end

  private

    def define_choices_for_each_possible_item(menu:, selected_items:, possible_items:, hidden_label:)
      possible_items.sort_by(&:to_s).each do |item|
        if item.in?(selected_items)
          menu.choice("[x] #{item}") { selected_items.delete(item) }
          menu.hidden(hidden_label[item]) { selected_items.delete(item) } if hidden_label.present?
        else
          menu.choice("[ ] #{item}") { selected_items << item }
          menu.hidden(hidden_label[item]) { selected_items << item } if hidden_label.present?
        end
      end
    end
  end
end
