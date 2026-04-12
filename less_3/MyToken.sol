// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MyToken
 * @dev 基于 OpenZeppelin 的 ERC20 代币示例
 *
 * 已覆盖学习目标：
 * - ERC20 标准接口（totalSupply / balanceOf / transfer / approve / allowance / transferFrom）
 * - 发行代币（部署时初始铸造）
 * - 管理员可继续铸造（mint）
 * - 转账与授权转账（由 ERC20 标准实现）
 *
 * 说明：
 * - Solidity ^0.8.x 已内置溢出检查，不再强制依赖 SafeMath。
 */
contract MyToken is ERC20, Ownable {
    /// @notice 部署时设定代币名称、符号，并给部署者铸造初始供应量
    /// @param initialSupply 初始供应量（按“最小单位”传入，包含 decimals）
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }

    /// @notice 仅管理员可增发代币
    /// @param to 接收代币地址
    /// @param amount 增发数量（最小单位）
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
