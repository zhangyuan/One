module OneApp
  class Worker
    def initialize
      @manager = JobManager.new 
    end
    def run
      @manager.retry_expired 
    end    
  end
end
