// ------------------------------------------------------------------------------------
// Common trigger dispathcher class for all trigger handlers
// Version#   Date           Author              Description
// ------------------------------------------------------------------------------------
// 1.0        26-Apr-2016    Puneet             Initial Version
// ------------------------------------------------------------------------------------
public class TriggerDispatcher {          
    // 26-Apr-2016    Puneet    This is the method that will be called from your trigger 
    //                          passing in your instance of trigger handler        
    // @params 
    // handler - instance of trigger handler    
    // @return - NA
    public static void Run(ITriggerHandler handler) {
        // Check to see if the trigger has been disabled. If it has, return
        if (handler.IsDisabled())
            return;             
        if (Trigger.IsBefore ) { 
            if (Trigger.IsInsert)
                handler.BeforeInsert(trigger.new);
            if (Trigger.IsUpdate)
                handler.BeforeUpdate(trigger.newMap, trigger.oldMap);
            if (Trigger.IsDelete)
                handler.BeforeDelete(trigger.oldMap);
        }         
        else if (Trigger.IsAfter) {
            if (Trigger.IsInsert)
                handler.AfterInsert(Trigger.newMap);
            if (Trigger.IsUpdate)
                handler.AfterUpdate(trigger.newMap, trigger.oldMap);
            if (trigger.IsDelete)
                handler.AfterDelete(trigger.oldMap);
            if (trigger.isUndelete)
                handler.AfterUndelete(trigger.oldMap);
        }
    }
}