@isTest
private class conv_SObjectConverterTest {
    @isTest
    private static void can_convert_sobject_to_another() {
        Lead sourceRecord = new Lead(
            NumberOfEmployees = 1000,
            Description = 'Test Description'
        );

        // When converting the same types of SObjectFields
        conv_SObjectConverter converter = new LeadToAccountConverter(new Map<Schema.SObjectField, Schema.SObjectField> {
            Lead.Description => Account.Description, 
            Lead.NumberOfEmployees => Account.NumberOfEmployees
        });

        Test.startTest();
        SObject resultRecord = converter.convert(sourceRecord);
        Test.stopTest();

        // Expect the correct field values to have been converted.
        System.assert(resultRecord.getSObjectType() == Account.SObjectType, 
            'Expected the correct SObjectType.');
        System.assertEquals('Test Description', resultRecord.get(Account.Description), 
            'Expected the correct converted description.');
        System.assertEquals(1000, resultRecord.get(Account.NumberOfEmployees), 
            'Expected the correct converted No of employees.');   
    }

    @isTest
    private static void can_convert_sobject_to_another_with_different_field_types() {
        Lead sourceRecord = new Lead(
            NumberOfEmployees = 500
        );

        conv_SObjectConverter converter = new LeadToAccountConverter(new Map<Schema.SObjectField, Schema.SObjectField> {
            Lead.NumberOfEmployees => Account.Description
        });

        Test.startTest();
        SObject resultRecord = converter.convert(sourceRecord);
        Test.stopTest();

        System.assertEquals(String.valueOf(500), resultRecord.get(Account.Description), 
            'Expected the correct converted integer to string.');   
    }

    private class LeadToAccountConverter extends conv_SObjectConverter {
        private Map<Schema.SObjectField, Schema.SObjectField> targetFieldBySourceFieldMap;

        public LeadToAccountConverter(Map<Schema.SObjectField, Schema.SObjectField> targetFieldBySourceFieldMap) {
            this.targetFieldBySourceFieldMap = targetFieldBySourceFieldMap;
        }

        protected override SObjectType getTargetSObjectType() {
            return Account.SObjectType;
        }

        protected override Map<Schema.SObjectField, Schema.SObjectField> getTargetFieldBySourceFieldMap() {
            return this.targetFieldBySourceFieldMap;
        }
    }
}
