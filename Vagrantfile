# -*- mode: ruby -*-

# vi: set ft=ruby :

# Ensure yaml module is loaded
require 'yaml'
require 'pp'
require 'timeout'
require 'socket'

require File.dirname(__FILE__) + '/graph.rb'
include GraphObj


class VagrantTopoError < StandardError
  def initialize(msg="Error in Vagrant topo")
    super
  end
end


def is_port_open?(host, port)
  begin
    Timeout::timeout(1) do
      begin
        s = TCPSocket.new(host, port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        return false
      end
    end
  rescue Timeout::Error
  end

  return false
end

def get_port(seed=65000, exception_list)
   (seed..65535).each do |tcp_port|
     eval_port = is_port_open?("0.0.0.0", tcp_port)
     unless eval_port
       unless (exception_list.include? tcp_port)
         return tcp_port
       end
     end
   end
   begin
     raise VagrantTopoError, "no ports available on the machine"
   rescue VagrantTopoError => e
     puts e.message
   end
end


nodes = yml_to_obj()

Vagrant.configure(2) do |config|
  port_list = []
  nodes.each do |name, nodeobj|
    config.vm.define name do |node|
      node.vm.box = nodeobj.box
      serial_ports = nodeobj.serial_ports
      serial_count = 1
      seed_host_port = 65000
      serial_ports.each do |serial_port|
        if (is_port_open?("0.0.0.0", serial_port["host_port"])) || \
           (port_list.include? serial_port["host_port"].to_i)
          serial_port["host_port"] = get_port(seed_host_port, port_list)
          seed_host_port = serial_port["host_port"] + 1
        end
        port_list.push(serial_port["host_port"].to_i)
        serial_port["uart"] = "--uart#{serial_count}"
        serial_port["uartmode"] = "--uartmode#{serial_count}"

        case serial_port["port_id"]
        when "COM1"
          serial_port["irq"] = 4
          serial_port["io_port"] = "0x3F8"
        when "COM2"
          serial_port["irq"] = 3
          serial_port["io_port"] = "0x2F8"
          serial_port["uartmode"] = "--uartmode#{serial_count}"
        else
          begin
            raise VagrantTopoError, "Invalid serial port #{serial_port['port_id']} for Virtualbox"
          rescue VagrantTopoError => e
            puts e.message
            raise e
          end
        end
        serial_count += 1     
      end


      unless nodeobj.fwd_ports.nil?
        nodeobj.fwd_ports.each do |fwd_port|
          if fwd_port["guest_port"] == 22
            fwd_port["port_id"] = "ssh" 
          end
          node.vm.network :forwarded_port, guest: fwd_port["guest_port"], host: fwd_port["host_port"], id: fwd_port["port_id"], auto_correct: fwd_port["auto_correct"] 
        end     
      end


      node.vm.provider "virtualbox" do |v|
        serial_ports.each do |serial_port|
          v.customize ["modifyvm", :id, serial_port["uart"], serial_port["io_port"], serial_port["irq"], serial_port["uartmode"], 'tcpserver', serial_port["host_port"]]
        end
      end


      intf_cnt = 0
      nodeobj.node_link_name.each do |intf_num, link_name|
          intf_cnt += 1
          link_name = nodeobj.node_link_name["#{intf_cnt}"]

          if nodeobj.node_link_type["#{intf_cnt}"] == "private_internal"
            var_str = ' node.vm.network :"private_network", virtualbox__intnet:"#{link_name}", ip: nodeobj.node_intf_ip["#{intf_cnt}"], auto_config: nodeobj.node_auto_config["#{intf_cnt}"]'
            if nodeobj.node_auto_config["#{intf_cnt}"] == "true"
              node.vm.network :"private_network", virtualbox__intnet:"#{link_name}", ip: nodeobj.node_intf_ip["#{intf_cnt}"]
            else
              node.vm.network :"private_network", virtualbox__intnet:"#{link_name}", auto_config: false
            end
          end 

          if nodeobj.node_link_type["#{intf_cnt}"] == "private_shared"
            intf_ip = nodeobj.node_intf_ip["#{intf_cnt}"]
            node.vm.network :"private_network", ip:"#{intf_ip}", auto_config: nodeobj.node_auto_config["#{intf_cnt}"] 
          end 
 
      end
    end
  end
end
