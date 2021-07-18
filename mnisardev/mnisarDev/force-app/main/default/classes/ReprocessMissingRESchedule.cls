global class ReprocessMissingRESchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
           reprocessRevenueEstimatesBatch reprocess= new reprocessRevenueEstimatesBatch('createMissingRE');
         database.executebatch(reprocess, 50);
    }
}