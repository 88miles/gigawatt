module Gigawatt
  module Commands
    class Sync
      attr_accessor :options

      def self.run!(settings)
        options = Trollop::options do
          banner <<-EOS
88 Miles Command line application - http://88miles.net

88 Miles caches your company and project list to speed things up. Run this command if you add, edit or remove companies or projects

If run inside a directory with a linked project, the linked project will be updated too

Usage
  88miles sync
        EOS
        end

        instance = self.new(settings, options)
        begin
          instance.sync
          instance.sync_current
        rescue OAuth2::Error => e
          say "Access to your 88 Miles may have been revoked. Please run <%= color('88miles setup', BOLD) %> again."
          return INVALID_OAUTH_TOKEN_EXIT_CODE
        end

        return 0
      end

      def initialize(settings, options)
        @settings = settings
        @options = options

        @access_key = OAuth.token(@settings.access_key)
        @cache = Cache.new(settings, @access_key)
      end

      def sync
        @cache.refresh!
      end

      def sync_current
        project = Gigawatt::ProjectFile.new.project
        if project
          response = JSON.parse(@access_key.get("/api/1/projects/#{project["uuid"]}.json").body)
          ProjectFile.write(response["response"])
        end
      end
    end
  end
end
