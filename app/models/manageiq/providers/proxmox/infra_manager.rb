class ManageIQ::Providers::Proxmox::InfraManager < ManageIQ::Providers::InfraManager
  supports :create

  def self.ems_type
    @ems_type ||= "proxmox".freeze
  end

  def self.description
    @description ||= "Proxmox".freeze
  end
end
