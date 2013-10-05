module Gigawatt
  class Application
    def self.run!
      trap("SIGINT") { puts " "; exit! }
      Options.parse!
    end
  end
end
