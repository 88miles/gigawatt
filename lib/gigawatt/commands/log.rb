module Gigawatt
  module Commands
    class Log
      attr_accessor :options

      def self.run!(settings)
        options = Trollop::options do
          banner <<-EOS
88 Miles Command line application - http://88miles.net

Print out the shifts for the linked project

Usage:
  88miles log [options]

options
          EOS
          opt :page, "Page the output", :type => :flag, :default => true
        end

        instance = self.new(settings, options)
        return instance.log
      end

      def initialize(settings, options)
        @settings = settings
        @options = options

        @access_key = OAuth.token(@settings.access_key)
        @cache = Cache.new(settings, @access_key)
        @project = Gigawatt::ProjectFile.new.project
      end

      def log
        unless @project
          say("No project found.")
          return -1
        end

        $terminal.page_at = :auto if @options[:page]

        buffer = ''
        shifts = JSON.parse(@access_key.get("/api/1/projects/#{@project["uuid"]}/shifts.json").body)

        company = @cache.companies(true)[@project["company_uuid"]]
        buffer += "#{company["name"]}: #{@project["name"]} shifts:\n\n"

        total = 0
        shifts["response"].each do |shift|
          start = Time.parse(shift["start"])
          stop = Time.parse(shift["stop"] || Time.now.to_s)
          total += (stop - start)

          str = "#{start.strftime("%d/%M/%Y %H:%M:%S")}"
          str += " - #{stop.strftime("%H:%M:%S")}\t"
          str += "[#{to_clock_s(stop - start)}]\t"

          if shift["notes"].to_s == ""
            str += " No notes"
          else
            str += " #{shift["notes"]}"
          end

          if shift["stop"].nil?
            str = HighLine::String.new(str).green
          end


          buffer += str + "\n"
        end
        overdue = @project["grand_total"] > @project["time_limit"] if @project["time_limit"]
        if overdue
          buffer += "Total:                          #{HighLine::String.new("[#{to_clock_s(total)}]").red}\n"
        else
          buffer += "Total:                          [#{to_clock_s(total)}]\n"
        end
        say(buffer)
        return 0
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
