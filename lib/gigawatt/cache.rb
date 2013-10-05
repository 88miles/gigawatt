module Gigawatt
  class Cache
    def initialize(settings, access_key)
      @access_key = access_key
      @settings = settings
    end

    def fetch_companies
      companies = JSON.parse(@access_key.get('/api/1/companies.json').body)
      companies["response"]
    end

    def fetch_projects
      projects = JSON.parse(@access_key.get("/api/1/projects.json?where=#{URI::encode('active="true"')}").body)
      projects["response"]
    end

    def refresh!
      @settings.companies = nil
      @settings.projects = nil
      companies
      projects
    end

    def companies(indexed = false)
      if @settings.companies.nil?
        @settings.companies = fetch_companies
        @settings.write(:companies)
      end
      return @settings.companies unless indexed
      companies = {}
      @settings.companies.each do |c|
        companies[c["uuid"]] = c
      end
      companies
    end

    def projects(indexed = false)
      if @settings.projects.nil?
        @settings.projects = fetch_projects
        @settings.write(:projects)
      end
      return @settings.projects unless indexed
      projects = {}
      @settings.projects.each do |p|
        projects[p["uuid"]] = p
      end
      projects
    end
  end
end
