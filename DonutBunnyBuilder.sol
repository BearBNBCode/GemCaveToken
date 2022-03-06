//SPDX-License-Identifier: UNLICENSED

/*
    ______                  _    ______                         
    |  _  \                | |   | ___ \                        
    | | | |___  _ __  _   _| |_  | |_/ /_   _ _ __  _ __  _   _ 
    | | | / _ \| '_ \| | | | __| | ___ \ | | | '_ \| '_ \| | | |
    | |/ / (_) | | | | |_| | |_  | |_/ / |_| | | | | | | | |_| |
    |___/ \___/|_| |_|\__,_|\__| \____/ \__,_|_| |_|_| |_|\__, |
                                                           __/ |
    Render Code Builder Contract                          |___/ 

    Returns a randomly generated Donut Bunny Render Code.
              
    Website: DonutBunny.net
                                                                                  
    Render Code Format = bgColour, lineColour, doughColour, icingColour, toppingColour, faceSet, shapeSet, icingSet, toppingSet

*/
pragma solidity ^0.8.4;

contract DonutBunnyBuilder {

  function random(uint256 odds) private view returns (uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(
        block.timestamp + block.difficulty +
        ((uint256(keccak256(abi.encodePacked(odds)))) / (block.timestamp)) +
        block.gaslimit + 
        ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
        block.number
    )));

    return ((seed - ((seed / 1000) * 1000)) % odds);
  }

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
      if (_i == 0) {
          return "0";
      }
      if (_i == 1) {
          return "1";
      }
      if (_i == 2) {
          return "2";
      }
      if (_i == 3) {
          return "3";
      }
      if (_i == 4) {
          return "4";
      }
      if (_i == 5) {
          return "5";
      }
      if (_i == 6) {
          return "6";
      }
      if (_i == 7) {
          return "7";
      }
      if (_i == 8) {
          return "8";
      }
      if (_i == 9) {
          return "9";
      }
      if (_i == 10) {
          return "10";
      }

      return string("999");
  }

  struct colourOptions {
    string[6] bgColour;
    string[3] lineColour;
    string[4] doughColour;
    string[4] icingColour;
    string[5] toppingColour;
  }

  struct colourRolls {
    uint256 bgColourR;
    uint256 lineColourR;
    uint256 doughColourR;
    uint256 icingColourR;
    uint256 toppingColourR;
  }

  struct donutOptions {
    string[5] faceSet;
    string[2] shapeSet;
    string[5] icingSet;
    string[5] toppingSet;
  }

 struct donutRolls {
    uint256 faceSetR;
    uint256 shapeSetR;
    uint256 icingSetR;
    uint256 toppingSetR;
  }

  function buildBunny(uint256 points) public view returns(string memory, string memory, uint256[10] memory){
    colourOptions memory colourOptionsA;
    colourRolls memory colourRollsA;
    donutOptions memory donutOptionsA;
    donutRolls memory donutRollsA;

    uint256 rareMode = 0;

    if (random(564) == 123) {
      rareMode = 1;
    }
    if (points > 1) {
      if (random(689) == 321) {
        rareMode = 1;
      }
    }
    if (points > 50) {
      if (random(642) == 420) {
        rareMode = 1;
      }
    }
    if (points > 100) {
      if (random(555) == 420) {
        rareMode = 1;
      }
    }
    if (points > 200) {
      if (random(250) == 144) {
        rareMode = 1;
      }
    }

    colourOptionsA.bgColour      = ['Blue', 'Green', 'Pink', 'Orange', 'Yellow', 'Purple'];
    colourOptionsA.lineColour    = ['Purple', 'Blue', 'Orange'];
    colourOptionsA.doughColour   = ['Chocolate', 'Oat', 'Vanilla', 'RARE'];
    colourOptionsA.icingColour   = ['Strawberry', 'Pinkberry', 'Banana', 'Blueberry'];
    colourOptionsA.toppingColour = ['Purple', 'White', 'Pink', 'Blue', 'Yellow'];
    
    colourRollsA.bgColourR       = random(colourOptionsA.bgColour.length);
    colourRollsA.lineColourR     = random(colourOptionsA.lineColour.length);
    colourRollsA.doughColourR    = random(colourOptionsA.doughColour.length - 1);
    colourRollsA.icingColourR    = random(colourOptionsA.icingColour.length);
    colourRollsA.toppingColourR  = random(colourOptionsA.toppingColour.length);

    donutOptionsA.faceSet     = ['Love', 'Bunny', 'Shocked', 'Cute', 'Dizzy'];
    donutOptionsA.shapeSet    = ['Regular', 'Heart'];
    donutOptionsA.icingSet    = ['Flower', 'Dipped', 'Wavy', 'Classic', 'None'];
    donutOptionsA.toppingSet  = ['Sprinkles', 'Marshmellows', 'Syrup', 'Stars', 'None'];
    
    donutRollsA.faceSetR     = random(donutOptionsA.faceSet.length);
    donutRollsA.shapeSetR    = random(donutOptionsA.shapeSet.length);
    donutRollsA.icingSetR    = random(donutOptionsA.icingSet.length);
    donutRollsA.toppingSetR  = random(donutOptionsA.toppingSet.length);

    if (rareMode == 1){
      colourRollsA.doughColourR    = colourOptionsA.doughColour.length - 1;
    }

    uint256[10] memory nftRenderCode = [colourRollsA.bgColourR, colourRollsA.lineColourR, colourRollsA.doughColourR, colourRollsA.icingColourR, colourRollsA.toppingColourR, donutRollsA.faceSetR, donutRollsA.shapeSetR, donutRollsA.icingSetR, donutRollsA.toppingSetR, rareMode];
    string memory nftRenderCodeS = string(abi.encodePacked(uint2str(colourRollsA.bgColourR), uint2str(colourRollsA.lineColourR), uint2str(colourRollsA.doughColourR), uint2str(colourRollsA.icingColourR), uint2str(colourRollsA.toppingColourR), uint2str(donutRollsA.faceSetR), uint2str(donutRollsA.shapeSetR), uint2str(donutRollsA.icingSetR), uint2str(donutRollsA.toppingSetR)));

    string memory nftConfig1 = string(abi.encodePacked('{"trait_type" : "Background", "value" : "', colourOptionsA.bgColour[colourRollsA.bgColourR], '" },       {"trait_type" : "Dough Flavour",  "value" : "', colourOptionsA.doughColour[colourRollsA.doughColourR], '" },'));
    string memory nftConfig2 = string(abi.encodePacked('{"trait_type" : "Icing",      "value" : "', colourOptionsA.icingColour[colourRollsA.icingColourR], '" }, {"trait_type" : "Icing Type",     "value" : "', donutOptionsA.icingSet[donutRollsA.icingSetR], '" },'));
    string memory nftConfig3 = string(abi.encodePacked('{"trait_type" : "Toppings",   "value" : "', donutOptionsA.toppingSet[donutRollsA.toppingSetR], '" },    {"trait_type" : "Shape",          "value" : "', donutOptionsA.shapeSet[donutRollsA.shapeSetR], '" },'));
    string memory nftConfig4 = string(abi.encodePacked('{"trait_type" : "Face",       "value" : "', donutOptionsA.faceSet[donutRollsA.faceSetR], '" }'));

    return (string(abi.encodePacked(nftConfig1, nftConfig2, nftConfig3, nftConfig4)), nftRenderCodeS, nftRenderCode);
  }


  function paintBunny(uint256[5] memory colourSet, uint256[5] memory lockedSet) public pure returns(string memory, string memory, uint256[10] memory){
    colourOptions memory colourOptionsA;
    colourRolls memory colourRollsA;
    donutOptions memory donutOptionsA;
    donutRolls memory donutRollsA;

    colourOptionsA.bgColour      = ['Blue', 'Green', 'Pink', 'Orange', 'Yellow', 'Purple'];
    colourOptionsA.lineColour    = ['Purple', 'Blue', 'Orange'];
    colourOptionsA.doughColour   = ['Chocolate', 'Oat', 'Vanilla', 'RARE'];
    colourOptionsA.icingColour   = ['Strawberry', 'Pinkberry', 'Banana', 'Blueberry'];
    colourOptionsA.toppingColour = ['Purple', 'White', 'Pink', 'Blue', 'Yellow'];
    
    colourRollsA.bgColourR       = colourSet[0];
    colourRollsA.lineColourR     = colourSet[1];
    colourRollsA.doughColourR    = colourSet[2];
    colourRollsA.icingColourR    = colourSet[3];
    colourRollsA.toppingColourR  = colourSet[4];

    donutOptionsA.faceSet     = ['Love', 'Bunny', 'Shocked', 'Cute', 'Dizzy'];
    donutOptionsA.shapeSet    = ['Regular', 'Heart'];
    donutOptionsA.icingSet    = ['Flower', 'Dipped', 'Wavy', 'Classic', 'None'];
    donutOptionsA.toppingSet  = ['Sprinkles', 'Marshmellows', 'Syrup', 'Stars', 'None'];
    
    donutRollsA.faceSetR     = lockedSet[0];
    donutRollsA.shapeSetR    = lockedSet[1];
    donutRollsA.icingSetR    = lockedSet[2];
    donutRollsA.toppingSetR  = lockedSet[3];
    uint256 rareMode  = lockedSet[4];

    uint256[10] memory nftRenderCode = [colourRollsA.bgColourR, colourRollsA.lineColourR, colourRollsA.doughColourR, colourRollsA.icingColourR, colourRollsA.toppingColourR, donutRollsA.faceSetR, donutRollsA.shapeSetR, donutRollsA.icingSetR, donutRollsA.toppingSetR, rareMode];
    string memory nftRenderCodeS = string(abi.encodePacked(uint2str(colourRollsA.bgColourR), uint2str(colourRollsA.lineColourR), uint2str(colourRollsA.doughColourR), uint2str(colourRollsA.icingColourR), uint2str(colourRollsA.toppingColourR), uint2str(donutRollsA.faceSetR), uint2str(donutRollsA.shapeSetR), uint2str(donutRollsA.icingSetR), uint2str(donutRollsA.toppingSetR)));

    string memory nftConfig1 = string(abi.encodePacked('{"trait_type" : "Background", "value" : "', colourOptionsA.bgColour[colourRollsA.bgColourR], '" },       {"trait_type" : "Dough Flavour",  "value" : "', colourOptionsA.doughColour[colourRollsA.doughColourR], '" },'));
    string memory nftConfig2 = string(abi.encodePacked('{"trait_type" : "Icing",      "value" : "', colourOptionsA.icingColour[colourRollsA.icingColourR], '" }, {"trait_type" : "Icing Type",     "value" : "', donutOptionsA.icingSet[donutRollsA.icingSetR], '" },'));
    string memory nftConfig3 = string(abi.encodePacked('{"trait_type" : "Toppings",   "value" : "', donutOptionsA.toppingSet[donutRollsA.toppingSetR], '" },    {"trait_type" : "Shape",          "value" : "', donutOptionsA.shapeSet[donutRollsA.shapeSetR], '" },'));
    string memory nftConfig4 = string(abi.encodePacked('{"trait_type" : "Face",       "value" : "', donutOptionsA.faceSet[donutRollsA.faceSetR], '" }'));

    return (string(abi.encodePacked(nftConfig1, nftConfig2, nftConfig3, nftConfig4)), nftRenderCodeS, nftRenderCode);
  }
}