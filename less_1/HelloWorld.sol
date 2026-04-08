// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HelloWorld {

    bool boolVar_1 = true;
    bool boolVar_2 = false;
    string message  = "Hello World";
    address addrVar = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    struct Info {
        string phrase;
        uint256 id;
        address addr;
    }

    Info[] infos;

    mapping(uint256 id =>Info info) infoMap;

    function sayHello(uint256 _id) public view  returns(string memory) {
        // for(uint i = 0 ; i < infos.length; i++){
        //     if(_id == infos[i].id){
        //         return  addinfo(infos[i].phrase);
        //     }
        // }
        if(infoMap[_id].addr == address(0x0)){
            return addinfo(message);
        }
        return addinfo(infoMap[_id].phrase);
    }

    function setHello(string memory newString,uint256 _id) public {
        Info memory info = Info(newString, _id, msg.sender);
        infoMap[_id] = info;
        //infos.push(info);
    }

    function addinfo(string memory newString) internal pure returns(string memory){
        return string.concat(newString," fack you");
    }


}