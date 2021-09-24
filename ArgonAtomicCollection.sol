pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ArgonAtomicCollection is
    ERC721URIStorage,
    IERC721Receiver,
    Ownable,
    ReentrancyGuard
{

    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using Strings for uint256;
    Counters.Counter private tokenCount;
    Counters.Counter private compoundCount;
    
       struct userNFTData {
        address owner;
        uint256[] tokenIds;
    }
    
    uint256 public price = 2 ether;
    uint256[] public remaining = [1];
    string public baseURI;
    mapping(address => userNFTData) public getUserNft;
    bool public paused;
    address payable public feeAddress;

    event Paused(bool paused);

    constructor(address payable _feeAddress)
        public
        ERC721("Argon Atomic Collection", "AAC")
    {
        require(_feeAddress != address(0));
        paused = true;
        feeAddress = _feeAddress;
    }

    modifier mustNotPaused() {
        require(!paused, "Paused!");
        _;
    }

    function changePause(bool _paused) public onlyOwner {
        paused = _paused;
        emit Paused(_paused);
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function addNumbers(uint256 count) public onlyOwner {
        for (uint256 i = remaining.length + 1; i <= count; i++) {
            remaining.push(i);
        }
    }

    function getRemainingNFTs() public view returns (uint256[] memory) {
        return remaining;
    }

    function getRemainingNFTsLength() public view returns (uint256) {
        return remaining.length;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function generateRandom() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        msg.sender,
                        block.timestamp,
                        block.number,
                        remaining,
                        remaining.length
                    )
                )
            );
    }

    function remove(uint256 index) private returns (uint256[] memory) {
        for (uint256 i = index; i < remaining.length - 1; i++) {
            remaining[i] = remaining[i + 1];
        }
        remaining.pop();
        return remaining;
    }

    function mint() external payable nonReentrant mustNotPaused {
        require(remaining.length > 0, "there is no nft");
        require(msg.value >= price);
        userNFTData storage user = getUserNft[msg.sender];
        uint256 newItemIndex = SafeMath.mod(
            generateRandom(),
            remaining.length,
            "SafeMath: error"
        );
        uint256 newItemId = remaining[newItemIndex];
        // require(msg.value >= price);
        _mint(msg.sender, newItemId);
        _setTokenURI(
            newItemId,
            string(
                abi.encodePacked(baseURI, Strings.toString(newItemId), ".json")
            )
        );
        user.tokenIds.push(newItemId);
        remaining[newItemIndex] = remaining[remaining.length - 1];
        remaining.pop();
        tokenCount.increment();
        feeAddress.transfer(msg.value);
    }

    function transferFromTokens(uint256[] memory tokenIDs)
        private
        nonReentrant
    {
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            safeTransferFrom(msg.sender, address(this), tokenIDs[i]);
        }
    }

    function createH2O(
        uint256 _h1,
        uint256 _h2,
        uint256 _o
    ) public nonReentrant {
        require(_h1 > 0 && _h1 <= 30);
        require(_h2 > 0 && _h2 <= 30);
        require(_o > 240 && _o <= 270);
        compoundCount.increment();
        tokenCount.increment();
        uint256[3] memory tokenIDs = [_h1, _h2, _o];
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            safeTransferFrom(msg.sender, address(this), tokenIDs[i]);
        }

        uint256 newId = tokenCount.current();
        _mint(msg.sender, newId);
        _setTokenURI(
            newId,
            string(abi.encodePacked(baseURI, "/compounds/H2O.json"))
        );
    }

    function createCO2(
        uint256 _c,
        uint256 _o1,
        uint256 _o2
    ) public nonReentrant {
        require(_o1 > 240 && _o1 <= 270);
        require(_o2 > 240 && _o2 <= 270);
        require(_c > 150 && _c <= 180);
        compoundCount.increment();
        tokenCount.increment();
        uint256[3] memory tokenIDs = [_o1, _o2, _c];
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            safeTransferFrom(msg.sender, address(this), tokenIDs[i]);
        }

        uint256 newId = tokenCount.current();
        _mint(msg.sender, newId);
        _setTokenURI(
            newId,
            string(abi.encodePacked(baseURI, "/compounds/CO2.json"))
        );
    }

    function createH2SO4(
        uint256 _h1,
        uint256 _h2,
        uint256 _s,
        uint256 _o1,
        uint256 _o2,
        uint256 _o3,
        uint256 _o4
    ) public nonReentrant {
        require(_s > 570 && _s <= 640);
        require(_o1 > 240 && _o1 <= 270);
        require(_o2 > 240 && _o2 <= 270);
        require(_o3 > 240 && _o3 <= 270);
        require(_o4 > 240 && _o4 <= 270);
        require(_h1 > 0 && _h1 <= 30);
        require(_h2 > 0 && _h2 <= 30);

        compoundCount.increment();
        tokenCount.increment();
        uint256[7] memory tokenIDs = [_h1, _h2, _s, _o1, _o2, _o3, _o4];
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            safeTransferFrom(msg.sender, address(this), tokenIDs[i]);
        }

        uint256 newId = tokenCount.current();
        _mint(msg.sender, newId);
        _setTokenURI(
            newId,
            string(abi.encodePacked(baseURI, "/compounds/H2SO4.json"))
        );
    }

    function createCaCO3(
        uint256 _ca,
        uint256 _c,
        uint256 _o1,
        uint256 _o2,
        uint256 _o3
    ) public nonReentrant {
        require(_ca > 721 && _ca <= 751);
        require(_c > 150 && _c <= 180);
        require(_o1 > 240 && _o1 <= 270);
        require(_o2 > 240 && _o2 <= 270);
        require(_o3 > 240 && _o3 <= 270);
        compoundCount.increment();
        tokenCount.increment();
        uint256[5] memory tokenIDs = [_ca, _c, _o1, _o2, _o3];
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            safeTransferFrom(msg.sender, address(this), tokenIDs[i]);
        }

        uint256 newId = tokenCount.current();
        _mint(msg.sender, newId);
        _setTokenURI(
            newId,
            string(abi.encodePacked(baseURI, "/compounds/CaCO3.json"))
        );
    }

    function createNaOH(
        uint256 _na,
        uint256 _o,
        uint256 _h
    ) public nonReentrant {
        require(_na > 330 && _na <= 360);
        require(_o > 240 && _o <= 270);
        require(_h > 0 && _h <= 30);
        compoundCount.increment();
        tokenCount.increment();
        uint256[3] memory tokenIDs = [_na, _o, _h];
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            safeTransferFrom(msg.sender, address(this), tokenIDs[i]);
        }

        uint256 newId = tokenCount.current();
        _mint(msg.sender, newId);
        _setTokenURI(
            newId,
            string(abi.encodePacked(baseURI, "/compounds/NaOH.json"))
        );
    }

    function createNaCl(uint256 _na, uint256 _cl) public nonReentrant {
        require(_na > 330 && _na <= 360);
        require(_cl > 640 && _cl <= 670);

        compoundCount.increment();
        tokenCount.increment();
        uint256[2] memory tokenIDs = [_na, _cl];
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            safeTransferFrom(msg.sender, address(this), tokenIDs[i]);
        }

        uint256 newId = tokenCount.current();
        _mint(msg.sender, newId);
        _setTokenURI(
            newId,
            string(abi.encodePacked(baseURI, "/compounds/NaCl.json"))
        );
    }

    function createHCl(uint256 _h, uint256 _cl) public nonReentrant {
        require(_cl > 640 && _cl <= 670);
        require(_h > 0 && _h <= 30);
        compoundCount.increment();
        tokenCount.increment();
        uint256[2] memory tokenIDs = [_h, _cl];
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            safeTransferFrom(msg.sender, address(this), tokenIDs[i]);
        }

        uint256 newId = tokenCount.current();
        _mint(msg.sender, newId);
        _setTokenURI(
            newId,
            string(abi.encodePacked(baseURI, "/compounds/HCl.json"))
        );
    }

    function crateHNO3(
        uint256 _h,
        uint256 _n,
        uint256 _o1,
        uint256 _o2,
        uint256 _o3
    ) public nonReentrant {
        require(_h > 0 && _h <= 30);
        require(_n > 180 && _n <= 210);
        require(_o1 > 240 && _o1 <= 270);
        require(_o2 > 240 && _o2 <= 270);
        require(_o3 > 240 && _o3 <= 270);
        compoundCount.increment();
        tokenCount.increment();
        uint256[5] memory tokenIDs = [_h, _n, _o1, _o2, _o3];
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            safeTransferFrom(msg.sender, address(this), tokenIDs[i]);
        }

        uint256 newId = tokenCount.current();
        _mint(msg.sender, newId);
        _setTokenURI(
            newId,
            string(abi.encodePacked(baseURI, "/compounds/HNO3.json"))
        );
    }

    function createKOH(
        uint256 _k,
        uint256 _o,
        uint256 _h
    ) public nonReentrant {
        require(_h > 0 && _h <= 30);
        require(_o > 240 && _o <= 270);
        require(_k > 671 && _k <= 721);
        compoundCount.increment();
        tokenCount.increment();
        uint256[3] memory tokenIDs = [_k, _o, _h];
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            safeTransferFrom(msg.sender, address(this), tokenIDs[i]);
        }

        uint256 newId = tokenCount.current();
        _mint(msg.sender, newId);
        _setTokenURI(
            newId,
            string(abi.encodePacked(baseURI, "/compounds/KOH.json"))
        );
    }

    function createSO2(
        uint256 _s,
        uint256 _o1,
        uint256 _o2
    ) public nonReentrant {
        require(_s > 570 && _s <= 640);
        require(_o1 > 240 && _o1 <= 270);
        require(_o2 > 240 && _o2 <= 270);
        compoundCount.increment();
        tokenCount.increment();
        uint256[3] memory tokenIDs = [_s, _o1, _o2];
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            safeTransferFrom(msg.sender, address(this), tokenIDs[i]);
        }

        uint256 newId = tokenCount.current();
        _mint(msg.sender, newId);
        _setTokenURI(
            newId,
            string(abi.encodePacked(baseURI, "/compounds/SO2.json"))
        );
    }

    function createHF(uint256 _h, uint256 _f) public nonReentrant {
        require(_h > 0 && _h <= 30);
        require(_f > 270 && _f <= 300);
        compoundCount.increment();
        tokenCount.increment();
        uint256[2] memory tokenIDs = [_h, _f];
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            safeTransferFrom(msg.sender, address(this), tokenIDs[i]);
        }

        uint256 newId = tokenCount.current();
        _mint(msg.sender, newId);
        _setTokenURI(
            newId,
            string(abi.encodePacked(baseURI, "/compounds/HF.json"))
        );
    }

    function createC6H12O6(
        uint256[6] memory _c,
        uint256[12] memory _h,
        uint256[6] memory _o
    ) public nonReentrant {
        compoundCount.increment();
        tokenCount.increment();
        for (uint256 i = 0; i < _c.length; i++) {
            require(_c[i] > 150 && _c[i] <= 180);
            safeTransferFrom(msg.sender, address(this), _c[i]);
        }

        for (uint256 x = 0; x < _h.length; x++) {
            require(_h[x] > 0 && _h[x] <= 30);
            safeTransferFrom(msg.sender, address(this), _h[x]);
        }

        for (uint256 y = 0; y < _o.length; y++) {
            require(_o[y] > 240 && _o[y] <= 270);
            safeTransferFrom(msg.sender, address(this), _o[y]);
        }

        uint256 newId = tokenCount.current();
        _mint(msg.sender, newId);
        _setTokenURI(
            newId,
            string(abi.encodePacked(baseURI, "/compounds/C6H12O6.json"))
        );
    }

    function createHArF(
        uint256 _h,
        uint256 _ar,
        uint256 _f
    ) public nonReentrant {
        require(_ar == 671);
        require(_h > 0 && _h <= 30);
        require(_f > 270 && _f <= 300);
        compoundCount.increment();
        tokenCount.increment();
        uint256[3] memory tokenIDs = [_h, _ar, _f];
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            safeTransferFrom(msg.sender, address(this), tokenIDs[i]);
        }

        uint256 newId = tokenCount.current();
        _mint(msg.sender, newId);
        _setTokenURI(
            newId,
            string(abi.encodePacked(baseURI, "/compounds/HArF.json"))
        );
    }
}
