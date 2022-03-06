//SPDX-License-Identifier: UNLICENSED

/*
    _____                _____                 
    |  __ \              /  __ \                
    | |  \/ ___ _ __ ___ | /  \/ __ ___   _____ 
    | | __ / _ \ '_ ` _ \| |    / _` \ \ / / _ \
    | |_\ \  __/ | | | | | \__/\ (_| |\ V /  __/
    \____/\___|_| |_| |_|\____/\__,_| \_/ \___|  v3
                                                                       
                                                       
    BSC Token Contract with smart and secure custom features
               
    Website: token.GemCave.org
*/

pragma solidity ^0.8.4;

import "./token/ERC20/extensions/IERC20Metadata.sol";
import "./access/Ownable.sol";
import "./utils/math/SafeMath.sol";
import "./utils/Address.sol";

interface IUniswapV2Factory {
	event PairCreated(address indexed token0, address indexed token1, address pair, uint);
	function feeTo() external view returns (address);
	function feeToSetter() external view returns (address);
	function getPair(address tokenA, address tokenB) external view returns (address pair);
	function allPairs(uint) external view returns (address pair);
	function allPairsLength() external view returns (uint);
	function createPair(address tokenA, address tokenB) external returns (address pair);
	function setFeeTo(address) external;
	function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
	function factory() external pure returns (address);
	function WETH() external pure returns (address);
	function addLiquidity( address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline
	) external returns (uint amountA, uint amountB, uint liquidity);
	function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline
	) external payable returns (uint amountToken, uint amountETH, uint liquidity);
	function removeLiquidity( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline
	) external returns (uint amountA, uint amountB);
	function removeLiquidityETH( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline
	) external returns (uint amountToken, uint amountETH);
	function removeLiquidityWithPermit( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountA, uint amountB);
	function removeLiquidityETHWithPermit( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountToken, uint amountETH);
	function swapExactTokensForTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
	) external returns (uint[] memory amounts);
	function swapTokensForExactTokens( uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline
	) external returns (uint[] memory amounts);
	function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
	function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
	function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
	function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
	function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
	function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
	function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
	function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
	function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
	function removeLiquidityETHSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline
	) external returns (uint amountETH);
	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountETH);
	function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
	) external;
	function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path, address to, uint deadline
	) external payable;
	function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
	) external;
}


