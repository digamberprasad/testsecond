/**
* Test class for object field
* @Author : Puneet Sardana
* @Created Date : 28/06/2016
*/
@isTest
public class ObjectFieldController_Test {
    @isTest
    public static void test_ObjectFieldController() {
        Test.startTest();
            List<SelectOption> objects = ObjectFieldController.getObjects();
            System.assert(objects.size() > 0);
            List<SelectOption> fields = ObjectFieldController.getObjectFields(objects.get(0).value);
            System.assert(fields.size() > 0);
            List<SelectOption> relations = ObjectFieldController.getObjectRelationships(objects.get(0).value);
            System.assert(relations.size() > 0);
        Test.stopTest();
    }
}