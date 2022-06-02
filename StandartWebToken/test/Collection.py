import freeton_utils
from   freeton_utils import *
import time

codeNft = getCodeFromTvc("../build/Nft.tvc")
codeIndex = getCodeFromTvc("../build/Index.tvc")
codeIndexBasis = getCodeFromTvc("../build/IndexBasis.tvc")
codeStorage = getCodeFromTvc("../build/TIP4_4Storage.tvc")

imgs = []
imgs.append(dict(link="https://raw.githubusercontent.com/monero-ecosystem/dont-buy-monero-sticker/master/sticker.en.png",mimetype="image/png"))

class BasicCollection(BaseContract):
    
    def __init__(self, everClient: TonClient, signer: Signer = None):

        genSigner = generateSigner() if signer is None else signer

        self.CONSTRUCTOR = dict(
            codeNft=codeNft,
            codeIndex=codeIndex,
            codeIndexBasis=codeIndexBasis,
            codeStorage=codeStorage,
            ownerPubkey="0x" + signer.keys.public,
            json="{}",
            mintingFee=int(1e9),
            imgs=imgs,
            timeToDeploy=int(time.time() + 120))
        self.INITDATA    = {}
        BaseContract.__init__(self, everClient=everClient, contractName="Collection", pubkey=signer.keys.public, signer=genSigner)

    #========================================
    #

    def mintNft(self, msig: SetcodeMultisig):
        params = {}
        result = self._callFromMultisig(msig=msig, functionName="mintNft", functionParams=params, value=int(1e10), flags=1)
        return result

