//SPDX-License-Identifier: UNLICENSED

/*
    ______                  _    ______                         
    |  _  \                | |   | ___ \                        
    | | | |___  _ __  _   _| |_  | |_/ /_   _ _ __  _ __  _   _ 
    | | | / _ \| '_ \| | | | __| | ___ \ | | | '_ \| '_ \| | | |
    | |/ / (_) | | | | |_| | |_  | |_/ / |_| | | | | | | | |_| |
    |___/ \___/|_| |_|\__,_|\__| \____/ \__,_|_| |_|_| |_|\__, |
                                                           __/ |
    NFT Contract                                          |___/ 

    The factory contract for the Donut Bunny NFT

    Website: DonutBunny.net
                                                                                            
    Render Code Format = bgColour, lineColour, doughColour, icingColour, toppingColour, faceSet, shapeSet, icingSet, toppingSet

*/

pragma solidity ^0.8.4;

import "./token/ERC721/extensions/ERC721URIStorage.sol";
import "./token/ERC721/extensions/ERC721Enumerable.sol";
import "./access/Ownable.sol";
import "./utils/Base64.sol";

contract IDonutBunnyBuilder {
    function buildBunny(uint256 points) public view returns (string memory, string memory, uint256[10] memory) {}
    function paintBunny(uint256[5] memory colourSet, uint256[5] memory lockedSet) public view returns (string memory, string memory, uint256[10] memory){}
}
contract IDonutBunnyRender {
    function renderBunny(uint256[10] memory renderCode, string memory bunnyName) public pure returns (string memory) {}
}
contract IDonutToken {
    function swapForMint(address account, uint256 amount) external returns (uint256) {}
}