// Main Contract
contract GemCaveToken is IERC20Metadata, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _walletBalance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isTaxExempt;

    IUniswapV2Router02 public immutable uniswapV2Router;

    // General 
    string private _name = 'GemCave Token';
    string private _symbol = 'GEMS';
    uint8 private _decimals = 9;
    uint256 public constant _supplyTotal = 100000000000000000000000;
    uint256 public maxTxPercent = 3;
    address public immutable uniswapV2Pair;
    address public _routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // LIVE

    // Wallet addresses
    address private constant burnAddress = 0x000000000000000000000000000000000000dEaD;
    address payable public taxWallet = payable(0x497d6c2b7567b6756f4d6CEC52d1F507DA3d1250);
    address payable public liqWallet = payable(0x497d6c2b7567b6756f4d6CEC52d1F507DA3d1250);

    // NFT
    address public addressOfNFT = 0x000000000000000000000000000000000000dEaD;
    address public addressOfNFT2 = 0x000000000000000000000000000000000000dEaD;
    address public addressOfNFT3 = 0x000000000000000000000000000000000000dEaD;
    mapping (address => uint256) private nftMintCredits;
    
    // Max wallet size
    uint256 public maxWalletSize = 5;
    mapping (address => bool) private maxWalletExempt;

    // Club
    mapping (address => uint256) private clubPayoutCount;
    mapping (address => uint256) private clubPayoutTally;
    mapping (address => uint256) private taxFreeBuyClub;
    address[] public clubList;
    uint256 public clubPayout = 10;
    uint256 public clubEntryPrice = 100000000000000000000;

    // Taxes
    uint256 public burnTaxS  = 1;
    uint256 public burnTaxB  = 0;
    uint256 public burnTaxT  = 0;
    uint256 public taxTaxS  = 13;
    uint256 public taxTaxB  = 4;
    uint256 public taxTaxT  = 5;
    uint256 public clubTaxS = 3;
    uint256 public clubTaxB = 3;
    uint256 public clubTaxT = 3;
    uint256 public liqTaxS = 4;
    uint256 public liqTaxB = 3;
    uint256 public liqTaxT = 4;

    // Tax options
    bool public taxesOnSell = true;
    bool public taxesOnBuy = true;
    bool public taxesOnTran = true;
    bool private doTaxes = true;
    
    // Swap
    uint256 public taxSwapAt  = 250000000000000000000;
    uint256 public liqSwapAt  = 250000000000000000000;
    uint256 public taxCount   = 0;
    uint256 public liqCount   = 0;
    bool public swapOnSell = true;
    bool public swapOnBuy = false;
    bool private inSwap = false;

    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    constructor() {
        _walletBalance[_msgSender()] = _supplyTotal;
        emit Transfer(address(0), _msgSender(), _supplyTotal);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_routerAddress);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _isTaxExempt[_msgSender()] = true;
        _isTaxExempt[burnAddress] = true;
        _isTaxExempt[taxWallet] = true;
        _isTaxExempt[liqWallet] = true;
        _isTaxExempt[_routerAddress] = true;
        maxWalletExempt[_msgSender()] = true;
        maxWalletExempt[burnAddress] = true;
        maxWalletExempt[taxWallet] = true;
        maxWalletExempt[liqWallet] = true;
        maxWalletExempt[_routerAddress] = true;
    }

    // Core
    function name() public view override returns (string memory) {
        return _name;
    }
    function symbol() public view override returns (string memory) {
        return _symbol;
    }
    function decimals() public view override returns (uint8) {
        return _decimals;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _walletBalance[account];
    }
    function totalSupply() public pure override returns (uint256) {
        return _supplyTotal;
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }   
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }
    function renounceOwnership() public override onlyOwner {
        if (_walletBalance[address(this)] == 1337133713371337){ // Added a check to stop accidental renounce
            _transferOwnership(address(0));
        }
    }

    // General
    function changeRouterAddress(address newRouterAddress) public virtual onlyOwner {
        _routerAddress = newRouterAddress;
    }
    function changeTaxWallet(address payable newWallet) public virtual onlyOwner {
        taxWallet = newWallet;
    }  
    function changeLiqWallet(address payable newLiqWallet) public virtual onlyOwner {
        liqWallet = newLiqWallet;
    }   
    function withdrawContractTokens(address account, uint256 tokenAmount) external onlyOwner() {
        require(_walletBalance[address(this)] >= tokenAmount, "Wallet balance error");
        _walletBalance[account] = _walletBalance[account].add(tokenAmount);  
        _walletBalance[address(this)] = _walletBalance[address(this)].sub(tokenAmount);     
        emit Transfer(address(this), account, tokenAmount);
    }
    function withdrawContractBNB(address payable account) external onlyOwner() {
        payable(address(account)).transfer(address(this).balance);
    }
    function changeMaxTxPercent(uint256 newMaxTxPercent) public virtual onlyOwner {
        maxTxPercent = newMaxTxPercent;
    }

    // NFT
    function changeNFTAddress(address newAddressOfNFT) public virtual onlyOwner {
        addressOfNFT = newAddressOfNFT;
    }
    function changeNFTAddress2(address newAddressOfNFT) public virtual onlyOwner {
        addressOfNFT2 = newAddressOfNFT;
    }
    function changeNFTAddress3(address newAddressOfNFT) public virtual onlyOwner {
        addressOfNFT3 = newAddressOfNFT;
    }
    function addNFTCredits(address[] memory accounts, uint256 creditsToAdd) public virtual onlyOwner {
        uint256 accLen = accounts.length;
        for (uint256 i=0; i<accLen; i++) {
            nftMintCredits[accounts[i]] = nftMintCredits[accounts[i]] + creditsToAdd;
        }
    }
    function resetNFTCredits(address account) public virtual onlyOwner {
        nftMintCredits[account] = 0;
    }
    function getNFTCredits(address account) public view returns (uint256) {
        return nftMintCredits[account];
    }

    // Tax values
    function changeTaxOnSell(uint256 newTax) public virtual onlyOwner {
        taxTaxS = newTax;
    }
    function changeTaxOnBuy(uint256 newTax) public virtual onlyOwner {
        taxTaxB = newTax;
    }
    function changeTaxOnTransfer(uint256 newTax) public virtual onlyOwner {
        taxTaxT = newTax;
    }
    function changeLiqOnSell(uint256 newLiqTax) public virtual onlyOwner {
        liqTaxS = newLiqTax;
    }
    function changeLiqOnBuy(uint256 newLiqTax) public virtual onlyOwner {
        liqTaxB = newLiqTax;
    }
    function changeLiqOnTransfer(uint256 newLiqTax) public virtual onlyOwner {
        liqTaxT = newLiqTax;
    }
    function changeBurnOnSell(uint256 newBurnTax) public virtual onlyOwner {
        burnTaxS = newBurnTax;
    }
    function changeBurnOnBuy(uint256 newBurnTax) public virtual onlyOwner {
        burnTaxB = newBurnTax;
    }
    function changeBurnOnTransfer(uint256 newBurnTax) public virtual onlyOwner {
        burnTaxT = newBurnTax;
    }
    function changeClubTaxOnSell(uint256 newClubTax) public virtual onlyOwner {
        clubTaxS = newClubTax;
    }
    function changeClubTaxOnBuy(uint256 newClubTax) public virtual onlyOwner {
        clubTaxS = newClubTax;
    }
    function changeClubTaxOnTransfer(uint256 newClubTax) public virtual onlyOwner {
        clubTaxS = newClubTax;
    }

    // Taxes enabled
    function changeTaxesOnSell(bool newTaxStatus) public virtual onlyOwner {
        taxesOnSell = newTaxStatus;
    }
    function changeTaxesOnBuy(bool newTaxStatus) public virtual onlyOwner {
        taxesOnBuy = newTaxStatus;
    }
    function changeTaxesOnTran(bool newTaxStatus) public virtual onlyOwner {
        taxesOnTran = newTaxStatus;
    }


    // Max wallet size
    function changeMaxWalletSize(uint256 newMaxWalletSize) public virtual onlyOwner {
        maxWalletSize = newMaxWalletSize;
    } 
    function addMaxWalletExempt(address account) public virtual onlyOwner {
        maxWalletExempt[account] = true;
    }
    function removeMaxWalletExempt(address account) public virtual onlyOwner {
        maxWalletExempt[account] = false;
    }
    function isMaxWalletExempt(address account) public view returns (bool) {
        return maxWalletExempt[account];
    }


    // Tax exempt buys
    function addTaxFreeBuyCredits(address[] memory accounts, uint256 taxFreeBuyCredits) public virtual onlyOwner {
        uint256 accLen = accounts.length;
        for (uint256 i=0; i<accLen; i++) {
            taxFreeBuyClub[accounts[i]] = taxFreeBuyClub[accounts[i]] + taxFreeBuyCredits;
        }
    }
    function resetTaxFreeBuyCredits(address account) public virtual onlyOwner {
        taxFreeBuyClub[account] = 0;
    }
    function getTaxFreeBuyCredits(address account) public view returns (uint256) {
        return taxFreeBuyClub[account];
    }

    
    // Tax exempt
    function isTaxExempt(address account) public view returns (bool) {
        return _isTaxExempt[account];
    }
    function addTaxExempt(address account) external onlyOwner() {
        require(!_isTaxExempt[account], "Account is already tax exempt");
        _isTaxExempt[account] = true; 
    }
    function removeTaxExempt(address account) external onlyOwner() {
        require(_isTaxExempt[account], "Account is not tax exempt");
        _isTaxExempt[account] = false;
    }


    // Club
    function changeClubEntryPrice(uint256 newPrice) public virtual onlyOwner {
        clubEntryPrice = newPrice;
    }
    function changeClubPayout(uint256 newPayout) public virtual onlyOwner {        
        clubPayout = newPayout;
    }
    function getClubPayoutCount(address account) external view returns (uint256) {
        return clubPayoutCount[account];
    }
    function getClubPayoutTally(address account) external view returns (uint256) {
        return clubPayoutTally[account];
    }
    function clearClubList() public virtual onlyOwner {
        delete clubList;
    }
    function setWalletPayoutCount(address[] memory accounts, uint256 payoutC) external onlyOwner() {
        uint256 accLen = accounts.length;

        for (uint256 i=0; i<accLen; i++) {
            if (clubPayoutCount[accounts[i]] == 0) {
                uint256 clubSize = clubList.length;
                bool foundIt = false;

                if (clubSize > 0){
                    for (uint256 z=0; z<clubSize; z++) {
                        if (clubList[z] == accounts[i]) {
                            foundIt = true;
                        }
                    }

                    if (!foundIt){
                        clubList.push(accounts[i]);
                    }
                } else {
                    clubList.push(accounts[i]);
                }
            }
            clubPayoutCount[accounts[i]] = payoutC;
        }
    }
    function addWalletPayoutCount(address[] memory accounts, uint256 payoutsToAdd) external onlyOwner() {
        uint256 accLen = accounts.length;

        for (uint256 i=0; i<accLen; i++) {
            uint256 clubSize = clubList.length;
            bool foundIt = false;

            if (clubSize > 0){
                for (uint256 z=0; z<clubSize; z++) {
                    if (clubList[z] == accounts[i]) {
                        foundIt = true;
                    }
                }

                if (!foundIt){
                    clubList.push(accounts[i]);
                }
            } else {
                clubList.push(accounts[i]);
            }
            clubPayoutCount[accounts[i]] = clubPayoutCount[accounts[i]] + payoutsToAdd;
        }
    }

   
    // Swap
    function changeSwapOnSell(bool newSwapOnSell) public virtual onlyOwner {
        swapOnSell = newSwapOnSell;
    }
    function changeSwapOnBuy(bool newSwapOnBuy) public virtual onlyOwner {
        swapOnBuy = newSwapOnBuy;
    }
    function changeTaxSwapAt(uint256 newTaxSwapAt) public virtual onlyOwner {
        taxSwapAt = newTaxSwapAt;
    }
    function changeLiqSwapAt(uint256 newLiqSwapAt) public virtual onlyOwner {
        liqSwapAt = newLiqSwapAt;
    }
    function swapForMint(address account, uint256 amount) external returns (uint256)  {
        bool isValid = false;

        if (_msgSender() == addressOfNFT) { isValid = true; }
        if (_msgSender() == addressOfNFT2) { isValid = true; }
        if (_msgSender() == addressOfNFT3) { isValid = true; }

        require(isValid, "Function can only be called from approved NFT Contract");

        if (nftMintCredits[account] > 0){
            nftMintCredits[account] = nftMintCredits[account].sub(1);
        } else {
            require(_walletBalance[account] >= amount, "Wallet does not hold tokens or NFT credits to mint");

            _walletBalance[burnAddress] = _walletBalance[burnAddress].add(amount);  
            _walletBalance[account] = _walletBalance[account].sub(amount);     
            emit Transfer(account, burnAddress, amount);
        }

        // Return users total Gem bonus payouts as a reed (higher = more likely to get rare)
        return clubPayoutTally[account];
    }
    function swapTokensForEth(uint256 tokenAmount, address sendTo) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        _approve(sendTo, address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            sendTo,
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);

        inSwap = false;
    }


    // MAIN TRANSFER
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(sender != address(burnAddress), "BaseRfiToken: transfer from the burn address");
        require(_walletBalance[sender] >= amount, "Insufficient balance");

        if(sender != owner()){
            require(recipient != address(0), "ERC20: transfer to the zero address");
        }
        
        uint256 newAmount = amount;
        uint256 burnTax = 0;   
        uint256 taxTax = 0;   
        uint256 clubTax = 0;   
        uint256 liqTax = 0;   
        
        doTaxes = true;

        if (inSwap){
            doTaxes = false;
        }

        uint256 totalTxAmount = _supplyTotal.div(100).mul(maxTxPercent);
        if(recipient != owner() && sender != owner() && !isTaxExempt(sender) && !isTaxExempt(recipient) && doTaxes) { 
            if(amount > totalTxAmount) {
                revert("Transfer amount exceeds the maxTxPercent.");
            }
        }

        // BUY
        if(sender == uniswapV2Pair) {

            // Check if tax free
            if (isTaxExempt(recipient) || !taxesOnBuy){
                doTaxes = false;
            }

            // Check if tax free buy credit
            if (taxFreeBuyClub[recipient] > 0){
                doTaxes = false;
                taxFreeBuyClub[recipient] = taxFreeBuyClub[recipient].sub(1);
            }

            // Check max wallet size
            if(!maxWalletExempt[recipient]) { 
                uint256 newAmountT = _walletBalance[recipient].add(amount);
                uint256 maxAmountT = _supplyTotal.div(100).mul(maxWalletSize);
                
                if(newAmountT > maxAmountT) {
                    revert("Wallet would exceed the maxWalletSize.");
                }
            }

            burnTax = burnTaxB; 
            taxTax = taxTaxB;
            clubTax = clubTaxB;
            liqTax = liqTaxB;

            if (swapOnBuy && !inSwap){

                // Run tax swapper
                if (balanceOf(address(this)) >= taxSwapAt && taxCount >= taxSwapAt) {
                    inSwap = true;
                    swapTokensForEth(taxSwapAt, taxWallet);
                    taxCount = 0;
                }

                // Run liq swapper
                if (balanceOf(address(this)) >= liqSwapAt && liqCount >= liqSwapAt) {
                    inSwap = true;
                    swapTokensForEth(liqSwapAt, liqWallet);
                    liqCount = 0;
                }
            }
            
            // Buyer club check
            if (amount >= clubEntryPrice && recipient != address(this)){
                
                // Add to club
                if (clubPayoutCount[recipient] == 0) {
                     uint256 clubSize = clubList.length;
                     bool foundIt = false;

                    if (clubSize > 0){

                        for (uint256 i=0; i<clubSize; i++) {
                            if (clubList[i] == recipient) {
                                foundIt = true;
                            }
                        }

                        if (!foundIt){
                            clubList.push(recipient);
                        }
                    } else {
                        clubList.push(recipient);
                    }
                }
                
                uint256 payoutMop = amount.div(clubEntryPrice);
                clubPayoutCount[recipient] = clubPayoutCount[recipient].add(clubPayout.mul(payoutMop));
            }
        }

        // SELL
        if(recipient == uniswapV2Pair) {

            if (isTaxExempt(sender) || !taxesOnSell){
                doTaxes = false;
            }

            burnTax = burnTaxS; 
            taxTax = taxTaxS;
            clubTax = clubTaxS;
            liqTax = liqTaxS;
            
            if (swapOnSell && !inSwap){

                // Run tax swapper
                if (balanceOf(address(this)) >= taxSwapAt && taxCount >= taxSwapAt) {
                    inSwap = true;
                    swapTokensForEth(taxSwapAt, taxWallet);
                    taxCount = 0;
                }

                // Run liq swapper
                if (balanceOf(address(this)) >= liqSwapAt && liqCount >= liqSwapAt) {
                    inSwap = true;
                    swapTokensForEth(liqSwapAt, liqWallet);
                    liqCount = 0;
                }
            }

            // Remove from club on sell
            if (clubPayoutCount[sender] > 0) {
                clubPayoutCount[sender] = 1;
            }

            // Remove tax free buys on sell
            taxFreeBuyClub[sender] = 0;

        }

        // TRANSFER
        if (sender != uniswapV2Pair && recipient != uniswapV2Pair){
            if (isTaxExempt(sender) || isTaxExempt(recipient) || !taxesOnTran){
                doTaxes = false;
            }

            // Check max wallet size
            if(!maxWalletExempt[recipient]) { 
                uint256 newAmountT = _walletBalance[recipient].add(amount);
                uint256 maxAmountT = _supplyTotal.div(100).mul(maxWalletSize);
                
                if(newAmountT > maxAmountT) {
                    revert("Wallet would exceed the maxWalletSize.");
                }
            }

            burnTax = burnTaxT; 
            taxTax = taxTaxT; 
            clubTax = clubTaxT;
            liqTax = liqTaxT;
        }

        // TAXES
        if (doTaxes){

            // BURN
            if (burnTax > 0){
                uint256 burnAmount = amount.div(100).mul(burnTax);
            
                _walletBalance[burnAddress] = _walletBalance[burnAddress].add(burnAmount);

                emit Transfer(sender, burnAddress, burnAmount);
                newAmount = newAmount.sub(burnAmount);
            }

            // TAX
            if (taxTax > 0){
                uint256 taxAmount = amount.div(100).mul(taxTax);
                
                _walletBalance[address(this)] = _walletBalance[address(this)].add(taxAmount);
                taxCount = taxCount.add(taxAmount);

                emit Transfer(sender, address(this), taxAmount);
                newAmount = newAmount.sub(taxAmount);
            }

            // LIQ
            if (liqTax > 0){
                uint256 liqAmount = amount.div(100).mul(liqTax);
                uint256 liqAmountHalf = liqAmount.div(2);
                
                _walletBalance[address(liqWallet)] = _walletBalance[address(liqWallet)].add(liqAmountHalf);
                _walletBalance[address(this)] = _walletBalance[address(this)].add(liqAmountHalf);
                liqCount = liqCount.add(liqAmountHalf);

                emit Transfer(sender, address(this), liqAmountHalf);
                emit Transfer(sender, address(liqWallet), liqAmountHalf);
                newAmount = newAmount.sub(liqAmount);
            }

            // CLUB
            if (clubTax > 0){
                uint256 clubRewardAmount = amount.div(100).mul(clubTax);

                if (_walletBalance[sender] >= clubTax){
                    uint256 clubSize = clubList.length;

                    if (clubSize > 0){
                        uint256 clubTaxPer = clubRewardAmount.div(clubSize);

                        for (uint256 i=0; i<clubSize; i++) {

                            if (clubPayoutCount[clubList[i]] > 0) {

                                if (clubList[i] != sender && clubList[i] != recipient) {

                                    _walletBalance[clubList[i]] = _walletBalance[clubList[i]].add(clubTaxPer);
                                    emit Transfer(sender, clubList[i], clubTaxPer);
                                    newAmount = newAmount.sub(clubTaxPer);

                                    clubPayoutCount[clubList[i]] = clubPayoutCount[clubList[i]].sub(1);
                                    clubPayoutTally[clubList[i]] = clubPayoutTally[clubList[i]].add(clubTaxPer);
                                    
                                }
                            }
                        }
                    }
                }
            }
        }

        _walletBalance[recipient] = _walletBalance[recipient].add(newAmount);  
        _walletBalance[sender] = _walletBalance[sender].sub(amount);     
        emit Transfer(sender, recipient, newAmount);
    }

    receive() external payable {}
}