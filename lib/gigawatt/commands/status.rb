module Gigawatt
  module Commands
    class Status
      attr_accessor :options

      def self.run!(settings)
        options = Trollop::options do
          banner <<-EOS
88 Miles Command line application - http://88miles.net

Get status about the linked project

Usage:
  88miles status [options]

options:
          EOS

          opt :sync, "Sync the data from the server first. Uses the cache if false", :type => :flag
          opt :foreground, "Don't exit - just refresh the timer", :type => :flag
          opt :time, "Only return the time", :type => :flag
        end

        instance = self.new(settings, options)
        return instance.get_settings
      end

      def initialize(settings, options)
        @settings = settings
        @options = options

        @access_key = OAuth.token(@settings.access_key)
        @cache = Cache.new(settings, @access_key)

        @project = Gigawatt::ProjectFile.new.project
      end

      def get_settings
        unless @project
          say("No project found.")
          return -1
        end

        if @options[:sync]
          sync = Gigawatt::Commands::Sync.new(@settings, @options)
          sync.sync
          sync.sync_current
        end

        if @options[:foreground]
          while(1)
            print_status
            sleep(1)
          end
          print "\n"
        else
          print_status
          print "\n"
        end

        return 0
      end

      def print_status
        company = @cache.companies(true)[@project["company_uuid"]]

        grand_total = @project["grand_total"]
        grand_total += (Time.now.to_i - @project["started_at"]) if @project["running"]
        overdue = grand_total > @project["time_limit"] if @project["time_limit"]

        clock_string = to_clock_s(grand_total, true)
        clock_string = " [#{HighLine::String.new(clock_string).red}]" if overdue

        str = ""
        if @options[:time]
           str = clock_string
        else
          str += "#{company["name"]}: #{@project["name"]}"
          str += " [#{clock_string}]"
          str += " #{HighLine::String.new("Running").green}" if @project["running"]
        end

        print "\e[0K\r#{str}" if @options[:foreground]
        print str unless @options[:foreground]
      end

      def to_clock_s(time, show_seconds = false)
        hour = (time.abs / 3600).floor
        minute = (time.abs / 60 % 60).floor
        seconds = (time.abs % 60).floor if show_seconds

        return (time != 0 && (time / time.abs) == -1 ? "-" : "") + hour.to_s.rjust(2, '0') + ":" + minute.to_s.rjust(2, '0') + (show_seconds ? ":" + seconds.to_s.rjust(2, '0') : '')
      end
    end
  end
end
