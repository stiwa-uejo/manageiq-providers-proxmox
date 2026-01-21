describe ManageIQ::Providers::Proxmox::InfraManager::Refresher do
  include Spec::Support::EmsRefreshHelper

  let(:ems) { FactoryBot.create(:ems_proxmox_with_vcr_authentication) }

  describe ".refresh" do
    context "full-refresh" do
      it "performs a full refresh" do
        with_vcr do
          described_class.refresh([ems])
        end

        assert_counts
        assert_ems_counts
        assert_specific_host
        assert_specific_vm
        assert_specific_template
      end
    end
  end

  def assert_counts
    expect(Vm.count).to          eq(1)
    expect(MiqTemplate.count).to eq(1)
    expect(Host.count).to        eq(1)
    expect(Storage.count).to     eq(2)
  end

  def assert_ems_counts
    expect(ems.vms.count).to           eq(1)
    expect(ems.miq_templates.count).to eq(1)
    expect(ems.hosts.count).to         eq(1)
    expect(ems.storages.count).to      eq(2)
  end

  def assert_specific_host
    host = ems.hosts.find_by(:ems_ref => "node/pve")
    expect(host).to have_attributes(
      :name            => "pve",
      :vmm_vendor      => "proxmox",
      :vmm_version     => nil,
      :vmm_product     => "Proxmox VE",
      :vmm_buildnumber => nil,
      :power_state     => "on",
      :uid_ems         => "node/pve",
      :ems_ref         => "node/pve"
    )
  end

  def assert_specific_vm
    vm = ems.vms.find_by(:ems_ref => "qemu/100")
    expect(vm).to have_attributes(
      :vendor          => "proxmox",
      :name            => "vm-test",
      :location        => "pve/100",
      :host            => ems.hosts.find_by(:ems_ref => "node/pve"),
      :uid_ems         => "qemu/100",
      :ems_ref         => "qemu/100",
      :power_state     => "off",
      :raw_power_state => "stopped"
    )
  end

  def assert_specific_template
    template = ems.miq_templates.find_by(:ems_ref => "qemu/101")
    expect(template).to have_attributes(
      :vendor          => "proxmox",
      :name            => "vm-template",
      :location        => "pve/101",
      :host            => ems.hosts.find_by(:ems_ref => "node/pve"),
      :uid_ems         => "qemu/101",
      :ems_ref         => "qemu/101",
      :power_state     => "never",
      :raw_power_state => "never"
    )
  end
end
