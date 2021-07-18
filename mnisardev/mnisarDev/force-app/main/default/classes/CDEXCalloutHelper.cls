public class CDEXCalloutHelper{

    public static CdexParser cdex;
	@future(callout=true)
    public static void getRecentChecks(){
        
        CDEXConfiguration__mdt c = [Select EndpointURL__c,Token__c from CDEXConfiguration__mdt  limit 1];
        List<energyLinkBucket__c> energyLinkBucketList = new List<energyLinkBucket__c>();
        energyLinkBucket__c energyLinkBucketRec;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(c.EndpointURL__c+'energy_link/queries/checks');
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Accept-Encoding', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+c.Token__c);
		request.setTimeout(60000);
        
         //Set the body as a JSON object
        String bodyStr = String.valueof(Date.valueOf(system.today().addDays(-1)))+'T00:00:00Z';
        //request.setBody('{"from": "'+bodyStr+'"}');
        
        request.setBody('{"from": "2016-05-01T00:00:00Z"}');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            EnergyLinkPostResponseWrapper responseList = new EnergyLinkPostResponseWrapper();
            responseList = EnergyLinkPostResponseWrapper.parse(response.getBody());

            for(EnergyLinkPostResponseWrapper.Results res : responseList.results){
                energyLinkBucketRec = new energyLinkBucket__c(checkUrl__c = res.url);
                energyLinkBucketList.add(energyLinkBucketRec);
            }
            if(energyLinkBucketList.size()>0){
                Database.upsert( energyLinkBucketList, energyLinkBucket__c.checkUrl__c.getDescribe().getSObjectField() ,true ) ;
            }
        }
    }

    public static Map<String,String> getCheckBody(String checkNumber,Id checkId){
        
        CDEXConfiguration__mdt c = [Select EndpointURL__c,Token__c from CDEXConfiguration__mdt  limit 1];
        Set<String> recentChecks = new Set<String>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(c.EndpointURL__c+checkNumber);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Accept-Encoding', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+c.Token__c);
		request.setTimeout(60000);
        //Set the body as a JSON object
        HttpResponse response = http.send(request);
        //Parse the JSON response 
        if (response.getStatusCode() !=200){
            System.debug('The status code returned is not expected:' + response.getStatusCode() + ''+ response.getStatus());
            return null;
        }
        else{
            system.debug('IMPORT Heap size before'+ limits.getHeapSize() + ' ==== '+ Limits.getLimitHeapSize());
            cdex = CdexParser.parse(response.getBody().substring(0,200).replaceFirst('details', 'Check')+response.getBody().substring(200));
            response = null;
            /*String checkBodyStr = response.getBody();
            String checkBodyStr1 = response.getBody().substring(0,200).replaceFirst('details', 'Check');
            String checkBodyStr2 = response.getBody().substring(200);
            checkBodyStr ='';
            checkBodyStr1 ='';
            checkBodyStr2 ='';*/
            system.debug('IMPORT Heap size before'+ limits.getHeapSize() + ' ==== '+ Limits.getLimitHeapSize());
            try{
                Map<String,String> retmap = ImportCdexChecks.createCdexChecksFromCallout(checkId);
                system.debug('Callout Heap size before'+ limits.getHeapSize() + ' ==== '+ Limits.getLimitHeapSize());
                return retmap;
            }catch(exception e){
                 log__c logRec = new log__c();
                logRec.Process__c = 'Cdex Check Import';
                logRec.Status__c = 'ERROR';
                logRec.Error_Message__c = e.getMessage();
                logRec.Additional_Details__c = 'Check Url: '+checkNumber;
                logRec.Stack_Trace__c = e.getStackTraceString();
                insert logRec;
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static String reprocessCdexCheck(Id checkId){
        
        Royalty_Check__c check = [Select Id,EnergyLink_URL__c  from Royalty_Check__c where Id=: checkId Limit 1];
        if(String.isBlank(check.EnergyLink_URL__c)){
            return 'Energy Link URL not Found';
        }else{
            Map<String,String> retmap = getCheckBody(check.EnergyLink_URL__c,check.Id);
            return 'Success';
        }
        
    }
}