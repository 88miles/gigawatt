module Gigawatt
  class ProjectFile
    def find_the_dotfile(dir = Dir.pwd)
      file = File.join(dir, ProjectFile.filename)
      if File.exists?(file)
        return File.join(file)
      else
        parts = dir.split(File::SEPARATOR)[0..-2]
        if parts.length == 0
          return nil
        else
          return find_the_dotfile(File.join(parts))
        end
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
