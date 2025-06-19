// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract RegionNFT is ERC721Enumerable {
    IERC20  public immutable gameToken;            // payment token
    address public immutable treasury;             // receiver of payments
    uint256 public constant PRICE = 10 ether;      // 10 GAME per mint

    string public baseMetadataURI;

    mapping(uint256 => uint8) private _templateOf;

    uint256 private _nextId = 1;                   // simple counter

    constructor(
        address _gameToken,
        address _treasury,
        string  memory _baseMetadataURI
    ) ERC721("WorldRegion", "REGION") {
        gameToken        = IERC20(_gameToken);
        treasury         = _treasury;
        baseMetadataURI  = _baseMetadataURI;
    }

    function claimRegion(uint8 templateId) external returns (uint256 tokenId) {
        require(templateId >= 1 && templateId <= 4, "INVALID_TEMPLATE");

        // Pull 10 GAME from caller
        require(
            gameToken.transferFrom(msg.sender, treasury, PRICE),
            "PAYMENT_FAILED"
        );

        tokenId = _nextId++;
        _safeMint(msg.sender, tokenId);
        _templateOf[tokenId] = templateId;
    }


    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_ownerOf(tokenId) != address(0), "NONEXISTENT_TOKEN");

        uint8 templateId = _templateOf[tokenId];
        return string.concat(
            baseMetadataURI,
            Strings.toString(templateId),
            ".json"
        );
    }

    function templateOf(uint256 tokenId) external view returns (uint8) {
        require(_ownerOf(tokenId) != address(0), "NONEXISTENT_TOKEN");
        return _templateOf[tokenId];
    }
}
