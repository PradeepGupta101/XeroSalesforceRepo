public with sharing class ContactWrapper{	
    public String name;
	public String firstName;
	public String lastName;
	public String emailAddress;
    public String bankAccountDetails;
    public Boolean isSupplier;
	public Boolean isCustomer;
    public List<Address> addresses;
    public List<Phone> phones;
	
    public class Address{
         public String city;
         public String region;
         public String postalCode;
         public String country;
         public String addressType;
         public String addressLine1;
        
        public Address(Contact contact) {
            this.addressType = 'POBOX';
            this.addressLine1 = String.valueOf(contact.MailingStreet);
            this.city = String.valueOf(contact.MailingCity);
            this.region = String.valueOf(contact.MailingState);
            this.postalCode = String.valueOf(contact.MailingPostalCode);
            this.country = String.valueOf(contact.MailingCountry);
        }
    }
    
    public class Phone {
        public String phoneType;
        public String phoneNumber;
        
        public Phone(String phoneNumber) {
            this.phoneType = 'MOBILE';
            this.phoneNumber = phoneNumber;
        }  
    }
    
    public ContactWrapper(Contact record) {
        this.name = record.FirstName +' '+ record.LastName;
        this.firstName = record.FirstName;
        this.lastName = record.LastName;
        this.emailAddress = record.Email;
        this.Phones = new List<Phone>();
        this.phones.add(new Phone(record.Phone));
        this.Addresses = new List<Address>();
        this.addresses.add(new Address(record)); 
        }
    
}