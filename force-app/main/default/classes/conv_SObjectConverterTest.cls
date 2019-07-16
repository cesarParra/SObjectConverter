@isTest
private class conv_SObjectConverterTest {
    @isTest
    private static void canConvertSObjectToAnother() {
        Lead sourceRecord = new Lead(
            NumberOfEmployees = 1000,
            Description = 'Test Description'
        );

        // When converting the same types of SObjectFields
        conv_SObjectConverter converter = new GenericConverter(new Map<Schema.SObjectField, Schema.SObjectField> {
            Lead.Description => Account.Description, 
            Lead.NumberOfEmployees => Account.NumberOfEmployees
        }, Account.SObjectType);

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
    private static void canConvertNonStringToString() {
        Lead sourceRecord = new Lead(
            NumberOfEmployees = 500
        );

        conv_SObjectConverter converter = new GenericConverter(new Map<Schema.SObjectField, Schema.SObjectField> {
            Lead.NumberOfEmployees => Account.Description
        }, Account.SObjectType);

        Test.startTest();
        SObject resultRecord = converter.convert(sourceRecord);
        Test.stopTest();

        System.assertEquals(String.valueOf(500), resultRecord.get(Account.Description), 
            'Expected the correct converted integer to string.');   
    }

    @isTest
    private static void canConvertNumberZeroToFalseBoolean() {
        Lead sourceRecord = new Lead(
            NumberOfEmployees = 0
        );

        conv_SObjectConverter converter = new GenericConverter(new Map<Schema.SObjectField, Schema.SObjectField> {
            Lead.NumberOfEmployees => Lead.DoNotCall
        }, Lead.SObjectType);

        Test.startTest();
        SObject resultRecord = converter.convert(sourceRecord);
        Test.stopTest();

        System.assertEquals(false, resultRecord.get(Lead.DoNotCall), 
            'Expected the correct converted number to boolean.');   
    }

    @isTest
    private static void canConvertNonZeroToPositiveBoolean() {
        Lead sourceRecord = new Lead(
            NumberOfEmployees = 1
        );

        conv_SObjectConverter converter = new GenericConverter(new Map<Schema.SObjectField, Schema.SObjectField> {
            Lead.NumberOfEmployees => Lead.DoNotCall
        }, Lead.SObjectType);

        Test.startTest();
        SObject resultRecord = converter.convert(sourceRecord);
        Test.stopTest();

        System.assertEquals(true, resultRecord.get(Lead.DoNotCall), 
            'Expected the correct converted number to boolean.');   
    }

    @isTest
    private static void canConvertYesStringToTrue() {
        Lead sourceRecord = new Lead(
            Jigsaw = 'yes'
        );

        conv_SObjectConverter converter = new GenericConverter(new Map<Schema.SObjectField, Schema.SObjectField> {
            Lead.Jigsaw => Lead.DoNotCall
        }, Lead.SObjectType);

        Test.startTest();
        SObject resultRecord = converter.convert(sourceRecord);
        Test.stopTest();

        System.assertEquals(true, resultRecord.get(Lead.DoNotCall), 
            'Expected the correct converted string to boolean.');   
    }

    @isTest
    private static void canConvertTrueStringToTrue() {
        Lead sourceRecord = new Lead(
            Jigsaw = 'True'
        );

        conv_SObjectConverter converter = new GenericConverter(new Map<Schema.SObjectField, Schema.SObjectField> {
            Lead.Jigsaw => Lead.DoNotCall
        }, Lead.SObjectType);

        Test.startTest();
        SObject resultRecord = converter.convert(sourceRecord);
        Test.stopTest();

        System.assertEquals(true, resultRecord.get(Lead.DoNotCall), 
            'Expected the correct converted string to boolean.');   
    }
    @isTest
    private static void canConvertNoStringToFalse() {
        Lead sourceRecord = new Lead(
            Jigsaw = 'No'
        );

        conv_SObjectConverter converter = new GenericConverter(new Map<Schema.SObjectField, Schema.SObjectField> {
            Lead.Jigsaw => Lead.DoNotCall
        }, Lead.SObjectType);

        Test.startTest();
        SObject resultRecord = converter.convert(sourceRecord);
        Test.stopTest();

        System.assertEquals(false, resultRecord.get(Lead.DoNotCall), 
            'Expected the correct converted string to boolean.');   
    }

    @isTest
    private static void canConvertFalseStringToFalse() {
        Lead sourceRecord = new Lead(
            Jigsaw = 'false'
        );

        conv_SObjectConverter converter = new GenericConverter(new Map<Schema.SObjectField, Schema.SObjectField> {
            Lead.Jigsaw => Lead.DoNotCall
        }, Lead.SObjectType);

        Test.startTest();
        SObject resultRecord = converter.convert(sourceRecord);
        Test.stopTest();

        System.assertEquals(false, resultRecord.get(Lead.DoNotCall), 
            'Expected the correct converted string to boolean.');   
    }

    private class GenericConverter extends conv_SObjectConverter {
        private Map<Schema.SObjectField, Schema.SObjectField> targetFieldBySourceFieldMap;
        private Schema.SObjectType objectType;

        public GenericConverter(Map<Schema.SObjectField, Schema.SObjectField> targetFieldBySourceFieldMap, 
            Schema.SObjectType objectType) {
            this.targetFieldBySourceFieldMap = targetFieldBySourceFieldMap;
            this.objectType = objectType;
        }

        protected override SObjectType getTargetSObjectType() {
            return this.objectType;
        }

        protected override Map<Schema.SObjectField, Schema.SObjectField> getTargetFieldBySourceFieldMap() {
            return this.targetFieldBySourceFieldMap;
        }
    }
}
