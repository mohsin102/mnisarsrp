public with sharing class Util {

    // Generic utilities designed to make life easier
    // Given a list of objects, return the set of unique IDs.
    public static Set<Id> getIds(List<sObject> objects) {
        Set<Id> resultIds = new Set<Id> (new Map<Id,SObject>(objects).keySet());
        return  resultIds;
    }
}