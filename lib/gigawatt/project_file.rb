module Gigawatt
  class ProjectFile
    def find_the_dotfile(dir = Dir.pwd)
      file = File.join(dir, ProjectFile.filename)
      if File.exists?(file)
        return File.join(file)
      else

      end
    end

    def project
      dotfile = find_the_dotfile
      if dotfile
        YAML.load_file(dotfile)
      else
        nil
      end
    end

    def self.write(project)
      File.write(File.join(Dir.pwd, ProjectFile.filename), project.to_hash.to_yaml)
    end

    def self.filename
      ".88miles"
    end
  end
end
