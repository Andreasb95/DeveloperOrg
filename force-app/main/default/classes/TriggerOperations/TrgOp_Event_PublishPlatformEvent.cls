public with sharing class TrgOp_Event_PublishPlatformEvent {
    
    Event newRecord;
    Event oldRecord;


    public TrgOp_Event_PublishPlatformEvent(List<SObject> newSObject, List<SObject> oldSobject) {
        newRecord = (Event) newSObject[0];
        EventBus.publish(new Event_Created__e(Service_Resource_Id__c = getServiceResourceIdFromAppointment(newRecord.ServiceAppointmentId), Service_Appointment_Id__c = newRecord.ServiceAppointmentId));
        System.debug('publish ---->');
    }

    private String getServiceResourceIdFromAppointment(String id){
        List<AssignedResource> ar = [SELECT Id, ServiceResourceId FROM AssignedResource WHERE ServiceAppointmentId = :id];
        return ar[0].ServiceResourceId;
    }



}