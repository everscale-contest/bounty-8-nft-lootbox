pragma ton-solidity = 0.58.1;

interface ITokenBurned {
    function onTokenBurned(uint256 id, address owner, address manager) external;
    function getRandomObject(uint256 id) external;
}

struct IMG {
    string mimetype;
    string link;
}