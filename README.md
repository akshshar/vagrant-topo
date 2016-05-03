# vagrant-topo
Plugin to handle Topologies for Virtual Machines using a node-edge yaml representation


This is a draft version of a future plugin to handle topologies in Vagrant using a node-edge graph representation in YAML. The code works, but hasn't been coded into a plugin format yet.

To try it out, right away:

* Clone this repository: `git clone https://github.com/akshshar/vagrant-topo.git`
* Don't mess with the Vagrantfile or graph.rb. You only need to modify and share `topology.yml` files, now.
* The topology.yml file is self-describing. Take a look at the example provided. All the supported fields are provided in the example. Think of it as a graph with two sets of objects:  
  * **Nodes**:  These are the vagrant VMs in your topology. The individual charateristics such as the name, box, memory, cpu, forwarded ports, serial ports etc. are specified here.
  * **Edges**:  These are links in your topology. Each link is named and involves some relationship between the nodes. There are two types of links supported:
    * `private-internal`: These are individual links between a pair of Nodes. These nodes are uniquely identified as "headnode" and "tailnode", though direction is not a property of the link. This defaults to an internal private_network in Vagrant.
    * `private-shared`: These are private "lan" style networks with a list of nodes that have their interfaces in the same subnet. This defaults to the "host-only" network in vagrant.


Currently, only the **VirtualBox** provider is supported.
