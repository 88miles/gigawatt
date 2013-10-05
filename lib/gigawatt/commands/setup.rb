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
          return -1
        end

        instance.preamble

        if !instance.authenticate
          puts "Invalid login or password"
          return -2
        end
        instance.postamble

        return 0
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
        say("Please enter your login and password below. Please note: this utility does not store your login or password.")
      end

      def postamble
        say("Thank you. We can now access your account. You can now initialize a directory by running <%= color('88miles init [directory]', BOLD) %>")
      end

      def authenticate
        login = ask("Login: ")
        password = ask("Password: ") { |q| q.echo = "*" }

        client = Gigawatt::OAuth.client

        begin
          @access_key = client.password.get_token(login, password)
        rescue OAuth2::Error
          return false
        end

        @settings.access_key = @access_key.token

        cache = Gigawatt::Cache.new(@settings, @access_key)
        @settings.companies = cache.companies
        @settings.projects = cache.projects

        @settings.write(:accesskey)
        @access_key.token
      end
    end
  end
end
