@isTest 
private class accountTriggerTest {

	
	@isTest
	private static void testName() {
		Account a = new Account(Name = 'New Account Trigger Test');
		insert a;
		a.Description = 'Test Notes';
		update a;
		delete a;
	}
}