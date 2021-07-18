public class updateRevenueEstimatesFromQueueable implements Queueable {  
  
    List<revenueEstimate__c> reList = new List<revenueEstimate__c>();
    public updateRevenueEstimatesFromQueueable(List<revenueEstimate__c> reList) {  
  
        this.reList = reList;
    }  
  
    public void execute(QueueableContext qc) {  
  
        update reList;  
    }  
}