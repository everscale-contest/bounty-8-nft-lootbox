from freeton_utils import *
from Collection import BasicCollection

SERVER_ADDRESS = "https://net.ton.dev"

def getClient():
    return TonClient(config=ClientConfig(network=NetworkConfig(server_address=SERVER_ADDRESS)))
 
keypair = getClient().crypto.generate_random_sign_keys()
signer  = Signer.Keys(keys=keypair)

msig = Multisig(everClient=getClient())

collection = BasicCollection(everClient=getClient(),signer=signer)
giverGive(getClient(), msig.ADDRESS, EVER * 30)
giverGive(getClient(), collection.ADDRESS, EVER * 10)


print(collection.ADDRESS,msig.ADDRESS)

msig.deploy()
collection.deploy()


collection.mintNft(msig)


