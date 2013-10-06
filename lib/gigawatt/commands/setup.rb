module Gigawatt
  module Commands
    class Setup
      attr_accessor :options

      def self.run!(settings)
        options = Trollop::options do
          banner <<-EOS
88 Miles Command line application - http://88miles.net

This command will request an access token, giving the command line utility access to your 88 Miles account.

To do this, you will be asked for your 88 Miles login and password. Please note that the login and password will not be saved.

Usage
  88miles setup [options]

options:
          EOS
          opt :force, "Override existing settings", :default => false, :type => :boolean
        end

        instance = self.new(settings, options)

        if instance.settings_exists?
          puts "The settings file #{instance.settings.path} already exists. Use --force to overwrite"
          return SETTINGS_FILE_EXISTS
        end

        instance.preamble

        begin
          instance.authenticate
        rescue OAuth2::Error => e
          puts "There was an issue authenticating your account. Please try again."
          return INVALID_OAUTH_TOKEN_EXIT_CODE
        end
        instance.postamble

        return OK_EXIT_CODE
      end

      def initialize(settings, options)
        @options = options
        @settings = settings
      end

      def settings
        @settings
      end

      def settings_exists?
        return false if options[:force]
        @settings.setup?
      end

      def preamble
        say("88 Miles command line utility setup")
        say("-----------------------------------")
        say("To setup the 88 Miles command line utility, we need to authenticate you and request an access token.")
        say("We will open a browser, where you will be asked to login and approve access to this app.")
      end

      def postamble
        say("Thank you. We can now access your account. You can now initialize a directory by running <%= color('88miles init [directory]', BOLD) %>")
      end

      def get_access_key(url)
        uri = URI(url)
        token = uri.fragment.split('&').map{ |kv| kv.split('=') }.delete_if{ |kv| kv[0] != 'access_token' }.first
        return token[1] if token
        return nil
      end

      def authenticate
        client = Gigawatt::OAuth.client

        redirect_uri = Gigawatt::OAuth.redirect_uri
        url = client.auth_code.authorize_url(:response_type => 'token', :redirect_uri => redirect_uri)

        Launchy.open(url) do |exception|
          say "Couldn't open a browser. Please paste the following URL into a browser"
          say url
        end

        say("After you have completed the approval process, cut and paste the URL you are redirected to.")
        access_key = get_access_key(ask("URL: ") do |url|
          url.validate = /\A#{redirect_uri}#access_token=.+&state=\Z/
          url.responses[:not_valid] = "That URL doesn't look right. It should look like: #{redirect_uri}#access_token=[some characters]&state="
        end)

        @settings.access_key = access_key
        @access_key = OAuth.token(access_key)

        cache = Gigawatt::Cache.new(@settings, @access_key)

        cache.refresh!

        @settings.companies = cache.companies
        @settings.projects = cache.projects

        @settings.write(:accesskey)
        @access_key.token
      end
    end
  end
end
