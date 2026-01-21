class ManageIQ::Providers::Proxmox::Inventory::Parser::InfraManager < ManageIQ::Providers::Proxmox::Inventory::Parser
  def parse
    clusters
    hosts
    storages
    networks
    vms
  end

  def clusters
  end

  def hosts
    collector.nodes.each do |host|
      persister.hosts.build(
        :ems_ref     => host["id"],
        :uid_ems     => host["id"],
        :name        => host["node"],
        :vmm_vendor  => "proxmox",
        :vmm_product => "Proxmox VE",
        :power_state => host["status"] == "online" ? "on" : "off"
      )
    end
  end

  def storages
    collector.storages.each do |storage|
      storage_obj = persister.storages.build(
        :ems_ref => storage["id"],
        :name    => storage["storage"]
      )

      host_ref = "node/#{storage["node"]}"
      persister.host_storages.build(
        :storage => storage_obj,
        :host    => persister.hosts.lazy_find(host_ref)
      )
    end
  end

  def networks
    collector.networks.each do |network|
    end
  end

  def vms
    collector.vms.each do |vm|
      host_ref = "node/#{vm["node"]}" if vm["node"]
      template = vm["template"] == 1
      raw_power_state = template ? "never" : vm["status"]

      vm_obj = persister.vms_and_templates.build(
        :type            => "#{persister.manager.class}::#{template ? "Template" : "Vm"}",
        :ems_ref         => vm["id"],
        :uid_ems         => vm["id"],
        :name            => vm["name"],
        :template        => template,
        :raw_power_state => raw_power_state,
        :host            => persister.hosts.lazy_find(host_ref),
        :location        => "#{vm["node"]}/#{vm["vmid"]}",
        :vendor          => "proxmox"
      )
    end
  end
end
