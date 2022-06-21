// ItGold.io Contracts (v1.0.0) 

pragma ton-solidity = 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import 'libs/TIP4_1/TIP4_1Nft.sol';
import 'libs/TIP4_2/TIP4_2Nft.sol';
import 'libs/TIP4_3/TIP4_3Nft.sol';
import 'libs/TIP4_4/TIP4_4Nft.sol';
import './interfaces/ITokenBurned.sol';
import './JsonGenerator.sol';


contract Nft is TIP4_2Nft, TIP4_3Nft {

    uint _timeToDeploy;

    bool _active = false;
    bool _isOpened = false;
    IMG _img;
    
    constructor(
        address owner,
        address sendGasTo,
        uint128 remainOnNft,
        string json,
        uint128 indexDeployValue,
        uint128 indexDestroyValue,
        TvmCell codeIndex,
        uint timeToDeploy
    ) TIP4_1Nft(
        owner,
        sendGasTo,
        remainOnNft
    ) TIP4_2Nft (
        json
    ) TIP4_3Nft (
        indexDeployValue,
        indexDestroyValue,
        codeIndex
    ) public {
        tvm.accept();
        _timeToDeploy = timeToDeploy;
    }

    function open() external {
        require(now > _timeToDeploy);
        require(_isOpened == false);
        tvm.accept();
        _isOpened = true;
        ITokenBurned(_collection).getRandomObject{value: 0.1 ton}(_id); // value will be returned but without gas on getting random object
    }

    function _beforeTransfer(
        address to, 
        address sendGasTo, 
        mapping(address => CallbackParams) callbacks
    ) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._beforeTransfer(to, sendGasTo, callbacks);
    }   

    function _afterTransfer(
        address to, 
        address sendGasTo, 
        mapping(address => CallbackParams) callbacks
    ) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._afterTransfer(to, sendGasTo, callbacks);
    }   

    function _beforeChangeOwner(
        address oldOwner, 
        address newOwner,
        address sendGasTo, 
        mapping(address => CallbackParams) callbacks
    ) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._beforeChangeOwner(oldOwner, newOwner, sendGasTo, callbacks);
    }   

    function _afterChangeOwner(
        address oldOwner, 
        address newOwner,
        address sendGasTo, 
        mapping(address => CallbackParams) callbacks
    ) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._afterChangeOwner(oldOwner, newOwner, sendGasTo, callbacks);
    }

    function setObject(IMG img) external {
        require(msg.sender == _collection,110);
        tvm.accept();
        _img = img;
        _active = true;
    }

    function burn(address dest) external virtual onlyManager {
        tvm.accept();
        ITokenBurned(_collection).onTokenBurned(_id, _owner, _manager);
        selfdestruct(dest);
    }
    using JsonWriter for JsonWriter.Json;
    function getJson() external virtual view override responsible returns (string json) {
        JsonWriter.Json writer;

        writer = writer.writeStart();
        
        writer = writer.writeString("type", "Basic Nft");
        if (_active) { 
            writer = writer.writeString("name", "Opened nft lootbox");
            writer = writer.writeStartName("preview");
            writer = writer.writeString("source", format("{}",_img.link));
            writer = writer.writeString("mimetype", format("{}",_img.mimetype));
            writer = writer.writeEnd();
        } else {
            writer = writer.writeString("name", "Opened nft lootbox");
            writer = writer.writeString("description", "You need to wait");
        }
        writer = writer.writeEnd();
        return {value: 0, flag: 64, bounce: false} (writer.value);
    }

}