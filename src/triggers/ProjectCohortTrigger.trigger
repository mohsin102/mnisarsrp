/**
 * Created by Nathan.Shulman on 5/16/2019.
 */

trigger ProjectCohortTrigger on Project_Cohort__c (before insert, before update) {
    List<Project_Cohort__c> pcs = Trigger.New;
    for (Project_Cohort__c pc : pcs) {
        pc.Account_Project_Key__c = pc.Account__c + ':' + pc.Project__c;
    }
}