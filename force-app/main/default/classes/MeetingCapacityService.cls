public with sharing class MeetingCapacityService {
    private static MeetingCapacityService instance;
    
    public static MeetingCapacityService getInstance(){
        if (instance == null) {
            return new MeetingCapacityService();
        }
        return instance;
    }

    @InvocableMethod(label='Calculate weekly capacity' description='check the users weekly meeting capacity and creates an absence record if max is acheived')
    public static void calculateUserMeetingBudget(List<String> serviceappointmentId, List<String> eventRecordType){
        MeetingCapacityService service = MeetingCapacityService.getInstance();
        service.capacityCalculation(serviceAppointmentId[0],eventRecordType[0]);
    }

    private void capacityCalculation(String serviceAppointmentId, String countEventsWithRecordType){
        AssignedResource sa = [SELECT Id, ServiceAppointment.SchedStartTime, ServiceResourceId FROM AssignedResource WHERE ServiceAppointmentId = :serviceAppointmentId];
        Integer weekNr = Integer.valueOf(sa.ServiceAppointment.SchedStartTime.format('w'));
        
        Map<Integer,Service_Resource_Capacity__c> availabilityMap = new Map<Integer,Service_Resource_Capacity__c>();
        for (Service_Resource_Capacity__c av : [SELECT Id, 	Service_Resource__c, Service_Resource__r.RelatedRecordId, Week__c, Week__r.Name, Capacity__c FROM Service_Resource_Capacity__c WHERE Service_Resource__c = :sa.ServiceResourceId AND Week__r.Name = :weekNr.toString()] ) {
            availabilityMap.put(Integer.valueOf(av.Week__r.Name), av);            
        }
        
        // Get the week number from the start of the year
        Integer count = [SELECT COUNT() FROM Event WHERE WEEK_IN_YEAR(ActivityDateTime) = :weekNr AND OwnerId = :availabilityMap.get(weekNr).Service_Resource__r.RelatedRecordId AND RecordType.Name = :countEventsWithRecordType];
        System.debug('count >>' + count);

        if (availabilityMap.get(weekNr).Capacity__c <= count) {
            Map<String, Date> startAndEndOfWeek = getDateRange(sa.ServiceAppointment.SchedStartTime);
            insert(new ResourceAbsence(ResourceId = availabilityMap.get(weekNr).Service_Resource__c, Start = startAndEndOfWeek.get('start'), End = startAndEndOfWeek.get('end'), Type = 'Weekly_Capacity_Reached'));
        }
    }
    
    private Map<String, Date> getDateRange(Datetime schedStartTime){
        Map<String, Date> startAndEnd = new Map<String, Date>();
        DateTime weekStart = schedStartTime.date().toStartofWeek();
        startAndEnd.put('start', weekStart.date());
        startAndEnd.put('end', weekStart.addDays(4).date());
        return startAndEnd;
    }   
}