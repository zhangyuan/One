module OneApp
  class Worker
    def run
      JobManager.retry_expired 
    end    
  end
end
