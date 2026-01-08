if ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

Dir[Rails.root.join("spec/shared/**/*.rb")].sort.each { |f| require f }
Dir[File.join(__dir__, "support/**/*.rb")].sort.each { |f| require f }

require "manageiq/providers/proxmox"

VCR.configure do |config|
  config.cassette_library_dir = File.join(ManageIQ::Providers::Proxmox::Engine.root, 'spec/vcr_cassettes')

  VcrSecrets.define_all_cassette_placeholders(config, :proxmox)
end
