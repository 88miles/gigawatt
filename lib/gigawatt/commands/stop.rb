module Gigawatt
  module Commands
    class Stop
      attr_accessor :options

      def self.run!(settings)
        options = Trollop::options do
          banner <<-EOS
88 Miles Command line application - http://88miles.net

Punch out of the project.

Usage
  88miles stop [options]

options:
          EOS
          opt :notes, "Save notes against the shift", :type => :string
          opt :tags, "Allocate tags to the shift", :type => :string
        end

        instance = self.new(settings, options)
        begin
          return instance.punch_out
        rescue OAuth2::Error => e
          say "Access to your 88 Miles may have been revoked. Please run <%= color('88miles setup', BOLD) %> again."
          return INVALID_OAUTH_TOKEN_EXIT_CODE
        rescue Faraday::Error::ConnectionFailed => e
          say "Couldn't connect to the 88 Miles server. Please try again later."
          return CONNECTION_ERROR_EXIT_CODE
        end
      end

      def initialize(settings, options)
        @settings = settings
        @options = options

        @access_key = OAuth.token(@settings.access_key)
        @cache = Cache.new(settings, @access_key)
      end

      def punch_out
        project = Gigawatt::ProjectFile.new.project

        if project
          running_total = (Time.now.to_i - project["started_at"])
          response = JSON.parse(@access_key.post("/api/1/projects/#{project["uuid"]}/punch_out.json", { :params => { :notes => options.notes.to_s } }).body)
          current = response["response"]
          ProjectFile.write(current)

          company = @cache.companies(true)[project["company_uuid"]]
          say("Punched out of #{company["name"]}: #{project["name"]}. Shift time: #{to_clock_s(running_total, true)}.")
          return OK_EXIT_CODE
        else
          say("No project found. Did you remember to run <%= color('88miles init [directory]', BOLD) %>?")
          return NO_PROJECT_EXIT_CODE
        end
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
