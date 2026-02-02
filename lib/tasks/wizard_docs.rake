# lib/tasks/wizard_docs.rake

require "dfe/wizard/documentation/formatters/mermaid_formatter"
require "dfe/wizard/documentation/formatters/graphviz_formatter"
require "dfe/wizard/documentation/formatters/markdown_formatter"

namespace :wizard do
  namespace :docs do
    # Generate documentation for all wizards
    #
    # Generates documentation (Mermaid, GraphViz, Markdown) for all wizard
    # classes found in app/wizards, in all supported themes.
    #
    # @example Generate all wizard documentation
    #   rake wizard:docs:generate
    #
    # @example Generate specific wizard
    #   WIZARD=PersonalInformationWizard rake wizard:docs:generate
    desc "Generate documentation for all wizards"
    task generate: :environment do
      # assuming your wizards live on app/wizards
      #
      Dir["app/wizards/**/*.rb"].each { |f| require File.expand_path(f) }

      output_dir = "guides/wizard"

      # you can hardcoded or make a way to discover all wizards.
      # Here we hardcoded PersonalInformationWizard
      [
        ALevelsWizard,
      ].each do |wizard_class|
        wizard = wizard_class.new(state_store: OpenStruct.new)

        # Using #generate_all but you can also generate individually.

        # Generate Markdown
        #   docs.generate(:markdown, 'docs/wizard.md')
        #
        # Generate Mermaid flowchart
        #   docs.generate(:mermaid, 'docs/wizard.mmd')
        #
        # Generate Graphviz diagram
        #   docs.generate(:graphviz, 'docs/wizard.dot')
        #
        wizard.documentation.generate_all(output_dir)

        puts "Generated docs for #{wizard_class.name}"
      end

      puts "All wizard docs written to #{File.expand_path(output_dir)}/"
    end
  end
end
