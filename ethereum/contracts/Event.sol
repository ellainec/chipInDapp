pragma solidity ^0.4.24;

contract EventFactory {

    address[] public deployedEvents;

    function createEvent(uint dateOfEvent, uint eventGracePeriod) public payable {
        address newEvent = new Event(msg.sender, dateOfEvent, msg.value, eventGracePeriod);
        deployedEvents.push(newEvent);
    }

    function getDeployedEvents() public view returns (address[]) {
        return deployedEvents;
    }
}
contract Event {

    struct Invoice {
        string name;
        string description;
        uint amount;
        bool paidOut;
        address recipient;
    }

    address public organizer;
    uint public contribution;
    uint public eventDate;
    mapping(address => bool) public attendees;
    uint gracePeriod;
    Invoice[] public invoices;

    constructor(address eventOrganizer, uint dateOfEvent, uint contributionAmount, uint eventGracePeriod) public payable {
        organizer = eventOrganizer;
        contribution = contributionAmount;
        eventDate = dateOfEvent;
        gracePeriod = eventGracePeriod;
    }

    function contribute () public payable {
        require(msg.value == contribution);
        attendees[msg.sender] = true;
    }

    function createInvoice(string name, string description, uint amount) public {
        require(attendees[msg.sender] || msg.sender == organizer);
        Invoice memory newInvoice = Invoice({
            name: name,
            description: description,
            amount: amount,
            recipient: msg.sender,
            paidOut: false
            });

        invoices.push(newInvoice);
    }

    function approveInvoice(uint invoiceNumber) public {
        Invoice storage invoice = invoices[invoiceNumber];
        require(msg.sender == organizer || (attendees[msg.sender] && now > eventDate + gracePeriod));
        require(!invoice.paidOut);
        invoice.paidOut = true;
        invoice.recipient.transfer(invoice.amount);
    }

}