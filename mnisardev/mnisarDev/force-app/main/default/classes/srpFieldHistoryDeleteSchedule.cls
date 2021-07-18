global class srpFieldHistoryDeleteSchedule implements Schedulable  {
	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */ 
	global void execute(SchedulableContext sc) {
		DeleteSRPFieldHistory newDeletion = new DeleteSRPFieldHistory();
	}
}