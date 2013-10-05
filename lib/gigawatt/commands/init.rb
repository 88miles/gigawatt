module Gigawatt
  module Commands
    class Init
      attr_accessor :options

      def self.run!(settings)
        directory = nil
        p = Trollop::Parser.new
        options = p.parse
        directory = p.leftovers.first

        Trollop::die "Please supply a directory" unless directory
        Trollop::die "Directory does not exist" unless File.exists?(directory)
        Trollop::die "#{directory} is not a directory" unless File.directory?(directory)

        instance = self.new(settings, options, directory)
        instance.list_projects
        return 0
      end

      def initialize(settings, options, directory)
        @settings = settings
        @options = options
        @directory = directory
        @access_key = OAuth.token(settings.access_key)
        @cache = Cache.new(settings, @access_key)
      end

      def list_projects
        companies = @cache.companies(true)

        selected = nil
        choose do |menu|
          menu.prompt = "Pick a project"
          @cache.projects.each do |project|
            menu.choice("#{companies[project["company_uuid"]]["name"]}: #{project["name"]}") { selected = project }
          end
        end

        ProjectFile.write(selected)
        say("<%= color('#{companies[selected["company_uuid"]]["name"]}: #{selected["name"]}', GREEN) %> selected. Run <%= color('88miles start', BOLD) %> to punch in")
      end
    end
  end
end
