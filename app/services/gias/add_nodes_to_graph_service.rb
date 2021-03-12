module GIAS
  class AddNodesToGraphService
    include ServicePattern

    def initialize(graph:, provider: nil, establishment: nil, debug_enabled: false)
      @graph = graph
      @provider = provider
      @establishment = establishment
      @debug = debug_enabled

      @nodes = {}
    end

    def call
      add_provider_node(@provider, graph: @graph, all_sites: true, draw_matches: true) if @provider
      add_establishment_node(@establishment, graph: @graph, draw_matches: true) if @establishment
    end

  private

    def routes
     Rails.application.routes.url_helpers
    end

    def add_provider_node(provider, graph:, all_sites: true, draw_matches: true)
      return @nodes[provider] if @nodes.key? provider

      debug("adding provider node: #{provider_node_name(provider)}")

      @nodes[provider] = graph.add_nodes(provider.provider_code,
                                         shape: :octagon,
                                         label: provider_node_name(provider),
                                         "URL": routes.gias_provider_path(provider))

      if all_sites
        sites_list = provider.sites
      else
        sites_list = provider.sites.that_match_establishments_by_name_or_postcode
      end

      sites_list.each do |site|
        add_site_node(site, graph: graph)
        add_edge(provider, site, graph: graph)
        add_establishment_matches_for_site(site, graph: graph) if draw_matches
      end

      add_establishment_matches_for_provider(provider, graph: graph) if draw_matches

      @nodes[provider]
    end

    def add_site_node(site, graph:)
      return @nodes[site] if @nodes.key? site

      debug("adding site node: #{site_node_name(site)}")

      @nodes[site] = graph.add_nodes("#{site.provider.provider_code} - #{site.code}",
                                     shape: :house,
                                     label: site_node_name(site))
    end

    def add_establishment_node(establishment, graph:, draw_matches: true)
      return @nodes[establishment] if @nodes.key? establishment

      debug("adding establishment node: #{establishment_node_name(establishment)}")

      @nodes[establishment] = graph.add_nodes(establishment.urn,
                                              shape: :box,
                                              label: establishment_node_name(establishment),
                                              "URL": routes.gias_establishment_path(establishment.urn))

      if draw_matches
        add_provider_matches_for_establishment(establishment, graph: graph)
        add_site_matches_for_establishment(establishment, graph: graph)
      end

      @nodes[establishment]
    end

    def add_establishment_matches_for_site(site, graph:)
      site.establishments_matched_by_name.each do |establishment|
        add_establishment_node(establishment, graph: graph, draw_matches: false)
        add_name_edge(site, establishment, graph: graph)
      end

      site.establishments_matched_by_postcode.each do |establishment|
        add_establishment_node(establishment, graph: graph, draw_matches: false)
        add_postcode_edge(site, establishment, graph: graph)
      end
    end

    def add_establishment_matches_for_provider(provider, graph:)
      provider.establishments_matched_by_name.each do |establishment|
        add_establishment_node(establishment, graph: graph, draw_matches: false)
        add_name_edge(provider, establishment, graph: graph)
      end

      provider.establishments_matched_by_postcode.each do |establishment|
        add_establishment_node(establishment, graph: graph, draw_matches: false)
        add_postcode_edge(provider, establishment, graph: graph)
      end
    end

    def add_provider_matches_for_establishment(establishment, graph:)
      establishment.providers_matched_by_name.each do |provider|
        add_provider_node(provider, graph: graph, draw_matches: false)
        add_name_edge(provider, establishment, graph: graph)
      end

      establishment.providers_matched_by_postcode.each do |provider|
        add_provider_node(provider, graph: graph, draw_matches: false)
        add_postcode_edge(provider, establishment, graph: graph)
      end
    end

    def add_site_matches_for_establishment(establishment, graph:)
      establishment.sites_matched_by_name.each do |site|
        add_provider_node(site.provider, graph: graph, draw_matches: false)
        # add_site_node(site, graph: graph)
        add_name_edge(site, establishment, graph: graph)
      end

      establishment.sites_matched_by_postcode.each do |site|
        add_provider_node(site.provider, graph: graph, draw_matches: false)
        # add_site_node(site, graph: graph)
        add_postcode_edge(site, establishment, graph: graph)
      end
    end

    def edge_attributes(**attributes)
      {
        arrowhead: "none",
      }.merge(attributes)
    end

    def provider_node_name(provider)
      "[#{provider.provider_code}] #{provider.provider_name}"
    end

    def site_node_name(site)
      "[#{site.code}] #{site.location_name}"
    end

    def establishment_node_name(establishment)
      "[#{establishment.urn}] #{establishment.name}"
    end

    def add_edge(source, destination, graph:, attributes: edge_attributes)
      graph.add_edges(@nodes[source], @nodes[destination], edge_attributes)
    end

    def add_name_edge(source, destination, graph:)
      graph.add_edges(@nodes[source],
                      @nodes[destination],
                      edge_attributes({
                                        color: "darkgreen",
                                        style: :dotted
                                      }))
    end

    def add_postcode_edge(source, destination, graph:)
      graph.add_edges(@nodes[source],
                      @nodes[destination],
                      edge_attributes({
                                        color: "red",
                                        style: :dashed
                                      }))
    end

    def debug(msg)
      puts msg if @debug
    end
  end
end
