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
          opt :table, "Outputs a formatted table", :type => :flag, :default => false
        end

        instance = self.new(settings, options)
        begin
          return instance.log
        rescue OAuth2::Error => e
          say "Access to your 88 Miles may have been revoked. Please run <%= color('88miles setup', BOLD) %> again."
          return INVALID_OAUTH_TOKEN_EXIT_CODE
        end
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
          return NO_PROJECT_EXIT_CODE
        end

        $terminal.page_at = :auto if @options[:page]

        if @options[:table]
          log_table
        else
          log_blob
        end
        return OK_EXIT_CODE
      end

      def log_blob
        buffer = ''
        shifts = JSON.parse(@access_key.get("/api/1/projects/#{@project["uuid"]}/shifts.json").body)

        company = @cache.companies(true)[@project["company_uuid"]]
        staff = @cache.staff(true)
        buffer += "#{company["name"]}: #{@project["name"]} shifts:\n\n"

        total = 0
        rows = []
        str = ""
        shifts["response"].each do |shift|
          staff_member = staff[shift["user_uuid"]]
          start = Time.parse(shift["start"])
          stop = Time.parse(shift["stop"] || Time.now.to_s)
          total += (stop - start)

          str += "<%= color('uuid #{shift["uuid"]}', YELLOW) %>\n"

          if staff_member
            str += "Staff:  #{staff_member["first_name"]} #{staff_member["last_name"]} <#{staff_member["email_address"]}>\n"
          else
            str += "Staff:  [Deleted user]\n"
          end

          str += "Start:  #{start.getlocal.strftime('%c %:z')}\n"
          str += "Stop:   #{stop.getlocal.strftime('%c %:z')}\n"
          str += "Total:  #{to_clock_s(stop - start)}\n"
          str += "\n\t"
          if shift["notes"].to_s == ""
            str += "No notes\n"
          else
            str += "#{shift["notes"]}\n"
          end
          str += "\n"
        end

        overdue = @project["grand_total"] > @project["time_limit"] if @project["time_limit"]
        if overdue
          str += "Total: #{HighLine::String.new(to_clock_s(total)).red}"
        else
          str += "Total: #{to_clock_s(total)}"
        end

        say(str)
      end

      def log_table
        buffer = ''
        shifts = JSON.parse(@access_key.get("/api/1/projects/#{@project["uuid"]}/shifts.json").body)

        company = @cache.companies(true)[@project["company_uuid"]]
        staff = @cache.staff(true)
        buffer += "#{company["name"]}: #{@project["name"]} shifts:\n\n"

        total = 0
        rows = []
        shifts["response"].each do |shift|
          row = []

          staff_member = staff[shift["user_uuid"]]
          start = Time.parse(shift["start"])
          stop = Time.parse(shift["stop"] || Time.now.to_s)
          total += (stop - start)

          if staff_member
            row << "#{staff_member["first_name"]} #{staff_member["last_name"]}"
          else
            row << "[Deleted user]"
          end
          row << "#{start.getlocal.strftime("%d/%M/%Y %H:%M:%S")} - #{stop.getlocal.strftime("%H:%M:%S")}"
          row << "#{to_clock_s(stop - start)}"

          if shift["notes"].to_s == ""
            row << " No notes"
          else
            row << " #{shift["notes"]}"
          end

          if shift["stop"].nil?
            row = row.map{ |col| HighLine::String.new(col).green }
          end
          rows << row
        end

        rows << :separator
        overdue = @project["grand_total"] > @project["time_limit"] if @project["time_limit"]
        if overdue
          rows << [ 'Total', '', HighLine::String.new(to_clock_s(total)).red, '' ]
        else
          rows << [ 'Total', '', to_clock_s(total), '' ]
        end

        say(Terminal::Table.new(:rows => rows).to_s) if @options[:table]
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
