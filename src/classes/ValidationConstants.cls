/**
 * Constants for Validation Engine
 * @author : Puneet Sardana
 * @Created Date : 18/05/2016
 * */
public class ValidationConstants extends BEConstants {
    public final static String VALIDATION_TYPE_INDEPENDENT = 'Class Independent';
    public final static String VALIDATION_TYPE_CLASSSPECIFIC = 'Class Specific';
    public final static String OPERAND_TYPE_FIELD = 'Field';
    public final static String QUERY_FIELD_ID = 'Id';
    public final static String SELF_OBJECT = 'Self';
    public final static String QUERY_FIELD_SEPARATOR = ',';
    public final static String QUERY_SELECT = 'SELECT ';
    public final static String QUERY_FROM = ' FROM ';
    public final static String QUERY_WHERE = ' WHERE ';
    public final static String QUERY_OR = ' OR ';
    public final static String QUERY_IN = ' IN ';
    public final static String QUERY_AND = 'AND';


    public final static String RELATES_TO_HORSE = 'Horse';
    public final static String RELATES_TO_RIDER = 'Rider';
    public final static String RELATES_TO_EVENT = 'Event';
    public final static String RELATES_TO_ID = 'Id';
    public final static String RELATES_TO_HORSEAPI = 'Horse__c';
    public final static String RELATES_TO_RIDERAPI = 'Contact';
    public final static String RELATES_TO_EVENTAPI = 'Event__c';


    public final static String CRITERIA_CALMODE_BATCH = 'Batch';
    public final static String VALIDATION_RESULT_PASS = 'Pass';
    public final static String VALIDATION_RESULT_FAIL = 'Fail';
    public final static String VALIDATION_LOGIC_START_DELIMITER = '[';
    public final static String VALIDATION_LOGIC_END_DELIMITER = ']';
    public final static String VALIDATION_COMPONENT_SPLITTER = ',';
    public final static String VRCOMPONENT_VALUE_SPLITTER = ',';
    public final static String VRCOMPONENT_OPERANDTYPE_FIELD = 'Field';
    public final static String VRCOMPONENT_OPERANDTYPE_VALUE = 'Value';
    public final static String VRCOMPONENT_ATTRIBUTE_TYPESTRING = 'Text';
    public final static String VRCOMPONENT_ATTRIBUTE_TYPEDATE = 'Date';
    public final static String VRCOMPONENT_ATTRIBUTE_TYPEDATETIME = 'DateTime';
    public final static String VRCOMPONENT_ATTRIBUTE_TYPEBOOLEAN = 'Boolean';
    public final static String VRCOMPONENT_ATTRIBUTE_TYPENUMBER = 'Number';

    public final static String VRCOMPONENT_OPERATOR_EQUALS = 'equals';
    public final static String VRCOMPONENT_OPERATOR_NOTEQUAL = 'not equal';
    public final static String VRCOMPONENT_OPERATOR_LESSTHAN = 'less than';
    public final static String VRCOMPONENT_OPERATOR_LESSTHANEQUAL = 'less or equal';
    public final static String VRCOMPONENT_OPERATOR_GREATERTHAN = 'greater than';
    public final static String VRCOMPONENT_OPERATOR_GREATERTHANEQUAL = 'greater or equal';
    public final static String VRCOMPONENT_OPERATOR_CONTAINS = 'contains';

    public final static String VRCOMPONENT_ATTRIBUTETYPE_TEXT = 'Text';
    public final static String VRCOMPONENT_ATTRIBUTETYPE_DATE = 'Date';
    public final static String VRCOMPONENT_ATTRIBUTETYPE_DATETIME = 'DateTime';

    public final static String VRCOMPONENT_ATTRIBUTETYPE_BOOLEAN = 'Boolean';
    public final static String VRCOMPONENT_ATTRIBUTETYPE_NUMBER = 'Number';

    public final static String TRUE_STRING = 'true';
    public final static String FALSE_STRING = 'false';

    public final static Integer TOOLING_API_BATCHSIZE = 250;
    public final static String VALIDATION_AND = 'AND';
    public final static String VALIDATION_OR = 'OR';
    public final static String VALIDATION_TOOLING_AND = '&&';
    public final static String VALIDATION_TOOLING_OR = '||';

    public final static String VRCRITERIA_CATEGORY_MANDATORY = 'Mandatory';
    public final static String VRCRITERIA_CATEGORY_WARNING = 'Warning';
    public final static String VRCRITERIA_MESSAGE_FIELD_PASTPRESENT = 'Start_Date__c';

    public final static String VRCRITERIA_ISMET = 'Is Met';
    public final static String VRCRITERIA_ISNOTMET = 'Is Not Met';
    public final static String BLANK_VALUE = ' ';
    public final static String CUSTOM_OBJECT = '*';
    public final static Set<Schema.DisplayType> VALIDATION_SUPPORTED_FIELDTYPES =
                                                                            new Set<Schema.DisplayType> { Schema.DisplayType.Boolean ,
                                                                                                                                   Schema.DisplayType.Currency,
                                                                                                                                   Schema.DisplayType.Date,
                                                                                                                                   Schema.DisplayType.DateTime,
                                                                                                                                   Schema.DisplayType.Double,
                                                                                                                                   Schema.DisplayType.Email,
                                                                                                                                   Schema.DisplayType.ID,
                                                                                                                                   Schema.DisplayType.Integer,
                                                                                                                                   Schema.DisplayType.Picklist,
                                                                                                                                   Schema.DisplayType.String,
                                                                                                                                   Schema.DisplayType.TextArea,
                                                                                                                                   Schema.DisplayType.URL };
}