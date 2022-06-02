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


contract Nft is TIP4_2Nft, TIP4_3Nft {

    uint _timeToDeploy;

    bool _active = false;

    uint _lootId;
    IMG[] _imgs;

    constructor(
        address owner,
        address sendGasTo,
        uint128 remainOnNft,
        string json,
        uint128 indexDeployValue,
        uint128 indexDestroyValue,
        TvmCell codeIndex,
        IMG[] imgs,
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
        _imgs = imgs;
        _timeToDeploy = timeToDeploy;
    }

    function open() external {
        require(now > _timeToDeploy);
        require(_active == false);
        tvm.accept();
        rnd.shuffle();
        _lootId = rnd.next(_imgs.length);
        _active = true;
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

    function burn(address dest) external virtual onlyManager {
        tvm.accept();
        ITokenBurned(_collection).onTokenBurned(_id, _owner, _manager);
        selfdestruct(dest);
    }
    function getJson() external virtual view override responsible returns (string json) {
        string _json;
        if (_active) {
            _json = '{"type": "Basic Nft", "name": "Opened nft lootbox","preview": {"source":"' + format("{}",_imgs[_lootId].link) +'","mimetype":"' + format("{}", _imgs[_lootId].mimetype) + '"}}';
        } else {
            _json = '{"type": "Basic Nft", "name": "Closed nft lootbox", "description": "You need to wait"}';
        }
        return {value: 0, flag: 64, bounce: false} (_json);
    }

}