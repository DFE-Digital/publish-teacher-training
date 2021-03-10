require 'ruby-graphviz'

module GIAS
  class GenerateGraphService
    include ServicePattern

    def initialize(start:)
      @start = start
    end

    def call
      graph = GraphViz.new("Provider Graph", type: "strict digraph")

      case @start
      when Provider then add_provider(graph: graph, provider: @start)
      when GIASEstablishment then add_establishment(graph: graph, establishment: @start)
      end

      graph
    end

    def arrow_attributes(**attributes)
      {
        arrowhead: "none"
      }.merge(attributes)
    end

    def provider_node_name(provider)
      "#{provider.provider_code} - #{provider.provider_name}"
    end

    def site_node_name(site)
      "#{site.code} - #{site.location_name}"
    end

    def establishment_node_name(establishment)
      "#{establishment.urn} - #{establishment.name}"
    end

    def add_provider(graph:, provider:)
      title = provider_node_name(provider)

      provider_node = graph.find_node(title)
      return provider_node if provider_node

      provider_node = graph.add_nodes(title, shape: :octagon)

      provider.establishments_matched_by_name.each do |establishment|
        establishment_node = add_establishment(graph: graph, establishment: establishment)
        graph.add_edges(establishment_node, provider_node, arrow_attributes(style: :dotted))
      end

      provider.establishments_matched_by_postcode.each do |establishment|
        establishment_node = add_establishment(graph: graph, establishment: establishment)
        graph.add_edges(establishment_node, provider_node, arrow_attributes(style: :dashed))
      end

      provider.sites.each do |site|
        site_node = add_site(graph: graph, site: site)
        graph.add_edges(provider_node, site_node, arrow_attributes)
      end

      provider_node
    end

    def add_site(graph:, site:)
      title = site_node_name(site)
      site_node = graph.find_node(title)
      return site_node if site_node

      site_node = graph.add_nodes(title, shape: :house)

      site.establishments_matched_by_name.each do |establishment|
        establishment_node = add_establishment(graph: graph, establishment: establishment)
        graph.add_edges(establishment_node, site_node, arrow_attributes(style: :dotted))
      end

      site.establishments_matched_by_postcode.each do |establishment|
        establishment_node = add_establishment(graph: graph, establishment: establishment)
        graph.add_edges(establishment_node, site_node, arrow_attributes(style: :dashed))
      end

      site_node
    end

    def add_establishment(graph:, establishment:)
      title = establishment_node_name(establishment)

      establishment_node = graph.find_node(title)
      return establishment_node if establishment_node

      establishment_node = graph.add_nodes(title, shape: :box)

      establishment.providers_matched_by_name.each do |provider|
        provider_node = add_provider(graph: graph, provider: provider)
        graph.add_edges(establishment_node, provider_node, arrow_attributes(style: :dotted))
      end

      establishment.providers_matched_by_postcode.each do |provider|
        provider_node = add_provider(graph: graph, provider: provider)
        graph.add_edges(establishment_node, provider_node, arrow_attributes(style: :dashed))
      end

      establishment.sites_matched_by_name.each do |site|
        site_node = add_site(graph: graph, site: site)
        graph.add_edges(establishment_node, site_node, arrow_attributes(style: :dotted))
      end

      establishment.sites_matched_by_postcode.each do |site|
        site_node = add_site(graph: graph, site: site)
        graph.add_edges(establishment_node, site_node, arrow_attributes(style: :dashed))
      end

      establishment_node
    end
  end
end
