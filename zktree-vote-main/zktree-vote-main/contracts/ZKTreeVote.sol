// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "zk-merkle-tree/contracts/ZKTree.sol";

contract ZKTreeVote is ZKTree {
    //定义了一个名为 "ZKTreeVote" 的合约，它继承自 "ZKTree" 合约。
    address public owner;
    //声明了一个公共状态变量 "owner"，用于存储合约的拥有者地址。
    mapping(address => bool) public validators;
    //声明了一个映射类型的状态变量 "validators"，用于存储验证者的地址及其验证状态
    mapping(uint256 => bool) uniqueHashes;
    //声明了一个映射类型的状态变量 "uniqueHashes"，用于存储唯一哈希值及其使用状态
    uint numOptions;
    //声明了一个无符号整数类型的状态变量 "numOptions"，用于存储选项的数量。
    mapping(uint => uint) optionCounter;
    //声明了一个映射类型的状态变量 "optionCounter"，用于存储每个选项的计数器。

    constructor(
        uint32 _levels,
        IHasher _hasher,
        IVerifier _verifier,
        uint _numOptions
    ) ZKTree(_levels, _hasher, _verifier) {
        owner = msg.sender;
        numOptions = _numOptions;
        for (uint i = 0; i <= numOptions; i++) optionCounter[i] = 0;
        //构造函数定义，接受 _levels（树的层数）、_hasher（哈希函数）
        //和 _verifier（验证器）作为参数，并调用了基类 "ZKTree" 的构造函数。
        //此外，它还初始化了 "owner" 和 "numOptions" 变量，
        //并为 "optionCounter" 的每个选项设置初始计数为0。
    }

    function registerValidator(address _validator) external {
        require(msg.sender == owner, "Only owner can add validator!");
        validators[_validator] = true;
    //所有者可以通过调用 registerValidator 方法添加验证程序。
    //只有验证者才能在检查选民身份后向智能合约发送承诺。
    }
    

    function registerCommitment(
        //定义了一个名为 "registerCommitment" 的外部函数，用于注册承诺。
        uint256 _uniqueHash,
        uint256 _commitment
    ) external {
        require(validators[msg.sender], "Only validator can commit!");
        //使用 "require" 断言，确保只有验证者才能提交承诺。
        require(
            !uniqueHashes[_uniqueHash],
            "This unique hash is already used!"
            //使用 "require" 断言，确保唯一哈希值尚未被使用。
        );
        //_commit 方法存储提交
        _commit(bytes32(_commitment));
        uniqueHashes[_uniqueHash] = true;
    }

    function vote(
        //定义了一个名为 "vote" 的外部函数，用于进行投票。
        uint _option,
        uint256 _nullifier,
        uint256 _root,
        uint[2] memory _proof_a,
        uint[2][2] memory _proof_b,
        uint[2] memory _proof_c
    ) external {
        require(_option <= numOptions, "Invalid option!");
        //使用 "require" 断言，确保选项的值在有效范围内。
        _nullify(
            //_nullify 方法存储 nullifier 并验证它的零知识证明。
            bytes32(_nullifier),
            bytes32(_root),
            _proof_a,
            _proof_b,
            _proof_c
        );
        optionCounter[_option] = optionCounter[_option] + 1;
        //增加指定选项的计数器值。
    }

    function getOptionCounter(uint _option) external view returns (uint) {
        return optionCounter[_option];
        //可用于实时查询投票结果。
    }
}.........................................................................................................4 
