module GIAS
  class ProviderGraphGeneratorService
    include ServicePattern

    def initialize(provider:)
      @provider = provider
    end

    def call
      graph = GraphViz.new("Provider Graph", type: "digraph", rankdir: "LR")

      GIAS::AddNodesToGraphService.call(graph: graph, provider: @provider)

      graph
    end
  end
end
