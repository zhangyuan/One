module OneApp
  class Job
    attr_accessor :name, :params, :expires_at

    def initialize(attrs)
      self.name = attrs[:name] || attrs['name']   
      self.params = attrs[:params] || attrs['params']
    end

    def to_json
      attrs = {
        name: name,
        params: params,
        expires_at: expires_at
      } 
      MultiJson.encode(attrs)
    end

    def self.from_json(json)
      attrs = MultiJson.decode(json) 
      new(attrs)
    end
  end
end
