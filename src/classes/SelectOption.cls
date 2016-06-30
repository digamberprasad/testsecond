/**
 * Created SelectOption class as for lightning properties should be Aura Enabled
 * @author : Puneet Sardana
 * @Created Date : 16/05/2016
 * */
global class SelectOption implements Comparable {
        global SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
            this.disabled = false;
            this.escapeItem = false;
        }
        global SelectOption(String value, String label, Boolean isDisabled) {
            this.value = value;
            this.label = label;
            this.disabled = isDisabled;
            this.escapeItem = false;
        }
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get;set; }
        @AuraEnabled
        public Boolean disabled { get;set; }
        @AuraEnabled
        public Boolean escapeItem { get;set; }
        global Integer compareTo(Object ObjToCompare) {
            return label.CompareTo(((SelectOption)ObjToCompare).label);
        }
    }