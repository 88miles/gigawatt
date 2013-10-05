module Gigawatt
  class OAuth
    def self.client
      client = OAuth2::Client.new('NjtVKz6Di3ccJjn2AGwZKhSxYBX4QHPJ5w1LrZOR', 'UxJrMUp9mV5AHaqXx62WuKToWk0nXxDYOgKDpQ8v', :site => 'http://localhost:3000')
    end

    def self.token(token)
      OAuth2::AccessToken.new(self.client, token)
    end
  end
end
