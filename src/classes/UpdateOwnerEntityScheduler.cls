global class UpdateOwnerEntityScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
       Set<Id> oppIds = new Set<id>();
      UpdateOwnerEntity uoeBatch = new UpdateOwnerEntity(oppIds);
      database.executeBatch(uoeBatch,10);
   }
}