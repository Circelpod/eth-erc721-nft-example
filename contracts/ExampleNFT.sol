// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**
 * @title ExampleNFT
 * ExampleNFT - a contract for my non-fungible creatures.
 */
contract ExampleNFT is ERC721, ERC721Enumerable, Ownable {
    using Strings for uint256;
    bool public _isWhiteListSaleActive = false;
    bool public _isSaleActive = false;
    bool public _isAuctionActive = false;

    // Constants
    uint256 public constant MAX_SUPPLY = 999;

    uint256 public mintPrice = 0.9 ether;
    uint256 public whiteListPrice = 0.9 ether;
    uint256 public tierSupply = 129;
    uint256 public maxBalance = 1;
    uint256 public maxMint = 1;

    uint256 public auctionStartTime;
    uint256 public auctionTimeStep;
    uint256 public auctionStartPrice;
    uint256 public auctionEndPrice;
    uint256 public auctionPriceStep;
    uint256 public auctionStepNumber;

    string private _baseURIExtended = "https://";

    mapping(address => bool) public whiteList;

    event TokenMinted(uint256 supply);

    constructor() ERC721("ExampleNFT", "EXN") {}

    /**
     * switch to white list sale
     */
    function switchWhiteListSaleActive() public onlyOwner {
        _isWhiteListSaleActive = !_isWhiteListSaleActive;
    }

    /**
     * switch to sale
     */
    function switchSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    /**
     * switch to auction
     */
    function switchAuctionActive() public onlyOwner {
        _isAuctionActive = !_isAuctionActive;
    }

    /**
     * @dev Set the mint price.
     * @param _mintPrice the new mint price.
     */
    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    /**
     * @dev Set the white list price.
     * @param _whiteListPrice the new white list price.
     */
    function setWhiteListPrice(uint256 _whiteListPrice) public onlyOwner {
        whiteListPrice = _whiteListPrice;
    }

    /**
     * @dev Set the tier supply.
     * @param _tierSupply the new tier supply.
     */
    function setTierSupply(uint256 _tierSupply) public onlyOwner {
        tierSupply = _tierSupply;
    }

    /**
     * @dev Set the max balance.
     * @param _maxBalance the new max balance.
     */
    function setMaxBalance(uint256 _maxBalance) public onlyOwner {
        maxBalance = _maxBalance;
    }

    /**
     * @dev Set the max mint.
     * @param _maxMint the new max mint.
     */
    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }

    /**
     * @dev Set the auction start time.
     * @param _auctionStartTime the new auction start time.
     * @param _auctionTimeStep the new auction time step.
     * @param _auctionStartPrice the new auction start price.
     * @param _auctionEndPrice the new auction end price.
     * @param _auctionPriceStep the new auction price step.
     * @param _auctionStepNumber the new auction step number.
     */
    function setAuction(
        uint256 _auctionStartTime,
        uint256 _auctionTimeStep,
        uint256 _auctionStartPrice,
        uint256 _auctionEndPrice,
        uint256 _auctionPriceStep,
        uint256 _auctionStepNumber
    ) public onlyOwner {
        auctionStartTime = _auctionStartTime;
        auctionTimeStep = _auctionTimeStep;
        auctionStartPrice = _auctionStartPrice;
        auctionEndPrice = _auctionEndPrice;
        auctionPriceStep = _auctionPriceStep;
        auctionStepNumber = _auctionStepNumber;
    }

    /**
     * @dev Set the white list.
     * @param _whiteList the new white list address.
     */
    function setWhiteList(address[] calldata _whiteList) external onlyOwner {
        for (uint256 i = 0; i < _whiteList.length; i++) {
            whiteList[_whiteList[i]] = true;
        }
    }

    /**
     * @dev withdraw ether.
     * @param to to address.
     */
    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }

    /**
     * @dev Set preserve Mint.
     * @param numEXNs number of tokens.
     * @param to to address.
     */
    function preserveMint(uint256 numEXNs, address to) public onlyOwner {
        require(
            totalSupply() + numEXNs <= tierSupply,
            "Preserve mint would exceed tier supply"
        );
        require(
            totalSupply() + numEXNs <= MAX_SUPPLY,
            "Preserve mint would exceed max supply"
        );
        _mintExampleNFT(numEXNs, to);
        emit TokenMinted(totalSupply());
    }

    /**
     * @dev Get Total Supply.
     */
    function getTotalSupply() public view returns (uint256) {
        return totalSupply();
    }

    /**
     * @dev get ExampleNFT By Owner.
     * @param _owner the owner address.
     */
    function getExampleNFTByOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](tokenCount);
        for (uint256 i; i < tokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    /**
     * @dev get Auction Price.
     */
    function getAuctionPrice() public view returns (uint256) {
        if (!_isAuctionActive) {
            return 0;
        }
        if (block.timestamp < auctionStartTime) {
            return auctionStartPrice;
        }
        uint256 step = (block.timestamp - auctionStartTime) / auctionTimeStep;
        if (step > auctionStepNumber) {
            step = auctionStepNumber;
        }
        return
            auctionStartPrice > step * auctionPriceStep
                ? auctionStartPrice - step * auctionPriceStep
                : auctionEndPrice;
    }

    /**
     * @dev mint ExampleNFT.
     * @notice check sale active, tier supply, max supply, max balance, number of mint < max mint, payable amount.
     */
    function mintExampleNFT(uint256 numEXNs) public payable {
        require(_isSaleActive, "Sale must be active to mint ExampleNFT");
        require(
            totalSupply() + numEXNs <= tierSupply,
            "Sale would exceed tier supply"
        );
        require(
            totalSupply() + numEXNs <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        require(
            balanceOf(msg.sender) + numEXNs <= maxBalance,
            "Sale would exceed max balance"
        );
        require(numEXNs <= maxMint, "Sale would exceed max mint");
        require(numEXNs * mintPrice <= msg.value, "Not enough ether sent");
        _mintExampleNFT(numEXNs, msg.sender);
        emit TokenMinted(totalSupply());
    }

    /**
     * @dev white list mint ExampleNFT.
     * @notice check white list sale active, tier supply, max supply, max balance, number of mint < max mint, payable amount.
     */
    function whiteListMintExampleNFT(uint256 numEXNs) public payable {
        require(_isWhiteListSaleActive, "Sale must be active to mint ExampleNFT");
        require(
            totalSupply() + numEXNs <= tierSupply,
            "Sale would exceed tier supply"
        );
        require(
            totalSupply() + numEXNs <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        require(
            balanceOf(msg.sender) + numEXNs <= maxBalance,
            "Sale would exceed max balance"
        );
        require(numEXNs <= maxMint, "Sale would exceed max mint");
        uint256 price = mintPrice;
        if (whiteList[msg.sender] == true) {
            price = whiteListPrice;
            whiteList[msg.sender] = false;
        } else {
            revert("Not in white list");
        }
        require(numEXNs * price <= msg.value, "Not enough ether sent");
        _mintExampleNFT(numEXNs, msg.sender);
        emit TokenMinted(totalSupply());
    }

    /**
     * @dev auction mint ExampleNFT.
     * @notice check auction active, auction startTime, auction timeStep, auction startPrice, auction endPrice, auction priceStep, auction stepNumber, payable amount.
     */
    function auctionMintExampleNFT(uint256 numEXNs) public payable {
        require(_isAuctionActive, "Auction must be active to mint ExampleNFT");
        require(block.timestamp >= auctionStartTime, "Auction not start");
        require(
            totalSupply() + numEXNs <= tierSupply,
            "Auction would exceed tier supply"
        );
        require(
            totalSupply() + numEXNs <= MAX_SUPPLY,
            "Auction would exceed max supply"
        );
        require(
            balanceOf(msg.sender) + numEXNs <= maxBalance,
            "Auction would exceed max balance"
        );
        require(numEXNs <= maxMint, "Auction would exceed max mint");
        require(
            numEXNs * getAuctionPrice() <= msg.value,
            "Not enough ether sent"
        );
        _mintExampleNFT(numEXNs, msg.sender);
        emit TokenMinted(totalSupply());
    }

    /**
     * @dev private mint ExampleNFT.
     * @notice call safe mint.
     */
    function _mintExampleNFT(uint256 numEXNs, address recipient) internal {
        uint256 supply = totalSupply();
        for (uint256 i = 0; i < numEXNs; i++) {
            _safeMint(recipient, supply + i);
        }
    }

    /**
     * @dev set base url
     */
    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIExtended = baseURI_;
    }

    /**
     * @dev return base url
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIExtended;
    }

    /**
     * @dev return token uri
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return string(abi.encodePacked(_baseURI(), tokenId.toString()));
    }

    /**
     * @dev override [_beforeTokenTransfer]
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev override [supportsInterface]
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
