/**
* Description: All logic needed for the outline timetable
* Date: 21/06/16
* Author: makepositive
**/
public with sharing class OutlineTimetableCntrl {
    
    @TestVisible
    private static String OUTLINE_TIMETABLE_ACTIVE_STATUS = 'Active';
    @TestVisible 
    private static String OUTLINE_TIMETABLE_INACTIVE_STATUS = 'Inactive';
    @TestVisible
    private static Integer maxSectionEntries = 42;
    @TestVisible
    private static String coffeeBreak = '20:00';
    // when no version is passed this method will return the active outline timetable
    /*
@AuraEnabled
public static List<Outline_Timetable_Details__c> getOutlineTimetableVersionDetails(Id eventId, Integer version) {
String query = 'SELECT Id, Name, Section__c, Section__r.Name, Class__c, Class__r.Name, Number_of_Sections__c, SJ_Course_Walks__c, ' +
'Dressage_Coffee_Break__c, Dressage_Duration__c, Dressage_End_Time__c, Dressage_Start_Time__c, ' +
'Dressage_Test_Time__c, SJ_Course_Change__c, SJ_Duration__c, SJ_End_Time__c, SJ_Interval__c, ' +
'SJ_Start_Time__c, XC_Course_Change__c, XC_Duration__c, XC_End_Time__c, XC_Interval__c, ' +
'XC_Start_Time__c, Outline_Timetable__r.Status__c,  Outline_Timetable__r.Version__c ' +
'FROM Outline_Timetable_Details__c ' +
'WHERE Outline_Timetable__r.Event__c = :eventId ';
String andCondition = version != null ? ' AND Outline_Timetable__r.Version__c = :version ' : ' AND Outline_Timetable__r.Status__c = :OUTLINE_TIMETABLE_ACTIVE_STATUS ';
query = query + andCondition + 'ORDER BY NAME ASC';
System.debug('query -> ' + query);
return Database.query(query);
}

// returns a list with all the exiting versions of the outlinetimetable
@AuraEnabled
public static List<OutlineTimetableVersionWrapper> getOutlineTimetableVersions(Id eventId) {
List<OutlineTimetableVersionWrapper> versionWrapperList = new List<OutlineTimetableVersionWrapper>();

for(Outline_Timetable__c ot : [SELECT Id, Status__c, Version__c
FROM Outline_Timetable__c 
WHERE Event__c = :eventId
ORDER BY Version__c DESC]) {
versionWrapperList.add(new OutlineTimetableVersionWrapper(String.valueOf(ot.Version__c), ot.Status__c == OUTLINE_TIMETABLE_ACTIVE_STATUS));
}

return versionWrapperList;
}

// gets the current active outline timetable
// or creates a new one if there's no active one
@AuraEnabled
public static List<Outline_Timetable_Details__c> getOutlineTimetable(Id eventId) {
System.debug('getOutlineTimetable eventId ' + eventId);
List<Outline_Timetable_Details__c> outlineTimetable = getOutlineTimetableVersionDetails(eventId, null);
// there's no active version of the outline timetable
// creates one suggesting times for the different disciplines
if (outlineTimetable.size() == 0) {
outlineTimetable = createOutlineTimetable(eventId);
}

return outlineTimetable;
}

// activate a version of the outline timetable
@AuraEnabled
public static Boolean activateOutlineTimetableVersion(Id eventId, Integer version) {
try {
List<Outline_Timetable__c> existingOutlineTimetableList = new List<Outline_Timetable__c>();
// sets all outline timetable versions to inactive, except for the one passed in
for(Outline_Timetable__c existingOT : [SELECT Id, Status__c, Version__c
FROM Outline_Timetable__c 
WHERE Event__c = :eventId
ORDER BY Version__c DESC]) {
String status = existingOT.Version__c == version ? OUTLINE_TIMETABLE_ACTIVE_STATUS : OUTLINE_TIMETABLE_INACTIVE_STATUS;
existingOutlineTimetableList.add(new Outline_Timetable__c(Id = existingOT.Id, Status__c = status));  
}

update existingOutlineTimetableList;

return true;
} catch(Exception e) {
return false;
}
}

// creates a new version of the outline timetable
@AuraEnabled
public static List<Outline_Timetable_Details__c> createNewOutlineTimetableVersion(Id eventId) {
return createOutlineTimetable(eventId);
}

// suggets a possible timetable for the event
private static List<Outline_Timetable_Details__c> createOutlineTimetable(Id eventId) {
try {
Integer newVersion = 1;
Integer maxSectionEntries = 42;
Integer sectionPos = 0;
List<String> sectionNameList = new List<String> {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
// fetch existing outline timetable version for the event
List<Outline_Timetable__c> existingOutlineTimetableList = new List<Outline_Timetable__c>();
// sets all previous outline timetable to inactive
for(Outline_Timetable__c existingOT : [SELECT Id, Status__c, Version__c
FROM Outline_Timetable__c 
WHERE Event__c = :eventId
ORDER BY Version__c DESC]) {
existingOutlineTimetableList.add(new Outline_Timetable__c(Id = existingOT.Id, Status__c = OUTLINE_TIMETABLE_INACTIVE_STATUS, Version__c = existingOT.Version__c));  
}
System.debug('existingOutlineTimetableList -> ' + existingOutlineTimetableList);
if (existingOutlineTimetableList.size() > 0) {
update existingOutlineTimetableList;
newVersion = Integer.valueOf(existingOutlineTimetableList.get(0).Version__c) + 1;
}
// create a new version of the outline timetable
Outline_Timetable__c ot = new Outline_Timetable__c(Status__c = OUTLINE_TIMETABLE_ACTIVE_STATUS, Version__c = newVersion, Event__c = eventId);
insert ot;

System.debug('ot -> ' + ot);

List<Outline_Timetable_Details__c> outlineTimetable = new List<Outline_Timetable_Details__c>();
List<Section__c> sectionList = new List<Section__c>();

for (Class__c c : [SELECT Id, Name, Class_Entries__c
FROM Class__c
WHERE Event__c = :eventId]) {
// needs logic to create section and times!
Integer max = Integer.valueOf(Math.ceil(c.Class_Entries__c / maxSectionEntries));
System.debug('max -> ' + max);
System.debug('c -> ' + c);
for (Integer i = 0; i < max; i++) {
sectionList.add(new Section__c(Class__c = c.Id, Name = sectionNameList.get(sectionPos)));
sectionPos++;
}
}

if (sectionList.size() > 0) {
insert sectionList;
for (Section__c s : sectionList) {
outlineTimetable.add(new Outline_Timetable_Details__c(Class__c = s.Class__c, Outline_Timetable__c = ot.Id, Section__c = s.Id));
}
}

// new version of the outline timetable created
if (outlineTimetable.size() > 0) {
insert outlineTimetable;
}

return getOutlineTimetableVersionDetails(eventId, newVersion);
}catch(Exception ex) {
System.debug('Something went wrong -> ' + ex.getMessage());
return null;
}
}


public class OutlineTimetableVersionWrapper {
@AuraEnabled
public String version;
@AuraEnabled
public Boolean isActive;

public OutlineTimetableVersionWrapper(String version, Boolean isActive) {
this.version = version;
this.isActive = isActive;
}
} */
    @AuraEnabled
    public static List<Outline_Timetable_Details__c> getOutlineTimetable(Id eventId) {
        return [SELECT Id, Name, Section__c, Section__r.Name, Class__c, Class__r.Name, Number_of_Sections__c, SJ_Course_Walks__c,
            Dressage_Coffee_Break__c, Dressage_Duration__c, Dressage_End_Time__c, Dressage_Start_Time__c, 
            Dressage_Test_Time__c, SJ_Course_Change__c, SJ_Duration__c, SJ_End_Time__c, SJ_Interval__c, 
            SJ_Start_Time__c, XC_Course_Change__c, XC_Duration__c, XC_End_Time__c, XC_Interval__c, 
            XC_Start_Time__c, Outline_Timetable__r.Status__c,  Outline_Timetable__r.Version__c, Section__r.Entries__c
            FROM Outline_Timetable_Details__c
            WHERE Outline_Timetable__r.Event__c = :eventId 
            ORDER BY NAME ASC];
    }

    @AuraEnabled
    public static List<Class__c> getEventClasses(Id eventId) {
        return [SELECT Id, Name, Class_Entries__c, Number_of_Sections__c, Order__c,
                    Event__r.Start_Date__c, Event__r.Dressage_Arenas__c,Event__r.Times_Start__c
                FROM Class__c
                WHERE Event__c = :eventId];
    }
    
    // updates events and classes based on user input from OutlineTimetableInfo lightning cmp
    // creates sections for the event classes
    @AuraEnabled
    public static Boolean saveOutlineTimetableInfo(Id eventId, String otInfoJSON) {
        try {
            System.debug('saveOutlineTimetableInfo otInfoJSON -> ' + otInfoJSON);
            OutlineTimetableInfo otInfo = (OutlineTimetableInfo)JSON.deserialize(otInfoJSON, OutlineTimetableInfo.class);
            
            System.debug('saveOutlineTimetableInfo eventId -> ' + eventId);
            System.debug('saveOutlineTimetableInfo otInfo -> ' + otInfo);
            // update the event and the classes with the data provided in the lightning cmp
            Event__c e = [SELECT Id, Start_Date__c, Dressage_Arenas__c
                          FROM Event__c
                          WHERE Id = :eventId];
            e.Start_Date__c = otInfo.startTime;
            e.Dressage_Arenas__c = otInfo.dressageArena;
            update e;
            update otInfo.classList;
            
            // name sections for the classes
            Integer sectionPos = 0;
            List<String> sectionNameList = new List<String> {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
           
            // creates a new outline timetable, deleting the previous one if any
            List<Outline_Timetable__c> otList = [SELECT Id FROM Outline_Timetable__c WHERE Event__c = :eventId];
            if (otList.size() > 0) { 
                List<Section__c> sList = [SELECT Id
                                         FROM Section__c
                                         WHERE Class__r.Event__c = :eventId];
                delete sList;
                delete otList;
            }
            Outline_Timetable__c ot = new Outline_Timetable__c(Event__c = eventId);
            insert ot;
            
            List<Outline_Timetable_Details__c> outlineTimetable = new List<Outline_Timetable_Details__c>();
            List<Section__c> sectionList = new List<Section__c>();
            Map<Id, Integer> classNumberSections = new Map<Id, Integer>();
            // create sections and details for the outline timetable
            for (Class__c c : [SELECT Id, Name, Number_of_Sections__c, Class_Entries__c
                               FROM Class__c
                               WHERE Event__c = :eventId
                               ORDER BY Order__c ASC]) {
                Integer remainingEntries = Integer.valueOf(c.Class_Entries__c);
                for (Integer i = 0; i < c.Number_of_Sections__c ; i++) {
                    // splits class entries into section entries
                    // considering what's usually the maximum number of entries 
                    // allowed per section
                    Integer sectionEntries = (remainingEntries <= maxSectionEntries) ? remainingEntries : maxSectionEntries;
                    remainingEntries = remainingEntries - maxSectionEntries;
                    remainingEntries = (remainingEntries < 0) ? 0 : remainingEntries;
                    sectionList.add(new Section__c(Class__c = c.Id, Name = sectionNameList.get(sectionPos), Entries__c = sectionEntries));
                    sectionPos++;
                }
                classNumberSections.put(c.Id, Integer.valueOf(c.Number_of_Sections__c));
            }
            
            if (sectionList.size() > 0) {
                insert sectionList;
            }
            
            Id previousClassId, currentClassId;
            for (Section__c s : sectionList) {
                Outline_Timetable_Details__c otDetails = new Outline_Timetable_Details__c(Class__c = s.Class__c, Outline_Timetable__c = ot.Id, Section__c = s.Id);
                currentClassId = s.Class__c;
                if (previousClassId != currentClassId) {
                    // needed to combine rows in the SJ and XC html table section
                    otDetails.Number_of_Sections__c = classNumberSections.get(s.Class__c);
                    previousClassId = s.Class__c;
                }
                outlineTimetable.add(otDetails);
            }

            if (outlineTimetable.size() > 0) {
                insert outlineTimetable;
            }
            
            return true;
        } catch(Exception ex) {
            System.debug('Something went wrong ' + ex.getMessage());
            return false;
        }
        
    }

    public class OutlineTimetableInfo {
        @AuraEnabled
        public Datetime startTime;
        @AuraEnabled
        public Integer dressageArena;
        @AuraEnabled
        public List<Class__c> classList;
        
        public OutlineTimetableInfo() {}
    }
}