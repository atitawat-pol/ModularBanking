pragma solidity ^0.6.0;

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

contract BankBalance {
    using SafeMath for uint256;

    // dictionary that maps addresses to balances
    mapping (address => uint256) private balances;

    // Users in system
    address[] _accounts;

    function balance(address user) external view returns (uint256) {
        return balances[user];
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    function deposit(address user, uint256 amount) public payable returns (uint256) {
        // Record account in array for looping
        if (0 == balances[user]) {
            _accounts.push(user);
        }
        
        // balances[user] = balances[user].add(msg.value); // Alternative
        balances[user] = balances[user].add(amount);
        // no "this." or "self." required with state variable
        // all values set to data type's initial value by default

        return balances[user];
    }

    function withdraw(address user,uint withdrawAmount) public returns (uint256 remainingBal) {
        require(balances[user] >= withdrawAmount);
        balances[user] = balances[user].sub(withdrawAmount);

        // Revert on failed
        msg.sender.transfer(withdrawAmount); // Send to caller not user
        // user.transfer(withdrawAmount); // Send to original user
        
        return balances[user];
    }

    function accounts(uint256 index) external returns (address) {
        return _accounts[index];
    }

    function accountCount() external returns (uint256) {
        return _accounts.length;
    }

    //! Bad practice
    function forceUpdateBalance(address user, uint256 newBalance) external {
        balances[user] = newBalance;
    }
}