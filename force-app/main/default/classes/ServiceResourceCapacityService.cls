public with sharing class ServiceResourceCapacityService {
    private static ServiceResourceCapacityService instance;

    private Map<String,Service_Resource_Capacity__c> existingSetup = new Map<String,Service_Resource_Capacity__c>();
    private List<Service_Resource_Capacity__c> initialSetup = new List<Service_Resource_Capacity__c>();
    private List<Service_Resource_Capacity__c> actualSetup = new List<Service_Resource_Capacity__c>();

    @InvocableMethod(label='Setup Service Resource with availability weeks' description='Creates a record for every week, to setup the service resource capacity')
    public static void setupServiceResourceAction(List<String> serviceResourceId){
        ServiceResourceCapacityService service = ServiceResourceCapacityService.getInstance();
        service.setupServiceResource(serviceResourceId[0]);
    }

    public static ServiceResourceCapacityService getInstance(){
        if (instance == null) {
            return new ServiceResourceCapacityService();
        }
        return instance;
    }

    private void setupServiceResource(String serviceResourceId){
        checkForExistingSetup(serviceResourceId);
        if (existingSetup.isEmpty()) {
            createInitialSetup(serviceResourceId);
            actualSetup = initialSetup;
        }

        else {
            for (Service_Resource_Capacity__c c : initialSetup) {
                if (!existingSetup.containsKey(c.Week__c)) {
                    actualSetup.add(c);
                }
            }
        }
        insert (actualSetup);
    }

    private void checkForExistingSetup(String serviceResourceId){
        for (Service_Resource_Capacity__c ex : [SELECT Id, Service_Resource__c, Week__c FROM Service_Resource_Capacity__c WHERE Service_Resource__c = :serviceResourceId]) {
            existingSetup.put(ex.Week__c, ex);
        }
    }

    private void createInitialSetup(String serviceResourceId){
        Set<Id> weekIds = new Set<Id>();
        for (Week__c w : [SELECT Id from Week__c]) {
            weekIds.add(w.Id);
        }
        for (Id week : weekIds) {
            initialSetup.add(new Service_Resource_Capacity__c(Service_Resource__c = serviceResourceId, Week__c = week));
        }
    }    
}

