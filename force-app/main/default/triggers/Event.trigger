trigger Event on Event (before insert, after insert) {
    
    switch on Trigger.OperationType {
        when BEFORE_INSERT  {
            
        }
        when AFTER_INSERT {
            new TrgOp_Event_PublishPlatformEvent(trigger.new, trigger.old);
        }
        when else {
            
        }
    }
}