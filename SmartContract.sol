pragma solidity ^0.4.25;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

}

contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;


    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount <= _balances[from]);

        _balances[from] = _balances[from].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
        return true;
    }



    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function _mint(address account, uint256 amount) public {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

}


 contract SharedOwenrship is ERC20 {
    
    uint256 public campaignCount;
    
    struct Campaign{
        address publisher;
        uint256 id;
        uint256 totalAmount;  // Campaign amount
        bool finished;
        bool activated;    // is Campaign live
        uint256 ownedByInvestorTotal;  // percentage owned by investors, initally 0 when contract gets activated and percentage*100 because of solidity limitation
        mapping (address => Investment) ownership; 
    }
    
    struct Investment{
        address investor;
        uint256 investAmount;
        uint256 ownershipPercent;
        uint256 intrest;
        bool isPaid;
        uint startDate;
    }
    
    mapping (uint256 => Campaign) public campaigns;
    
    constructor (string memory name, string memory symbol, uint8 decimals) public ERC20(name, symbol, decimals){
        campaignCount = 0;                        //postCount initialized to 0
    }
    
    function getCampaignCount() view public returns(uint256){
        return campaignCount;
    }
    function createCampaign(uint256 totalAmount, address publisher,uint256 campaignID) public {
       Campaign memory campaign= Campaign({publisher:publisher,totalAmount:totalAmount,finished:false,id:campaignCount,activated:false,ownedByInvestorTotal:0});
        campaigns[campaignID]=campaign;
        campaignCount++;
    }
    
    
    function investToCampaign(uint256 campaignID, uint256 ownershipPercent, address investor, uint256 investmentAmount,uint256 intrest) public {
        require(ownershipPercent+campaigns[campaignID].ownedByInvestorTotal<=100, "owned percentage went above 100");
        require(transferFrom(investor, campaigns[campaignID].publisher, investmentAmount)==true,"Wallet error");
        campaigns[campaignID].ownedByInvestorTotal += ownershipPercent;
        campaigns[campaignID].ownership[investor] = Investment({
            investor:investor,investAmount:investmentAmount,ownershipPercent:ownershipPercent,intrest:intrest,isPaid:false,startDate:now});
    }
    

    
    function newRepay(uint256 campaignID, address investor, uint256 daysDifference,uint256 amountWillingToPay) public {
        
        uint256 amountToPay = campaigns[campaignID].ownership[investor].investAmount+
            ((daysDifference/30)*(campaigns[campaignID].ownership[investor].investAmount)*(campaigns[campaignID].ownership[investor].intrest)/100)+
                ((daysDifference%30)*(campaigns[campaignID].ownership[investor].investAmount)*(campaigns[campaignID].ownership[investor].intrest)/(30*100));
        
        
        if (amountToPay == amountWillingToPay) {
            require(transferFrom(campaigns[campaignID].publisher, investor, amountToPay)==true,"Wallet error");
            campaigns[campaignID].ownership[investor].isPaid=true;
            campaigns[campaignID].ownedByInvestorTotal-= campaigns[campaignID].ownership[investor].ownershipPercent;
            
            if(campaigns[campaignID].ownedByInvestorTotal==0){
                deactivateCampaign(campaignID);
            }
            
        }
        else {
            //transferring the amountWillingToPay from fundRaiser to investor
            require(transferFrom(campaigns[campaignID].publisher, investor, amountWillingToPay)==true,"Wallet error");
            
            //now the investAmount = amountToPay - amountWillingToPay
            campaigns[campaignID].ownership[investor].investAmount = amountToPay - amountWillingToPay;
            
            //the following is formula for calculating amount of percentage to be transferred from fundRaiser to investor
            uint256 ownershipGainedByRepaying = (((amountWillingToPay*100) / amountToPay)*(campaigns[campaignID].ownership[investor].ownershipPercent))/100;
            
            //thus the same amount of percentage is deducted from ownedByInvestorTotal and investor.ownershipPercent
            campaigns[campaignID].ownedByInvestorTotal -= ownershipGainedByRepaying;
            campaigns[campaignID].ownership[investor].ownershipPercent -= ownershipGainedByRepaying;
        }
        
    }
    
    
    function deactivateCampaign(uint256 campaignID) public {
        require(campaigns[campaignID].ownedByInvestorTotal==0,"Clear all dues");
        campaigns[campaignID].finished=true;
    }
    
}
