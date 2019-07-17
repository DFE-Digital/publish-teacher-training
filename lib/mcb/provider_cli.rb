module MCB
  class ProviderCLI < BaseCLI
    def ask_name
      @cli.ask("Enter new name").strip
    end
  end
end
