module OneApp
  class Worker
    def initialize
      @manager = JobManager.new 
    end
    def run(options = {})
      @manager.retry_expired(options)
    end    
  end
end
