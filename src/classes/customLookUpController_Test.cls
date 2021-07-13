@isTest
public class customLookUpController_Test{
    
    @isTest
    public static void lookupTest(){
        
       list<sObject> testList = customLookUpController.fetchLookUpValues('', 'Account');
    }
}