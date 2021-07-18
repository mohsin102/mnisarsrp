public class projectAOITriggerHelper  {

	public static void setParentFlags(List<Project_AOI__c> triggerNew, List<Project_AOI__c> triggerOld, Map<Id, Project_AOI__c> newMap, Map<Id, Project_AOI__c> oldMap){
		
		Set<String> parentIds = new Set<String>();
		Set<String> oldParentIds = new set<String>();
		Set<String> newParentIds = new set<String>();
		Set<String> unParentIds = new Set<String>();
		System.debug(newMap);
		Map<Id, Set<String>> parentRemovals = new Map<Id, Set<String>>();
		
		//Check for removal of parent flag - previous parent will need to be checked for other children.
		if(triggerNew != null){
			for(Project_AOI__c projectAOI: triggerNew){
				//Update - need to check for parent removal 
				//Check to see if there was a previous value
				if (oldMap != null && oldMap.size() > 0){
					//Check to insure the parent field was changed.
					if(oldMap.get(projectAOI.Id).parentAOI__c != newMap.get(projectAOI.Id).parentAOI__c){
						String removeId = oldMap.get(projectAOI.Id).parentAOI__c;
						oldParentIds.add(removeId);
						if(parentRemovals.keySet().contains(removeId)){
							parentRemovals.get(removeId).add(projectAOI.Id);
						}
						else{
							Set<String> oldChildren = new Set<String>();
							oldChildren.add(projectAOI.Id);
							parentRemovals.put(removeId, oldChildren);
						}
					}
				}
				//Add new parents to parent list
				if(projectAOI.parentAOI__c != null){
					newParentIds.add(projectAOI.parentAOI__c);
					//allParentIds.add(projectAOI.parentAOI__c);
					if(newMap != null && newMap.containsKey(projectAOI.parentAOI__c)){
						newMap.get(projectAOI.parentAOI__c).isParent__c = true;
					}
					else{
						parentIds.add(projectAOI.parentAOI__c);
					}
				}
			}
		}
		//Delete Trigger handling
		if(triggerOld != null && triggerNew == null){
			for(Project_AOI__c oldProjectAOI: triggerOld){
				String removeId = oldMap.get(oldProjectAOI.Id).parentAOI__c;
				oldParentIds.add(removeId);
				if(parentRemovals.keySet().contains(removeId)){
					parentRemovals.get(removeId).add(oldProjectAOI.Id);
				}
				else{
					Set<String> oldChildren = new Set<String>();
					oldChildren.add(oldProjectAOI.Id);
					parentRemovals.put(removeId, oldChildren);
				}
			}
		}

		System.debug(parentRemovals);
		//If New Parents include any items that are included in the remove list, take out of removed lists.
		for(Id parentId: newParentIds){
			if(oldParentIds.contains(parentId)){
				oldParentIds.remove(parentId);
			}
			if(parentRemovals.containsKey(parentId)){
				parentRemovals.remove(parentId);
			}
		}

		//Create a map of all current parents with their current children
		List<Project_AOI__c> childrenProjects = new List<Project_AOI__c>();
		Map<Id, set<Id>> parentChildren = new Map<Id, set<Id>>();
		childrenProjects = [SELECT Id, parentAOI__c FROM Project_AOI__c WHERE parentAOI__c IN: oldParentIds];

		System.debug('List size is: ' + childrenProjects.size());

		for(Project_AOI__c projectAOI: childrenProjects){
			if(parentChildren.containsKey(projectAOI.parentAOI__c)){
				parentChildren.get(projectAOI.parentAOI__c).add(projectAOI.Id);
			}
			else{
				set<Id> childrenSet = new set<Id>();
				childrenSet.add(projectAOI.Id);
				parentChildren.put(projectAOI.parentAOI__c, childrenSet);
			}
		}

		//Loop through the map and check to see if all children have been removed.
		for(Id parentId: parentChildren.keySet()){
			unParentIds.add(parentId);
			for(Id childId: parentChildren.get(parentId)){
				if(parentRemovals.containsKey(parentId)){
					if(!parentRemovals.get(parentId).contains(childId)){
						unParentIds.remove(parentId);
					}
				}
			}
			//System.debug('Children size is: ' + parentChildren.get(parentId).size());
		}
		//Loop through items in trigger and modify parent flag if included in existing trigger set
		for(Id unParentId : unParentIds){	
			if(newMap != null && newMap.containsKey(unParentId)){
				newMap.get(unParentId).isParent__c = false;
				unParentIds.remove(unParentId);
			}
		}


		List<Project_AOI__c> parentProjects = new List<Project_AOI__c>() ;
		List<Project_AOI__c> unParentProjects = new List<Project_AOI__c>() ;
		List<Project_AOI__c> updateProjects = new List<Project_AOI__c>();
		//List<Project_AOI__c> allParentProjects = new List<Project_AOI__c>();
		parentProjects = [SELECT Id FROM Project_AOI__c WHERE id in :parentIds AND isParent__c = false];
		unParentProjects = [SELECT Id FROM Project_AOI__c WHERE id in :unParentIds AND isParent__c = true];
		//allParentProjects = [SELECT Id FROM Project_AOI__c WHERE id in :allParentIds];
		for(Project_AOI__c parentProject: parentProjects){
            	parentproject.isParent__c = true;
				updateProjects.add(parentProject);
		}
		for(Project_AOI__c unParentProject: unParentProjects){
            	unParentproject.isParent__c = false;
				updateProjects.add(unParentProject);
		}
		//Remove parent flags from items that are no longer parents.

		update updateProjects;
		//List<Project_AOI_Tract__c> updateAOITracts = [SELECT ID FROM Project_AOI_Tract__c WHERE projectAoi__c in :allParentProjects];
		//update updateAOITracts; 

	}

}