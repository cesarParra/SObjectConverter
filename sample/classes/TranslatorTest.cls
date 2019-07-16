@isTest
private class TranslatorTest {
    @isTest
    private static void testTranslation() {
        Lead sourceRecord = new Lead(
            Description = 'Yes'
        );  

        Test.startTest();
        SObject convertedRecord = new Translator().convert(sourceRecord);
        Test.stopTest();    

        System.assertEquals('Si', convertedRecord.get(Lead.Description), 
            'Expected the record to have been translated.');
    }
}