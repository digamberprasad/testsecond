// ------------------------------------------------------------------------------------
// Interface for all trigger handlers
// Version#   Date           Author              Description
// ------------------------------------------------------------------------------------
// 1.0        26-Apr-2016    Puneet             Initial Version
// ------------------------------------------------------------------------------------
public interface ITriggerHandler {
    void beforeInsert(List<SObject> newItems);
    void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
    void beforeDelete(Map<Id, SObject> oldItems);
    void afterInsert(Map<Id, SObject> newItems);
    void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
    void afterDelete(Map<Id, SObject> oldItems);
    void afterUndelete(Map<Id, SObject> oldItems);
    Boolean isDisabled();
}