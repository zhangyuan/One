module OneApp
  class Job
    attr_accessor :name, :params, :expires_at, :created_at, :retry_times

    def initialize(attrs)
      self.name = attrs[:name] || attrs['name']   
      self.params = attrs[:params] || attrs['params']
      self.created_at = attrs[:created_at] || attrs['created_at']
      self.expires_at = attrs[:expires_at] || attrs['expires_at']
      self.retry_times = attrs[:retry_times] || attrs['retry_times'] || 0
    end

    def to_json
      attrs = {
        name: name,
        params: params,
        expires_at: expires_at,
        created_at: created_at,
        retry_times: self.retry_times
      } 
      MultiJson.encode(attrs)
    end

    def self.from_json(json)
      attrs = MultiJson.decode(json) 
      new(attrs)
    end
  end
end
