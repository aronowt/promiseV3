public class Chain implements Finalizer {
  Promise[] promises;
  Object passthrough;

  public Chain(Promise[] promises, Object passthrough){
    this.promises = promises;
    this.passthrough = passthrough;
  }

  public void execute(FinalizerContext context){
    Id parentQueueableJobId = context.getAsyncApexJobId();
    switch on context.getAsyncApexJobResult() {
      when SUCCESS {
        if(this.promises.size() > 0){
          Promise next = this.promises.remove(0);
          next.promises = this.promises;
          next.passthrough = passthrough;
          System.enqueueJob(next);
        }
      }
      when UNHANDLED_EXCEPTION {
        System.Debug('Parent Queueable (Job ID: ' + parentQueueableJobId + '): FAILED!');
        System.Debug('Parent Queueable Exception: ' + context.getAsyncApexJobException().getMessage());
      }
    }    
  }
}