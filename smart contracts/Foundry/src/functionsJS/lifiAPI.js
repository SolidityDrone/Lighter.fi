/**
 * @dev test at: https://functions.chain.link/playground
 * Should be called only Chain X to X
 */

const fC= 'pol';
        const fT=args[0];   // FromToken
        const tT=args[1];   // ToToken
        const fAd=args[2];  // FromAddress
        const fAm=args[3];  // FromAmount
        const lRUrl = `https://li.quest/v1/quote?fromChain=${fC}&toChain=${fC}&fromToken=${fT}&toToken=${tT}&fromAddress=${fAd}&fromAmount=${fAm}`;
        const lR = await Functions.makeHttpRequest({
            url: lRUrl,
            method: 'GET',
            headers: {
                'accept': 'application/json',
            },
        });
        //Get lifi tx data
        const data = lR.data.transactionRequest.data;
        //Get lifi tx toolData
        const tD = lR.data.includedSteps[0].estimate.toolData;
        // Parse byte string and pack the slices
        function parsebs(bs) {
            const ts = bs.slice(10);
            const txId = ts.slice(0, 64);
            const minOut = ts.slice(288, 320);
            const router = tD.routerAddress.slice(2);
            const selector = ts.slice(1664, 1672);
            let middleToken1 = '';
            let middleToken2 = '';
            if (tD.path.length === 3){
                middleToken1 = tD.path[1].slice(2);
            }
            if (tD.path.length === 4){
                middleToken1 = tD.path[1].slice(2);
                middleToken2 = tD.path[2].slice(2);
            }
            return txId+minOut+router+selector+middleToken1+middleToken2;
        }
        // Return encoded string to the smart contract
        return (Functions.encodeString(parsebs(data)));