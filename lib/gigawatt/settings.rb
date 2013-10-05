module Gigawatt
  class Settings
    attr_accessor :access_key, :projects, :companies

    def initialize(options = {})
      @options = Settings.defaults.merge(options)
      read if setup?
    end

    def self.defaults
      {
        :path => File.join(Dir.home, '.88miles')
      }
    end

    def setup?
      File.exists?(path) && File.directory?(path)
    end

    def path
      @options[:path]
    end

    def read
      self.access_key = YAML.load_file(File.join(path, 'accesskey'))
      self.companies = YAML.load_file(File.join(path, 'companies'))
      self.projects = YAML.load_file(File.join(path, 'projects'))
    end

    def write(type)
      # Make the directory if it doesn't exist
      FileUtils.mkdir_p(path) unless File.exists?(path)
      File.write(File.join(path, 'accesskey'), self.access_key.to_yaml) if type == :accesskey
      File.write(File.join(path, 'companies'), self.companies.to_yaml) if type == :companies
      File.write(File.join(path, 'projects'), self.projects.to_yaml) if type == :projects
      FileUtils.chmod 0700, path
    end
  end
end