contract DonutBunny is ERC721, ERC721URIStorage, ERC721Enumerable, Ownable {
    using Strings for uint256;

    mapping(string => bool) private mintedRenderCodes;
    mapping(uint256 => uint256[10]) private tokenRenderCode;
    mapping(uint256 => string) private tokenRenderCodeS;
    mapping(uint256 => string) private tokenConfig;

    address immutable dbBuilderAddress = address(0x8f26D3eF8437C1D10b118D7F75D33e7d01Da59b6);
    address immutable dbRenderAddress = address(0x6d5783a1d14ab3B52a613A9A9157e2ac4A7900Dc);
    address immutable dTokenAddress = address(0x8C4A71D0F7A4cD2A1CaFB55f57f53C9E08a79bDA);
    address feeRec = address(0x4302B4Ad74b0cFfE844F881dc1471dEA6d52be33);

    uint256 maxSupply = 1500;
    uint256 tokenCost = 500000000000000000000;
    string extURL = "https://donutbunny.net/view/";
    event PermanentURI(string _value, uint256 indexed _id);

    constructor () ERC721('Donut Bunny', 'DONUTBUNNY') {}
    
    function changeMintCost(uint256 newCost) public virtual onlyOwner {
        tokenCost = newCost;
    }

    function changeFeeRec(address newRec) public virtual onlyOwner {
        feeRec = newRec;
    }

    function changeExtURL(string memory newURL) public virtual onlyOwner {
        extURL = newURL;
    }

    // Return overall NFT contract info JSON Array
    function contractURI() public view returns (string memory) {
        string memory mainSVG = '<svg xmlns="http://www.w3.org/2000/svg" class="intro-svg" viewBox="0 0 30.69 38.13"><g class="bunny"><path fill="#f6e4d9" stroke="#807bb4" stroke-linecap="round" stroke-linejoin="round" stroke-miterlimit="10" d="M5.1.5C1.56.3-1.08 4.29 1.6 9.37c1.58 3 4.48 5.79 4.48 5.79a12.9 12.9 0 0 0-4.15 9.56c0 7.14 6.01 12.92 13.43 12.92S28.8 31.85 28.8 24.71c0-3.71-1.55-7.2-4.15-9.56 0 0 2.86-2.8 4.46-5.79C32.15 3.7 28.3-.8 24.05.86c-4.55 1.78-5.38 10.81-5.42 11.32a13.97 13.97 0 0 0-6.51 0c-.05-.55-.88-9.55-5.45-11.32A5.1 5.1 0 0 0 5.11.5Zm10.2 19.83c2.32 0 4.2 1.82 4.2 4.06a4.14 4.14 0 0 1-4.2 4.06 4.14 4.14 0 0 1-4.2-4.06 4.13 4.13 0 0 1 4.2-4.06z"/><path fill="#edbec2" d="M15.17 13.27c-.97 0-1.86.54-2.3 1.4a2.6 2.6 0 0 0-1.63-.53 2.55 2.55 0 0 0-2.5 2.8 2.57 2.57 0 0 0-3.27 1.9 2.5 2.5 0 0 0 .45 2.04 2.52 2.52 0 0 0-1.25 4.48 2.5 2.5 0 0 0-.6 2.44 2.56 2.56 0 0 0 2.06 1.8 2.48 2.48 0 0 0-.16 1.82A2.58 2.58 0 0 0 8.9 33.2a2.56 2.56 0 0 0 2.56 2.26 2.6 2.6 0 0 0 1.48-.46 2.58 2.58 0 0 0 4.63-.36 2.59 2.59 0 0 0 4.4-1.83l-.01-.23.22.06c1.4.28 2.76-.6 3.04-1.96a2.5 2.5 0 0 0-.45-2.03 2.52 2.52 0 0 0 2.12-3.2A2.52 2.52 0 0 0 25.76 24a2.5 2.5 0 0 0-1.08-4.35c.18-.5.2-1.03.04-1.54a2.58 2.58 0 0 0-2.93-1.78 2.59 2.59 0 0 0-4.3-1.6 2.58 2.58 0 0 0-2.32-1.46zm.11 6.62c2.6 0 4.7 2.03 4.7 4.53 0 2.5-2.1 4.54-4.7 4.54a4.62 4.62 0 0 1-4.69-4.54c0-2.5 2.1-4.53 4.7-4.53z"/><path fill="#2a3154" d="M17.7 15.92c0 .36.24.65.54.65.3 0 .55-.3.55-.65 0-.36-.25-.65-.55-.65-.3 0-.54.29-.54.65m-5 0c0 .36.24.65.54.65.3 0 .55-.3.55-.65 0-.36-.25-.65-.55-.65-.3 0-.54.29-.54.65"/><path fill="none" stroke="#2a3154" stroke-linecap="round" stroke-linejoin="round" stroke-miterlimit="10" stroke-width=".48" d="m16.55 15.99-.85.7-.85-.7m.85.84v.7m1.29-.33s-1.32 1.5-2.58-.05"/><path fill="none" stroke="#7c77b2" stroke-linecap="round" stroke-linejoin="round" stroke-miterlimit="10" stroke-width=".9" d="m12.66 30.15-.1 1.5m5.54-1.17-1.43.46m-.41 2.95-1.5-.14m7.96-4.73-.68-1.34m-1.52 4.96.43-1.45m2.99-9.54.43-1.45m-16.31.83-1.1-1.04M21.76 24l-.24-1.49m-11.4-.77-.25 1.49m15.36 2.37-1.49.16M6.62 24.6l-1.16.96m3.84 1.82-1.5-.1m1.95 4.49L9.1 30.4" class="sprinkle"/></g></svg>';

        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                           '{"name" : "Donut Bunny",',
                           ' "description" : "Donut Bunnys are a unique fully on chain NFT that is minted and stored entirely on chain. Own your first real NFT today!",',
                           ' "external_link" : "https://donutbunny.net",',
                           ' "seller_fee_basis_points" : "100",',
                           ' "fee_recipient" : "', feeRec ,'",',
                           ' "image" : "data:image/svg+xml;base64,', Base64.encode(bytes(mainSVG)), '"}'
                        )
                    )
                )
            )
        );
    }

    // Return specific NFT info JSON Array
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        IDonutBunnyRender dbRender;
        dbRender = IDonutBunnyRender(dbRenderAddress);

        string memory name = string(abi.encodePacked('Bunny #',tokenId.toString()));
        string memory description = string(abi.encodePacked("I am a Donut Bunny - minted, generated and stored 100% on-chain forever! My Bunny Render Code is ", tokenRenderCodeS[tokenId]));
        
        // If this is a rare Donut Bunny
        if (tokenRenderCode[tokenId][9] == 1){
            description = string(abi.encodePacked("I am a RARE EDITION Donut Bunny - minted, generated and stored 100% on-chain forever! My Bunny Render Code is ", tokenRenderCodeS[tokenId]));
        }
       
        // Render the SVG from the render code
        string memory bunnySVG = dbRender.renderBunny(tokenRenderCode[tokenId], name);

        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                           '{"name" : "', name, '",',
                           ' "description" : "', description, '",',
                           ' "external_url" : "', extURL, '",',
                           ' "attributes" : [', tokenConfig[tokenId], '],',
                           ' "image" : "data:image/svg+xml;base64,', Base64.encode(bytes(bunnySVG)), '"}'
                        )
                    )
                )
            )
        );
    }

    // Mint a new Donut Bunny
    function mint() public {
        uint256 tSupply = totalSupply();
        require(tSupply <= maxSupply, "SOLD OUT FOREVER - There are no more Donut Bunnys left, check out our next collection at DonutToken.net");

        string memory bunnyConfig;
        string memory bunnyRenderCodeS;
        uint256[10] memory bunnyRenderCode;

        IDonutToken dToken;
        dToken = IDonutToken(dTokenAddress);

        // Call function on Donut Token contract to deduct the tokens from wallet - fail if no balance
        uint256 points = dToken.swapForMint(_msgSender(), tokenCost);

        IDonutBunnyBuilder dbBuilder;
        dbBuilder = IDonutBunnyBuilder(dbBuilderAddress);
        
        bool foundNewBunny = false;

        // Loop until a new unique Donut Bunny render code is generated
        while (!foundNewBunny) {
            (bunnyConfig, bunnyRenderCodeS, bunnyRenderCode) = dbBuilder.buildBunny(points);

            if (mintedRenderCodes[bunnyRenderCodeS] == false){
                foundNewBunny = true;
                mintedRenderCodes[bunnyRenderCodeS] = true;
            }
        }

        uint256 theId = tSupply + 1;

        // Save NFT data
        tokenRenderCodeS[theId] = bunnyRenderCodeS;
        tokenRenderCode[theId] = bunnyRenderCode;
        tokenConfig[theId] = bunnyConfig;

        _mint(_msgSender(), theId);
    }

    // Apply a colour change item to a Donut Bunny
    function usePaintbrush(uint256 tokenId, uint256[5] memory newColourConfig) public {
        require(_msgSender() == ownerOf(tokenId), "Only the current owner of this Donut Bunny NFT can do this!");

        string memory bunnyConfig;
        string memory bunnyRenderCodeS;
        uint256[10] memory bunnyRenderCode;
        uint256[5] memory lockedSet;

        // Grab the config for the NFT - these cannot be modified by paintbrush
        lockedSet[0] = tokenRenderCode[tokenId][5];
        lockedSet[1] = tokenRenderCode[tokenId][6];
        lockedSet[2] = tokenRenderCode[tokenId][7];
        lockedSet[3] = tokenRenderCode[tokenId][8];
        lockedSet[4] = tokenRenderCode[tokenId][9];

        IDonutBunnyBuilder dbBuilder;
        dbBuilder = IDonutBunnyBuilder(dbBuilderAddress);

        (bunnyConfig, bunnyRenderCodeS, bunnyRenderCode) = dbBuilder.paintBunny(newColourConfig, lockedSet);

        // Save the NFT data
        tokenRenderCodeS[tokenId] = bunnyRenderCodeS;
        tokenRenderCode[tokenId] = bunnyRenderCode;
        tokenConfig[tokenId] = bunnyConfig;
    }

    // Return only the SVG data for a specific token ID
    function tokenSVG(uint256 tokenId) public view virtual returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        IDonutBunnyRender dbRender;
        dbRender = IDonutBunnyRender(dbRenderAddress);

        string memory name = string(abi.encodePacked('Bunny #',tokenId.toString()));

        return string(dbRender.renderBunny(tokenRenderCode[tokenId], name));
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        _burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
}