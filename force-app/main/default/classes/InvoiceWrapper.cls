public with sharing class InvoiceWrapper {
	
    public String Type;
    public String InvoiceNumber;         
	public date IssueDate;
	public date DueDate;
    public String Reference;
    public String CurrencyType;
    public ContactWrapper Contact;
    public List<LineItem> LineItems;
    
    public class LineItem{

        public String LineItemID;	
        public String Description;	
        public Decimal Quantity;
        public Decimal Price;
        public String AccountCode;	
        public String TaxType;	  	
        public Decimal TotalTax;	
        public Decimal TotalAmount;	
        
        public LineItem(){
            this.Description = 'Laptop';
        }
    }
    
    public InvoiceWrapper(Contact contact) {
        this.Type = 'ACCREC';
        this.Contact = new ContactWrapper(contact);
        this.CurrencyType = 'INR';
        this.LineItems = new List<LineItem>();
        this.LineItems.add(new LineItem());
    }
}