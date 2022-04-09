// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./InterestRateInterface.sol";
import "./BankBalanceInterface.sol";


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}



/// @title SimpleBank
/// @author nemild, kor, tot

/* 'contract' has similarities to 'class' in other languages (class variables,
inheritance, etc.) */
contract CoreBank { // CamelCase
    using SafeMath for uint256;
    // Declare state variables outside function, persist through life of contract
    

    //  Type of rateModule is InterestRateModule
    // InterestRateModule = type: address
    InterestRateModule public rateModule;
    BankBalanceModule public balanceModule;

    // "private" means that other contracts can't directly query balances
    // but data is still viewable to other parties on blockchain

    address public owner;
    // 'public' makes externally readable (not writeable) by users or contracts

    // Events - publicize actions to external listeners
    event DepositMade(address accountAddress, uint amount);

    // Constructor, can receive one or many variables here; only one allowed
    constructor(InterestRateModule _rateModule, BankBalanceModule _balanceModule) public {
        // msg provides details about the message that's sent to the contract
        // msg.sender is contract caller (address of contract creator)
        owner = msg.sender;

        rateModule = _rateModule;
        balanceModule = _balanceModule;
    }

    function upgradeInterestModule(InterestRateModule _rateModule) public {
        require(owner == msg.sender);
        rateModule = _rateModule;
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    function deposit() public payable returns (uint256) {
        // Change from user to Programming
        // function deposit(address user, uint256 amount) external payable returns (uint256);
        uint256 newBalance = balanceModule.deposit.value(msg.value)(msg.sender, msg.value);

        emit DepositMade(msg.sender, msg.value); // fire event

        return newBalance;
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return remainingBal The balance remaining for the user
    function withdraw(uint withdrawAmount) public returns (uint256 remainingBal) {
        uint256 newBalance = balanceModule.withdraw(msg.sender, withdrawAmount);

        // Revert on failed
        msg.sender.transfer(withdrawAmount);
        
        return newBalance;
    }

    /// @notice Get balance
    /// @return The balance of the user
    // 'constant' prevents function from editing state variables;
    // allows function to run locally/off blockchain
    function balance() public view returns (uint256) {
        return balanceModule.balance(msg.sender);
    }

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is reverted if the contract fails
    // otherwise, the sender's money is transferred to contract
    fallback () external payable {
        // revert(); // throw reverts state to before call
    }
    
    
    function increaseYear() public {
        for(uint256 i = 0; i < balanceModule.accountCount(); i++) {
            address account = balanceModule.accounts(i);
            uint256 interest = rateModule.calculateInterest(account, balanceModule.balance(account)); // change calculateInterest() to return newBalance instead of interest
            balanceModule.forceUpdateBalance(account, balanceModule.balance(account).add(interest));
        }
    }
    
    function systemBalance() public view returns(uint256) {
        return address(balanceModule).balance;
    }
}
// ** END EXAMPLE **