@isTest
private with sharing class XeroOrchestratorTest {
    @TestSetup
    static void setup(){

        List<User> usersList = new List<User>();

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        usersList.add(new User(Username='akumar@testorg.com',TimeZoneSidKey='Asia/Kolkata',LocaleSidKey='en_IN',EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',Alias='AKumar',LastName='Kumar',Email='akumar123@testemail.com',ProfileId = p.Id));
        usersList.add(new User(Username='prao@testorg.com',TimeZoneSidKey='Asia/Kolkata',LocaleSidKey='en_IN',EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',Alias='PRao',LastName='Rao',Email='prao123@testemail.com',ProfileId = p.Id)); 

        insert usersList;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Xero_Integration_Read'];
        insert new PermissionSetAssignment(AssigneeId = usersList[0].id, PermissionSetId = ps.Id);
    }


    @isTest
    static void testForPermission(){
        User u = [SELECT Id FROM User WHERE LastName='Rao'];
        System.runAs(u){
            Test.startTest();
                String response = XeroOrchestrator.connectToXero('Contacts');
            Test.stopTest();

            Assert.areEqual('User does not have sufficiant access!',response,'User without permission allowed to access the data!');
        }
    }

    @isTest
    static void testForTenantId(){
        User u = [SELECT Id FROM User WHERE LastName='Kumar'];
        System.runAs(u){
            Test.startTest();
                String response = XeroOrchestrator.connectToXero('Conta');
            Test.stopTest();

            Assert.areEqual('There was some problem in retriving the Tenant Id',response,'Tenant Id retrieved on providing wrong resource!');
        }
    }

    @isTest
    static void testForXeroData(){
        User u = [SELECT Id FROM User WHERE LastName='Kumar'];

        System.runAs(u){
            Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new HttpMockFactory());
                String data = XeroOrchestrator.connectToXero('Contacts');
                
                Assert.areEqual('Data Present',data,'Data did not return!');
                
            Test.stopTest();
        }
    }

}