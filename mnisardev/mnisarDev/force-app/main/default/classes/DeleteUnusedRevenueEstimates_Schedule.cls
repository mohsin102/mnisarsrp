global with sharing class DeleteUnusedRevenueEstimates_Schedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        DeleteUnusedRevenueEstimates_Batch batchInstance = new DeleteUnusedRevenueEstimates_Batch();
        Database.executeBatch(batchInstance,1000);
    }
}