public with sharing class TitleWorkJobUpdateModalAura  {

	@AuraEnabled
	public static List<LookupSearchResult> searchOwners(String searchTerm, List<String> selectedIds){
		System.debug('Trying to get search results.');
		return lookupUtility.searchOwners(searchTerm, selectedIds, 'TitleWorkJob__c');
	}

	@AuraEnabled 
    public static List<LookupSearchResult> fetchOwner(Id ownerId){
		//String ownerType = String.valueOf(ownerId.getSobjectType().getDescribe().getName());
		switch on ownerId.getSobjectType().getDescribe().getName(){
			when 'User'{
				String ltIcon = 'standard:user';
				User u = [select id,Name from User where id =: ownerId];
				List<LookupSearchResult> results = new List<LookupSearchResult>();
				results.add(new LookupSearchResult(u.Id, 'User', ltIcon, u.Name, 'User'));
				return results;
			}
			when 'Group'{
				String ltIcon = 'standard:queue';
				Group g = [select id,Name from Group where id =: ownerId];
				List<LookupSearchResult> results = new List<LookupSearchResult>();
				results.add(new LookupSearchResult(g.Id, 'Queue', ltIcon, g.Name, 'Queue'));
				return results;
			}
			when else{
				return null;
			}
		}

    }

}