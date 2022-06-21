from tonos_ts4 import ts4
import json
import time

eq = ts4.eq

imgs = []
imgs.append(dict(link="https://raw.githubusercontent.com/monero-ecosystem/dont-buy-monero-sticker/master/sticker.en.png",mimetype="image/png"))


now = int(time.time())
ts4.init('../build', verbose = True,time=now)

main_keypair = ts4.make_keypair()

codeNft = ts4.load_code_cell('Nft.tvc')
codeIndex = ts4.load_code_cell('Index.tvc')
codeIndexBasis = ts4.load_code_cell('IndexBasis.tvc')
codeStorage = ts4.load_code_cell('TIP4_4Storage.tvc')

ts4.register_abi("Index")
ts4.register_abi("IndexBasis")
ts4.register_abi("Nft")
ts4.register_abi("TIP4_4Storage")
ts4.register_abi("Collection")

collection = ts4.BaseContract('Collection',dict(
    codeNft=codeNft,
    codeIndex=codeIndex,
    codeIndexBasis=codeIndexBasis,
    codeStorage=codeStorage,
    ownerPubkey=main_keypair[1],
    json=json.dumps(dict()),
    mintingFee=int(10e9),
    imgs=imgs,
    timeToDeploy=now + 60 # one minute
),keypair=main_keypair,balance=int(1e11))

wallet = ts4.BaseContract("SafeMultisigWallet", dict(
    owners=[main_keypair[1]],
    reqConfirms=1),keypair=main_keypair,balance=int(1e11))

payload = ts4.encode_message_body('Collection', 'mintNft', dict())

wallet.call_method_signed("sendTransaction",dict(
    dest = collection.addr,
    value = int(11e9),
    bounce = True,
    flags = 0,
    payload = payload
))

ts4.dispatch_messages()
nftAddr = collection.call_getter("nftAddress",dict(id=0,answerId=0))

nft = ts4.BaseContract("Nft", dict(
    owner=wallet.addr,
    sendGasTo=wallet.addr,
    remainOnNft = 1,
    json = "",
    indexDeployValue = 1,
    indexDestroyValue = 1,
    codeIndex=codeIndex,
),address=nftAddr,balance=int(1e9))

wallet.call_method_signed("sendTransaction",dict(
    dest = nft.addr,
    value = int(2e9),
    bounce = True,
    flags = 0,
    payload = ts4.Cell("te6ccgEBAQEAAgAAAA==")
))
ts4.dispatch_messages()

nft.call_method("open",expect_ec=100)
firstans = nft.call_getter("getJson",dict(answerId=0))


ts4.core.set_now(now + 120)
nft.call_method("open")
ts4.dispatch_messages()
secondsans = nft.call_getter("getJson",dict(answerId=0))

if firstans == secondsans:
    print("Failed")




