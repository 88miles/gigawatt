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
          response = JSON.parse(@access_key.post("/api/1/projects/#{project["uuid"]}/punch_out.json", { :params => { :notes => options.notes.to_s } }).body)
          current = response["response"]
          ProjectFile.write(current)

          company = @cache.companies(true)[project["company_uuid"]]
          say("Punched out of #{company["name"]}: #{project["name"]}")
          return OK_EXIT_CODE
        else
          say("No project found. Did you remember to run <%= color('88miles init [directory]', BOLD) %>?")
          return NO_PROJECT_EXIT_CODE
        end
      end
    end
  end
end
