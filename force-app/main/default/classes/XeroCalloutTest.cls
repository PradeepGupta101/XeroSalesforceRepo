@isTest
private class XeroCalloutTest {
    @isTest
    static void tenantIdTest(){

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpMockFactory('[{"id":"1e95b4b8-8215-44c5-8243-028cb7b37ce3","authEventId":"7afbbfcc-bd43-4ef0-bea7-9a4a5f746832","tenantId":"012f16a4-dbd7-41e6-925d-e459b23c1804","tenantType":"ORGANISATION","tenantName":"Demo Company (Global)","createdDateUtc":"2023-04-27T04:59:47.0195430","updatedDateUtc":"2023-04-27T04:59:47.0206660"}]','OK',200));
            String tenantId = XeroCallout.getTenantId('Contacts');
        Test.stopTest();

        Assert.areNotEqual('0',tenantId,'Tenant id Not returned!');
        Assert.areEqual('012f16a4-dbd7-41e6-925d-e459b23c1804',tenantId,'Tenant id returned is not correct!');
    }
    
    @isTest
    static void tenantIdTestNegative(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpMockFactory('0','Error',400));
            String tenantId = XeroCallout.getTenantId('Contac');
        Test.stopTest();

        Assert.areEqual('0',tenantId,'Tenant Id returned!');
    }

    @isTest
    static void xeroDataTest(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpMockFactory('({AmountCredited=0.00, AmountDue=396.00, AmountPaid=0.00, BrandingThemeID=d613f7f9-8fcb-477f-97f0-31eb85b7e5cf, Contact={Addresses=(), ContactGroups=(), ContactID=5b96e86b-418e-48e8-8949-308c14aec278, ContactPersons=(), HasValidationErrors=false, Name=Marine Systems, Phones=()}, CreditNotes=(), CurrencyCode=USD, CurrencyRate=1.0000000000, Date=/Date(1681603200000+0000)/, DateString=2023-04-16T00:00:00})','OK',200));
            String xeroData = XeroCallout.getXeroData('GET', 'Contacts', 'testTenantId');
        Test.stopTest();

        System.debug(xeroData);
    }
}