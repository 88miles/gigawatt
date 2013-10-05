module Gigawatt
  module Commands
    class Start
      attr_accessor :options

      def self.run!(settings)
        options = Trollop::options do
          banner <<-EOS
88 Miles Command line application - http://88miles.net

Punch into the project.

Usage
  88miles start [options]

options:
          EOS


          opt :activity, "Select an activity", :type => :flag
        end

        instance = self.new(settings, options)
        instance.punch_in
        return 0
      end

      def initialize(settings, options)
        @settings = settings
        @options = options

        @access_key = OAuth.token(@settings.access_key)
        @cache = Cache.new(settings, @access_key)
      end

      def select_activity(project)
        return nil unless options[:activity]
        return nil unless project["activities"]

        selected = nil
        choose do |menu|
          menu.prompt = "Pick an Activity"
          project["activities"].each do |activity|
            menu.choice("#{activity["name"]}") { selected = activity }
          end
        end
        selected
      end

      def punch_in
        project = Gigawatt::ProjectFile.new.project

        if project
          activity = select_activity(project)
          opts = {}
          opts = { :body => { :activity_uuid => activity["uuid"] } } if activity
          response = JSON.parse(@access_key.post("/api/1/projects/#{project["uuid"]}/punch_in.json", opts).body)
          current = response["response"]
          ProjectFile.write(current)

          company = @cache.companies(true)[project["company_uuid"]]
          say("Punched in to #{company["name"]}: #{project["name"]}")
        else
          say("No project found. Did you remember to run <%= color('88miles init [directory]', BOLD) %>?")
        end
      end
    end
  end
end
