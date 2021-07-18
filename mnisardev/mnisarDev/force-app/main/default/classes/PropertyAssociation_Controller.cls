public class PropertyAssociation_Controller{
    /*
    //@future
    public static void reAssociateCSVChecks(String revenueProperty){
        system.debug( revenueProperty);
        revenuePropertyWrapper config = (revenuePropertyWrapper)System.JSON.deserialize(revenueProperty,revenuePropertyWrapper.class);
        List<Royalty_Line_Item__c> rliListUpdate = new List<Royalty_Line_Item__c>();
        Royalty_Line_Item__c rliInstance;
        
        if(config.oldValue.size() == config.newValue.size()){
            Map<String,String> wellMap = new Map<String,String>();
            for(Integer i = 0; i<config.newValue.size() ; i++){
                wellMap.put(config.oldValue[i],config.newValue[i]);
            }
            List<Royalty_Line_Item__c> rliList = [Select Id,well__r.API10__c,well__c
                            from Royalty_Line_Item__c 
                            where propertyName__c =: config.propertyName
                            AND (Royalty_Check__r.Source__c = 'CSV' OR Royalty_Check__r.Source__c = '')
                            order by well__c];
            for(Royalty_Line_Item__c rli : rliList){
                rliInstance = new Royalty_Line_Item__c(Id = rli.Id);
                if(wellMap.get(rli.well__r.API10__c) =='NONWELLITEM'){
                    rliInstance.Well__c = null;
                    rliInstance.isNonWellLineItem__c = true;
                    rliInstance.revenueAllocated__c = true;
                    System.debug('non');
                }else{
                    if(rli.well__c!=null && wellMap.containsKey(rli.well__r.API10__c)){
                        rliInstance.Well__r = new well__c(API10__c = wellMap.get(rli.well__r.API10__c));
                    }else{
                        rliInstance.Well__r =  new well__c(API10__c = wellMap.get( 'NONWELLITEM'));
                    }
                   
                }
                rliListUpdate.add(rliInstance);
            }
            update rliListUpdate;
        }else if(config.oldValue.size() > config.newValue.size()){
            Map<String,String> wellMap = new Map<String,String>();
            for(Integer i = 0; i<config.newValue.size() ; i++){
                wellMap.put(config.oldValue[i],config.newValue[i]);
            }
            
            List<Royalty_Line_Item__c> rliListDelete = new List<Royalty_Line_Item__c>();
            for(Royalty_Line_Item__c rli : [Select Id,well__r.API10__c,ownerNetValueActual__c 
                                from Royalty_Line_Item__c 
                                where propertyName__c =: config.propertyName 
                                AND Royalty_Check__r.Source__c != 'CDEX'
                                order by well__c]){
                if(wellMap.containsKey(rli.well__r.API10__c)){
                    rliInstance = new Royalty_Line_Item__c(Id = rli.Id);
                    if(wellMap.get(rli.well__r.API10__c) =='NONWELLITEM'){
                        rliInstance.Well__c = null;
                        rliInstance.isNonWellLineItem__c = true;
                        rliInstance.revenueAllocated__c = true;
                        if(rli.ownerNetValueActual__c!=null){
                            rliInstance.ownerNetValueActual__c = (rli.ownerNetValueActual__c*config.oldValue.size())/config.newValue.size();
                        }
                    }else{
                        rliInstance.Well__r = new well__c(API10__c = wellMap.get(rli.well__r.API10__c));
                        if(rli.ownerNetValueActual__c!=null){
                            rliInstance.ownerNetValueActual__c = (rli.ownerNetValueActual__c*config.oldValue.size())/config.newValue.size();
                        }
                    }
                    rliListUpdate.add(rliInstance);
                }else{
                    rliListDelete.add(rli);
                }

            }
            update rliListUpdate;
            delete rliListDelete;
        }else if(config.oldValue.size() < config.newValue.size()){
            Map<String,String> wellMap = new Map<String,String>();
            Set<String> newValueSet = new Set<String>();
            for(Integer i = 0; i<config.oldValue.size() ; i++){
                wellMap.put(config.oldValue[i],config.newValue[i]);
            }
            system.debug('----'+wellMap);
            for(String str : config.newValue){
                    newValueSet.add(str);
            }
            newValueSet.removeAll(wellMap.values());
            List<Royalty_Line_Item__c> rliListInsert = new List<Royalty_Line_Item__c>();

            Royalty_Line_Item__c newRli;
            List<String> fieldNames = new List<String>();
            for(String name: Royalty_Line_Item__c.sObjectType.getDescribe().fields.getMap().keySet()){
                fieldNames.add(name);
            }

            for(Royalty_Line_Item__c rli : Database.query('select ' + string.join(fieldNames, ',') +',well__r.API10__c'+ ' from Royalty_Line_Item__c'
                                +' where propertyName__c =\''+ config.propertyName+'\''
                                +' AND Royalty_Check__r.Source__c != \'CDEX\'')){
                                    
                    rliInstance = new Royalty_Line_Item__c(Id=rli.Id);
                    if(wellMap.get(rli.well__r.API10__c) =='NONWELLITEM'){
                        rliInstance.Well__c = null;
                        rliInstance.isNonWellLineItem__c = true;
                        rliInstance.revenueAllocated__c = true;
                        if(rli.ownerNetValueActual__c!=null){
                            rliInstance.ownerNetValueActual__c = (rli.ownerNetValueActual__c*config.oldValue.size())/config.newValue.size();
                        }
                    }else{
                         system.debug('-ELSE---');
                        if(rli.well__c!=null && wellMap.containsKey(rli.well__r.API10__c)){
                             system.debug('--ELSE--'+wellMap.get(rli.well__r.API10__c));
                        	rliInstance.Well__r = new well__c(API10__c = wellMap.get(rli.well__r.API10__c));
                        }else{
                            system.debug('--oldValue--'+wellMap.get( 'NONWELLITEM'));
                            rliInstance.Well__r =  new well__c(API10__c = wellMap.get( 'NONWELLITEM'));
                        }
                        if(rli.ownerNetValueActual__c!=null){
                            rliInstance.ownerNetValueActual__c = (rli.ownerNetValueActual__c*config.oldValue.size())/config.newValue.size();
                        }
                        
                    }
                    rliListUpdate.add(rliInstance);
                
                if(config.oldValue[0]==rli.well__r.API10__c || config.oldValue[0]== 'NONWELLITEM'){      
                    for(String api10 : newValueSet){
                                system.debug('2'+api10);
                        newRli = rli.clone(false,false,false,false);
                        Map<String,Object> objMap = (Map<String,Object>)JSON.deserializeUntyped( JSON.serialize( newRli ) );
                        objMap.remove('Well__c');
                        newRli = (Royalty_Line_Item__c)(JSON.deserialize(System.JSON.serialize(objMap), Royalty_Line_Item__c.class));
                        newrli.Well__r = new well__c(API10__c = api10);
                        if(rli.ownerNetValueActual__c!=null){
                            newrli.ownerNetValueActual__c = (rli.ownerNetValueActual__c*config.oldValue.size())/config.newValue.size();
                        }
                        newRLI.revenueAllocated__c = true;
                        rliListInsert.add(newRLI);
                    }
                }
            }
            system.debug(rliListUpdate.size());
            system.debug(rliListInsert.size());
            update rliListUpdate;
            insert rliListInsert;
        }else{
            //Do Nothing
        }
    }

    public class revenuePropertyWrapper{
        public string propertyName;
        public String[] oldValue;
        public string[] newValue;
    }*/
}