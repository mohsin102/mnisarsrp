public with sharing class GridLookupController {
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled
    public static Boolean linkTract(Id selectedId, Id parentId) {
        // Links a LandGridTract to a Tract based on the ID of the LandGridTract (selectedId) and Tract (parentId)
        Tract__c selTract = [SELECT Id,Name from Tract__c where Id = :parentId];
        selTract.LandGridTract__c = selectedId;
        update selTract;
        return true;
    }

    //If the term starts with the selected value, return true
    private static Boolean hasTerm(String term, String value)
    {
        return (term.left(value.length()).toLowerCase() == value.toLowerCase());
    }

    @AuraEnabled
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare query parameters
        List<String> terms = searchTerm.split('\\s');
        List<String> newTerms = new List<String>();
        Map<String,String> aliasList = new Map<String,String>();

		for(String term : terms)		
        {
            // Aliases

            if (hasTerm(term,'tex'))
            {
                newTerms.add('(*TX* OR *' + term + '*)');
            }
            else if (hasTerm(term,'arka'))
            {
                newTerms.add('(*AR* OR *' + term + '*)');
            }
            else if (hasTerm(term,'colo'))
            {
                newTerms.add('(*CO* OR *' + term + '*)');
            }
            else if (hasTerm(term,'monta'))
            {
                newTerms.add('(*MT* OR *' + term + '*)');
            }
            else if (hasTerm(term,'kans'))
            {
                newTerms.add('(*KS* OR *' + term + '*)');
            }
            else if (hasTerm(term,'new') || hasTerm(term,'mexi'))
            {
                newTerms.add('(*NM* OR *' + term + '*)');
            }
            else if (hasTerm(term,'louis'))
            {
                newTerms.add('(*LA* OR *' + term + '*)');
            }
            else if (hasTerm(term,'wyo'))
            {
                newTerms.add('(*WY* OR *' + term + '*)');
            }
            else
            {
                newTerms.add('*' + term + '*');
            }
        }

        String newTerm = String.join(newTerms,' AND ');
        System.debug('newTerm: ' + newTerm);
        Datetime qryStart = Datetime.now();
        
        List<List<SObject>> searchResults = [FIND :newTerm IN Name fields Returning Landgridtract__c(Id,Name,County__c,RecordType.Name,Section__c,Block__c)LIMIT 10];
        System.debug('Result size: ' + searchResults.size());
        
        Datetime qryEnd = Datetime.now();
        
        System.debug(LoggingLevel.WARN, 'Result time: ' + (qryEnd.getTime() - qryStart.getTime()) + 'ms');
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Land Grid Tracts & convert them into LookupSearchResult
        LandGridTract__c [] tracts = ((List<LandGridTract__c>) searchResults[0]);
        for (LandGridTract__c lt : tracts) {
            String ltIcon = 'custom:custom12';
            String blockSectionInfo = '';
                if (lt.RecordType.Name.contains('Abstract'))
                {
                    if (lt.Block__c != null ) {
                        blockSectionInfo = ' <strong>Block:</strong> ' + lt.Block__c;
                    }
                    if (lt.Section__c != null) {
                        blockSectionInfo += ' <strong>Section:</strong> ' + lt.Section__c;
                    }
                    ltIcon = 'custom:custom6';
                }
                else if (lt.RecordType.Name.contains('Section'))
                {
                    if (lt.Block__c != null) {
                        blockSectionInfo = ' <strong>Block:</strong> ' + lt.Block__c;
                    }
                    if (lt.Section__c != null) {
                        blockSectionInfo += ' <strong>Section:</strong> ' + lt.Section__c;
                    }

                    ltIcon = 'custom:custom7';
                }
            else if (lt.RecordType.Name.contains('Parcel'))
                {
                    ltIcon = 'custom:custom8';
                }
            System.debug('tract found: '+lt.Name);
            results.add(new LookupSearchResult(lt.Id, 'Land Grid Tract', ltIcon, lt.Name, '<strong>Type:</strong> '+ lt.RecordType.Name + blockSectionInfo));
        }

        // Extract Opportunities & convert them into LookupSearchResult
        /*String opptyIcon = 'standard:opportunity';
        Opportunity [] opptys = ((List<Opportunity>) searchResults[1]);
        for (Opportunity oppty : opptys) {
            results.add(new LookupSearchResult(oppty.Id, 'Opportunity', opptyIcon, oppty.Name, 'Opportunity • '+ oppty.StageName));
        }*/

        return results;
    }

}