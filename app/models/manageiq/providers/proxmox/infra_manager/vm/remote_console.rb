module ManageIQ::Providers::Proxmox::InfraManager::Vm::RemoteConsole
  extend ActiveSupport::Concern

  def console_supported?(type)
    %w[html5 vnc].include?(type.to_s.downcase)
  end

  def validate_remote_console_acquire_ticket(protocol, options = {})
    raise MiqException::RemoteConsoleNotSupportedError, "#{protocol} remote console requires the vm to be registered with a management system" if ext_management_system.nil?

    options[:check_if_running] = true unless options.key?(:check_if_running)
    raise MiqException::RemoteConsoleNotSupportedError, "#{protocol} remote console requires the vm to be running" if options[:check_if_running] && state != "on"
  end

  def remote_console_acquire_ticket(userid, originating_server, protocol)
    validate_remote_console_acquire_ticket(protocol)
    protocol = protocol.to_s == 'html5' ? 'vnc' : protocol.to_s
    ext_management_system.remote_console_acquire_ticket(self, userid, originating_server, protocol)
  end

  def remote_console_acquire_ticket_queue(protocol, userid)
    task_opts = {
      :action => "Acquire Remote Console Ticket for #{name}",
      :userid => userid
    }

    queue_opts = {
      :class_name  => self.class.name,
      :instance_id => id,
      :method_name => 'remote_console_acquire_ticket',
      :priority    => MiqQueue::HIGH_PRIORITY,
      :role        => 'ems_operations',
      :zone        => my_zone,
      :args        => [userid, MiqServer.my_server.id, protocol]
    }

    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def native_console_connection(userid, originating_server, protocol)
    validate_remote_console_acquire_ticket(protocol, :check_if_running => false)
    protocol = protocol.to_s == 'html5' ? 'vnc' : protocol.to_s
    ext_management_system.native_console_connection(self, userid, originating_server, protocol)
  end
end
