module OneApp
  class Config
    attr_accessor :api_key

    def initialize(hash)
      self.api_key = hash['api_key'] 
    end
  end
end
