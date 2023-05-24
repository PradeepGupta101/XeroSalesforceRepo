public with sharing class ContactWrapper{

    public String ContactNumber; // Identify Contact in External System
	public String Name;         // Full name of contact/organisation
	public String FirstName;
	public String LastName;
	public String EmailAddress;
	
    public ContactWrapper(Contact record) {
        this.ContactNumber = record.ID;
        this.Name = record.Name;
        this.FirstName = record.FirstName;
        this.LastName = record.LastName;
        this.EmailAddress = record.Email;
    }
}
