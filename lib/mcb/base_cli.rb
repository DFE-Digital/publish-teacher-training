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

    def confirm_creation?
      @cli.agree("Continue? ")
    end

    def enter_to_continue
      @cli.ask("Press Enter to continue")
    end

  private

    def define_choices_for_each_possible_item(menu:, selected_items:, possible_items:, hidden_label:)
      possible_items.sort_by(&:to_s).each do |item|
        define_item(menu: menu, item: item, selected_items: selected_items, hidden_label: hidden_label)
      end
    end

    def define_item(menu:, item:, selected_items:, hidden_label:)
      if item.in?(selected_items)
        action = ->(_) { selected_items.delete(item) }
        label = "[x] #{item}"
      else
        action = ->(_) { selected_items << item }
        label = "[ ] #{item}"
      end
      menu.choice(label, &action)
      menu.hidden(hidden_label[item], &action) if hidden_label.present?
    end
  end
end
