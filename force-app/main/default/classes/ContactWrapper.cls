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
         public String City;
         public String Region;
         public String PostalCode;
         public String Country;
         public String AddressType;
        
        public Address(Contact contact, String AddressType) {
            this.AddressType = AddressType;
            this.City = contact.MailingCity;
            this.Region = contact.MailingState;
            this.PostalCode = contact.MailingPostalCode;
            this.Country = contact.MailingCountry;
        }
    }
    
    public class Phone {
        public String PhoneType;
        public String PhoneNumber;
        
        public Phone(String phoneType,String phoneNumber) {
            this.PhoneType = phoneType;
            this.PhoneNumber = phoneNumber;
        }  
    }
    
    public ContactWrapper(Contact record) {
        this.Name = record.FirstName +' '+ record.LastName;
        this.FirstName = record.FirstName;
        this.LastName = record.LastName;
        this.EmailAddress = record.Email;
        this.Phones = new List<Phone>();
        this.Phones.add(new Phone('MOBILE',record.Phone));
        this.Addresses = new List<Address>();
        this.Addresses.add(new Address(record,'STREET'));
        }
    
}