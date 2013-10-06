module Gigawatt
  class OAuth
    def self.client
      if ENV['ENV'] == 'development'
        client = OAuth2::Client.new('NjtVKz6Di3ccJjn2AGwZKhSxYBX4QHPJ5w1LrZOR', nil, :site => 'http://localhost:3000')
      else
        client = OAuth2::Client.new('hhWZrEF6YTlPUKrggiesnjXAFViLa8FBZNNUtr8L', nil, :site => 'https://88miles.net')
      end
    end

    def self.token(token)
      OAuth2::AccessToken.new(self.client, token)
    end

    def self.redirect_uri
      if ENV['ENV'] == 'development'
        "http://localhost:3000/oauth/authorized"
      else
        "https://88miles.net/oauth/authorized"
      end
    end
  end
end
