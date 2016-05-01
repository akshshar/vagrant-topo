module GraphObj
  class Nodes
    attr_accessor :name, :mem, :cpus, :box, :fwd_ports, :serial_ports, :node_link_name, :node_link_type, :node_intf_ip, :node_auto_config
    def initialize(node_specs={})
      node_specs.each { |k,v| instance_variable_set("@#{k}", v) }
      @node_link_name = {}
      @node_link_type = {}
      @node_intf_ip = {}
      @node_auto_config = {}
    end
  end

# Read yaml topology definitions to create a graph object

  def yml_to_obj
    graph = YAML.load_file(File.join(__dir__,'topology.yml'))
    node_specs = graph["nodes"]
    edges = graph["edges"]

    nodes = {}
    node_specs.each do |node_spec|
      nodes["#{node_spec["name"]}"] =   Nodes.new(node_spec)
    end 

    link_nodes = ["headnode", "tailnode"]
    edges.each do |edge|
      link_nodes.each do |link_node| 
        if edge["type"] == "private_internal"
          nodes["#{edge[link_node]["name"]}"].node_link_name["#{edge[link_node]["interface"]}"] = edge["name"]
          nodes["#{edge[link_node]["name"]}"].node_link_type["#{edge[link_node]["interface"]}"] = edge["type"]
          if not edge[link_node].key?("ip")
            nodes["#{edge[link_node]["name"]}"].node_auto_config["#{edge[link_node]["interface"]}"] = "false"
            nodes["#{edge[link_node]["name"]}"].node_intf_ip["#{edge[link_node]["interface"]}"] = ""
          else
            nodes["#{edge[link_node]["name"]}"].node_auto_config["#{edge[link_node]["interface"]}"] = "true" 
            nodes["#{edge[link_node]["name"]}"].node_intf_ip["#{edge[link_node]["interface"]}"] = edge[link_node]["ip"]    
          end
        end 
      end

      if edge["type"] == "private_shared"
        edge["nodes"].each do |shared_node|
            nodes["#{shared_node["name"]}"].node_link_name["#{shared_node["interface"]}"] = edge["name"]
            nodes["#{shared_node["name"]}"].node_link_type["#{shared_node["interface"]}"] = edge["type"]
            unless defined?(shared_node["ip"]).nil?
              nodes["#{shared_node["name"]}"].node_intf_ip["#{shared_node["interface"]}"] = shared_node["ip"]
              nodes["#{shared_node["name"]}"].node_auto_config["#{shared_node["interface"]}"] = "true" 
           end
        end
      end
    end

    return nodes
  end
end
