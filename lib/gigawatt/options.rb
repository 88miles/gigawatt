module Gigawatt
  class Options
    SUB_COMMANDS = %w(setup init start stop sync status)

    def self.parse!
      version_string = File.read(File.join(File.dirname(__FILE__), '..', '..', 'VERSION')).strip

      options = Trollop::options do
        version "88miles #{version_string}"
        stop_on SUB_COMMANDS
        banner <<-EOS
88 Miles Command line application - http://88miles.net

Usage:
  88miles [globaloptions] <subcommand> [options]

subcommands:
  setup: Link your 88 Miles account to this program
  init:  Link a project to a directory
  start: Punch in to the linked project
  stop:  Punch out of the linked project
  sync:  Refresh the local cache from the server

globaloptions:
        EOS
        opt :settings, "Path to store 88 Miles settings", :default => Settings.defaults[:path], :type => :string
      end

      settings = Settings.new(options)
      cmd = ARGV.shift.strip
      case cmd
      when "setup"
        Gigawatt::Commands::Setup.run!(settings)
      when "init"
        Gigawatt::Commands::Init.run!(settings)
      when "start"
        Gigawatt::Commands::Start.run!(settings)
      when "stop"
        Gigawatt::Commands::Stop.run!(settings)
      when "sync"
        Gigawatt::Commands::Sync.run!(settings)
      when "status"
        Gigawatt::Commands::Status.run!(settings)
      else
        Trollop::die "Unknown subcommand #{cmd.inspect}"
      end
    end
  end
end
