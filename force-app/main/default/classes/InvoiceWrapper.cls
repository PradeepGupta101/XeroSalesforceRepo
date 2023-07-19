public with sharing class InvoiceWrapper {
	
    public String type;
    public String invoiceNumber;         
	public date issueDate;
	public date dueDate;
    public String reference;
    public String currencyType;
    //public ContactWrapper Contact;
    public List<LineItem> lineItems;
    
    public class LineItem{

        public String lineItemID;	
        public String description;	
        public Decimal quantity;
        public Decimal price;
        public String accountCode;	
        public String taxType;	  	
        public Decimal totalTax;	
        public Decimal totalAmount;	
        
        public LineItem(InvoiceLine invLine){
            this.description = 'Laptop';
            this.quantity = invLine.Quantity;
            this.price = invLine.LineAmount;
            this.accountCode = invLine.TaxCode;
            this.taxType = 'GST';
            this.totalTax = invLine.TaxAmount;
            this.totalAmount = invLine.LineAmount + invLine.TaxAmount;
        }
    }
    
    public InvoiceWrapper(Invoice invoiceRecord) {
        this.type = 'ACCREC';
        //this.Contact = new ContactWrapper(contact);
        this.currencyType = 'INR';
        this.invoiceNumber = invoiceRecord.InvoiceNumber;
        this.issueDate = invoiceRecord.InvoiceDate;
        this.dueDate = invoiceRecord.DueDate;
        this.reference = invoiceRecord.ReferenceEntityId;
        this.lineItems = new List<LineItem>();
        for(InvoiceLine invLine : invoiceRecord.InvoiceLines){
            this.lineItems.add(new LineItem(invLine));
        }
    }
}