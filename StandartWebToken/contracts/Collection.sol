pragma ton-solidity = 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import 'libs/TIP4_2/TIP4_2Collection.sol';
import 'libs/TIP4_3/TIP4_3Collection.sol';
import 'libs/access/OwnableExternal.sol';
import './interfaces/ITokenBurned.sol';
import './Nft.sol';


contract Collection is TIP4_2Collection, TIP4_3Collection , OwnableExternal, ITokenBurned {

    /**
    * Errors
    **/
    uint8 constant sender_is_not_owner = 101;
    uint8 constant value_is_less_than_required = 102;

    IMG[] _imgs;

    uint _timeToDeploy;

    /// _remainOnNft - the number of crystals that will remain after the entire mint 
    /// process is completed on the Nft contract
    uint128 _remainOnNft = 0.3 ever;

    uint128 _lastTokenId;

    uint128 _mintingFee;

    constructor(
        TvmCell codeNft, 
        TvmCell codeIndex,
        TvmCell codeIndexBasis,
        uint256 ownerPubkey,
        string json,
        uint128 mintingFee,
        IMG[] imgs,
        uint timeToDeploy
    ) OwnableExternal(
        ownerPubkey
    ) TIP4_1Collection (
        codeNft
    ) TIP4_2Collection (
        json
    ) TIP4_3Collection (
        codeIndex,
        codeIndexBasis
    ) 
    public {
        tvm.accept();
        _timeToDeploy = timeToDeploy;
        _imgs = imgs;
        _mintingFee = mintingFee;
    }

    function mintNft(

    ) external virtual {
        require(msg.value > _remainOnNft + _mintingFee + (2 * _indexDeployValue), value_is_less_than_required);
        /// reserve original_balance + _mintingFee 
        tvm.rawReserve(_mintingFee, 4);

        uint256 id = _lastTokenId;
        _totalSupply++;
        _lastTokenId++;

        TvmCell codeNft = _buildNftCode(address(this));
        TvmCell stateNft = _buildNftState(codeNft, id);
        address nftAddr = address(tvm.hash(stateNft));
        
        new Nft{
            stateInit: stateNft,
            value: 0,
            flag: 128
        }(
            msg.sender,
            msg.sender,
            _remainOnNft,
            "{}",
            _indexDeployValue,
            _indexDestroyValue,
            _codeIndex,
            _timeToDeploy
        ); 

        emit NftCreated(
            id, 
            nftAddr,
            msg.sender,
            msg.sender, 
            msg.sender
        );
    
    }

    function withdraw(address dest, uint128 value) external pure onlyOwner {
        tvm.accept();
        dest.transfer(value, true);
    }

    function onTokenBurned(uint256 id, address owner, address manager) external override {
        require(msg.sender == _resolveNft(id));
        emit NftBurned(id, msg.sender, owner, manager);
        _totalSupply--;
    }

    function getRandomObject(uint256 id) external override {
        require(msg.sender == _resolveNft(id));
        rnd.shuffle();
        uint _lootId = rnd.next(_imgs.length);
        IMG _img = _imgs[_lootId];
        delete _imgs[_lootId];
        Nft(msg.sender).setObject{value: 0, flag: 64, bounce: false}(_img);
    }

    function setRemainOnNft(uint128 remainOnNft) external virtual onlyOwner {
        _remainOnNft = remainOnNft;
    } 

    function setMintingFee(uint128 mintingFee) external virtual onlyOwner {
        _mintingFee = mintingFee;
    }

    function mintingFee() external view responsible returns(uint128) {
        return {value: 0, flag: 64, bounce: false}(_mintingFee);
    }

    function _isOwner() internal override onlyOwner returns(bool){
        return true;
    }

    function _buildNftState(
        TvmCell code,
        uint256 id
    ) internal virtual override(TIP4_2Collection, TIP4_3Collection) pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: Nft,
            varInit: {_id: id},
            code: code
        });
    }

}
