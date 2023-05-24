public with sharing class ContactWrapper{	
    public String Name;         // Full name of contact/organisation
	public String FirstName;
	public String LastName;
	public String EmailAddress;
	public String Phone;
	
    public ContactWrapper(Contact record) {
        this.Name = record.FirstName +' '+ record.LastName;
        this.FirstName = record.FirstName;
        this.LastName = record.LastName;
        this.EmailAddress = record.Email;
        this.Phone = record.Phone; 
    }
}