pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ArgonAtomicMarketPlace is ReentrancyGuard {
    
    using SafeMath for uint256;
      
    struct Sale{
        uint tokenID;
        address owner;
        uint price;
    }
    uint[] public sales;
    mapping(uint => Sale) public IDtoSale;
    mapping(uint => bool) public isOnSale;
    address payable public feeAddress;
    IERC721 public ArgonAtomicCollection;
    uint public feeRate;
    uint public putFeeRate;
    
      constructor(address payable _feeAddress, IERC721 _ArgonAtomicCollection, uint _feeRate, uint _putFeeRate)
        public
    {
        require(_feeAddress != address(0));
        feeAddress = _feeAddress;
        ArgonAtomicCollection = _ArgonAtomicCollection;
        feeRate = _feeRate;
        putFeeRate = _putFeeRate;
    }
    
    
    modifier onlySeller(uint _tokenID) {
        Sale storage sale = IDtoSale[_tokenID];
        require(sale.owner == msg.sender);
        _;
    }
    
    function getSales() public view returns(uint[] memory) {
        return sales;
    }
    
    function getSaleData(uint _tokenID) public view returns(uint, address, uint) {
                Sale memory sale = IDtoSale[_tokenID];
                return (sale.tokenID, sale.owner, sale.price);

    }
    
    function putSale(uint _tokenID, uint _price) public nonReentrant {
         uint putFee = _price.mul(putFeeRate).div(1e6);
        //require(msg.value >= putFee);
        require(!isOnSale[_tokenID]);
        Sale memory newSale = Sale(
            _tokenID, msg.sender, _price);
        sales.push(_tokenID);
        isOnSale[_tokenID] = true;
        IDtoSale[_tokenID] = newSale;
        //feeAddress.transfer(putFee);
        ArgonAtomicCollection.transferFrom(msg.sender, address(this), _tokenID);
        
    }
    
    function cancelSale(uint _tokenID) public onlySeller(_tokenID) nonReentrant {
        require(isOnSale[_tokenID]);
        isOnSale[_tokenID] = false;
        ArgonAtomicCollection.transferFrom(address(this), msg.sender, _tokenID);
        
    }
    
    function changePrice(uint _tokenID, uint _newPrice) public onlySeller(_tokenID) nonReentrant {
        Sale memory sale = IDtoSale[_tokenID];
        sale.price = _newPrice;
        IDtoSale[_tokenID] = sale;

        
    }
    
    function buy(uint _tokenID) public payable nonReentrant {
        Sale memory sale = IDtoSale[_tokenID];
        uint price = sale.price;
        uint fee = feeRate.mul(price).div(1e6);
        address owner = sale.owner;
        //require(msg.value >= price);
        require(isOnSale[_tokenID]);
        isOnSale[_tokenID] = false;
        Sale memory newSale = Sale(_tokenID, msg.sender, 0);
        IDtoSale[_tokenID] = newSale;
        feeAddress.transfer(fee);
        payable(owner).transfer(price.add(fee));
        ArgonAtomicCollection.transferFrom(address(this), msg.sender, _tokenID);

    }
    
}
