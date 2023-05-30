public with sharing class ContactWrapper{	
    public String ContactID;
    public String Name;         // Full name of contact/organisation
	public String FirstName;
	public String LastName;
	public String EmailAddress;
    public String BankAccountDetails;
    public Boolean IsSupplier;
	public Boolean IsCustomer;
    public List<Address> Addresses;
    public List<Phone> Phones;
	
    public class Address{
         public String mailingCity;
         public String mailingRegion;
         public String mailingPostalCode;
         public String mailingCountry;
         public String AddressType;

        
        public Address(Contact contact) {
            this.AddressType = 'STREET';
            this.mailingCity = contact.MailingCity;
            this.mailingRegion = contact.MailingState;
            this.mailingPostalCode = contact.MailingPostalCode;
            this.mailingCountry = contact.MailingCountry;
        }
    }
    
    public class Phone {
        public String PhoneType;
        public String PhoneNumber;
        
        public Phone(String phoneNumber) {
            this.PhoneType = 'MOBILE';
            this.PhoneNumber = phoneNumber;
        }  
    }
    
    public ContactWrapper(Contact record) {
        this.Name = record.FirstName +' '+ record.LastName;
        this.FirstName = record.FirstName;
        this.LastName = record.LastName;
        this.EmailAddress = record.Email;
        this.Phones = new List<Phone>();
        this.Phones.add(new Phone(record.Phone));
        this.Addresses = new List<Address>();
        this.Addresses.add(new Address(record)); 
        }
    
}