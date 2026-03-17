describe ManageIQ::Providers::Proxmox::InfraManager::Vm do
  let(:ems)  { FactoryBot.create(:ems_proxmox) }
  let(:host) { FactoryBot.create(:host_proxmox, :ext_management_system => ems) }
  let(:vm)   { FactoryBot.create(:vm_proxmox, :ext_management_system => ems, :host => host) }

  let(:power_state_on)        { "running" }
  let(:power_state_off)       { "stopped" }
  let(:power_state_suspended) { "suspended" }
  let(:power_state_paused)    { "paused" }

  describe "#supports?(:shutdown_guest)" do
    context "when powered off" do
      before { vm.update(:raw_power_state => power_state_off) }

      it "is not available" do
        expect(vm.supports?(:shutdown_guest)).to be false
        expect(vm.unsupported_reason(:shutdown_guest)).to include("not powered on")
      end
    end

    context "when powered on" do
      before { vm.update(:raw_power_state => power_state_on) }

      it "is not available if QEMU agent is not running" do
        vm.update(:tools_status => "toolsNotRunning")
        expect(vm.supports?(:shutdown_guest)).to be false
        expect(vm.unsupported_reason(:shutdown_guest)).to include("agent is not running")
      end

      it "is not available if QEMU agent is not installed" do
        vm.update(:tools_status => "toolsNotInstalled")
        expect(vm.supports?(:shutdown_guest)).to be false
        expect(vm.unsupported_reason(:shutdown_guest)).to include("agent is not running")
      end

      it "is available if QEMU agent is running" do
        vm.update(:tools_status => "toolsOk")
        expect(vm.supports?(:shutdown_guest)).to be true
      end
    end
  end

  describe "#supports?(:reboot_guest)" do
    context "when powered off" do
      before { vm.update(:raw_power_state => power_state_off) }

      it "is not available" do
        expect(vm.supports?(:reboot_guest)).to be false
        expect(vm.unsupported_reason(:reboot_guest)).to include("not powered on")
      end
    end

    context "when suspended" do
      before { vm.update(:raw_power_state => power_state_suspended) }

      it "is not available" do
        expect(vm.supports?(:reboot_guest)).to be false
        expect(vm.unsupported_reason(:reboot_guest)).to include("not powered on")
      end
    end

    context "when powered on" do
      before { vm.update(:raw_power_state => power_state_on) }

      it "is not available if QEMU agent is not running" do
        vm.update(:tools_status => "toolsNotRunning")
        expect(vm.supports?(:reboot_guest)).to be false
        expect(vm.unsupported_reason(:reboot_guest)).to include("agent is not running")
      end

      it "is not available if QEMU agent is not installed" do
        vm.update(:tools_status => "toolsNotInstalled")
        expect(vm.supports?(:reboot_guest)).to be false
        expect(vm.unsupported_reason(:reboot_guest)).to include("agent is not running")
      end

      it "is available if QEMU agent is running" do
        vm.update(:tools_status => "toolsOk")
        expect(vm.supports?(:reboot_guest)).to be true
      end
    end
  end

  describe "#supports?(:reset)" do
    context "when powered off" do
      before { vm.update(:raw_power_state => power_state_off) }

      it "is not available" do
        expect(vm.supports?(:reset)).to be false
        expect(vm.unsupported_reason(:reset)).to include("not powered on")
      end
    end

    context "when powered on" do
      before { vm.update(:raw_power_state => power_state_on) }

      it "is available without QEMU agent" do
        vm.update(:tools_status => "toolsNotInstalled")
        expect(vm.supports?(:reset)).to be true
      end

      it "is available with QEMU agent" do
        vm.update(:tools_status => "toolsOk")
        expect(vm.supports?(:reset)).to be true
      end
    end
  end

  describe "#supports?(:terminate)" do
    context "when powered on" do
      before { vm.update(:raw_power_state => power_state_on) }

      it "is not available" do
        expect(vm.supports?(:terminate)).to be false
        expect(vm.unsupported_reason(:terminate)).to include("not powered off")
      end
    end

    context "when suspended" do
      before { vm.update(:raw_power_state => power_state_suspended) }

      it "is not available" do
        expect(vm.supports?(:terminate)).to be false
        expect(vm.unsupported_reason(:terminate)).to include("not powered off")
      end
    end

    context "when powered off" do
      before { vm.update(:raw_power_state => power_state_off) }

      it "is available when connected to a provider" do
        expect(vm.supports?(:terminate)).to be true
      end
    end

    context "when not connected to a provider" do
      let(:archived_vm) { FactoryBot.create(:vm_proxmox, :host => host) }

      it "is not available" do
        expect(archived_vm.supports?(:terminate)).to be false
        expect(archived_vm.unsupported_reason(:terminate)).to include("not connected to an active Provider")
      end
    end
  end
end
