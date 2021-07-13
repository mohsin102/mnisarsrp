global class CDEX_CreateEnergyLinkScheduler implements Schedulable{
   global void execute(SchedulableContext SC) {
      CDEXCalloutHelper.getRecentChecks();
   }
}