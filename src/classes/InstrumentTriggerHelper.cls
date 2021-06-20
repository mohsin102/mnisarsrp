public with sharing class InstrumentTriggerHelper {

    public static boolean preventDelete(Map<Id,Instrument__c> oldMap) {
        boolean result = false;
		List<Subtract__c> sts  = [SELECT Id,Instrument__c FROM Subtract__c WHERE Instrument__c IN: oldMap.keySet()];
        Map<Id,Boolean> hasSubtract = new Map<Id,Boolean>();
        for (Subtract__c st : sts) {
            if (!hasSubtract.containsKey(st.Instrument__c))
            {
                hasSubtract.put(st.Instrument__c,true);
                oldMap.get(st.Instrument__c).addError('Cannot delete an instrument with Subtracts');
				result = true;
            }
        }
		return result;
    }

}