module GIAS
  class EstablishmentGraphGeneratorService
    include ServicePattern

    def initialize(establishment:)
      @establishment = establishment
    end

    def call
      graph = GraphViz.new("Establishment Graph", type: "digraph", rankdir: "LR")

      GIAS::AddNodesToGraphService.call(graph: graph, establishment: @establishment)

      graph
    end
  end
end
