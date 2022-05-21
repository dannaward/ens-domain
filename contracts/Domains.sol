pragma solidity ^0.8.10;

import "hardhat/console.sol";
import { StringUtils } from "./libraries/StringUtils.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Domains is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address payable public domainContractOwner;

    string public tld;

    // 주인
    mapping(string => address) public domains;

    // 포인팅 어디로? value store 하겠지 ..
    mapping(string => string) public records;

    constructor(string memory _tld) payable {
        console.log("This is my domains contract", _tld);
        domainContractOwner = payable(msg.sender);
        tld = _tld;
    }

    function price(string calldata name) public pure returns (uint) {
        // 문자열 길이에 따라서 돈을 매겨보겠습니다.
        uint length = StringUtils.strlen(name);
        require(length > 0, "smaller than 0 string value length");

        if (length == 3) {
            return 5 * (10 ** 17); // 0.5 MATIC
        } else if (length == 4) {
            return 3 * (10 ** 17); // 0.3 MATIC
        } else {
            return 1 * (10 ** 17); // 0.1 MATIC
        }
    }

    function register(string calldata name) public payable {
        require(domains[name] == address(0), "not registered");

        uint _price = price(name);

        // domainContractOwner.tranfer(msg.value); // 보안 취약점이 발견돼서 쓰지 말라고 컨벤션
        (bool success, ) = domainContractOwner.call {
            value: msg.value
        }("");

        require(msg.value >= _price, "not enough MATIC sent");

        domains[name] = msg.sender;
        console.log("%s has registered a domain!", msg.sender);
    }

    function getAddress(string calldata name) public view returns (address) {
        return domains[name];
    }

    function setRecord(string calldata _name, string calldata _record) public {
        // domain의 주인만 domain이 가리키게 될 record를 수정할 수 있다. (접근 제한자)
        require(domains[_name] == msg.sender, "not an owner");
        records[_name] = _record;
    }
    
    function getRecord(string calldata name) public view returns(string memory) {
        return records[name];
    }
}