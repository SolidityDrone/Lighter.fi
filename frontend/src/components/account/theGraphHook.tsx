import { ApolloClient, ApolloQueryResult, InMemoryCache, NormalizedCacheObject } from "@apollo/client"
import { useCallback, useEffect, useState } from "react"
import { gql } from "urql"
import { useAccount } from "wagmi"

const query = `query($id: String) {
   user(id: $id) {
    strategies(where: {type_not: "Deleted"}) {
      amount
      blockTimestamp
      id
      limit
      nextExecution
      strategyIndex
      timeInterval
      tokenIn
      tokenOut
      type
    }
  }
}`
const APIURL = 'https://api.thegraph.com/subgraphs/name/soliditydrone/lighter-fi'

export type Strategy = {
    amount: string;
    blockTimestamp: string;
    id: string;
    limit: string;
    nextExecution: string;
    strategyIndex: string;
    timeInterval: string;
    tokenIn: string;
    tokenOut: string;
    type: string;
}
type Result = {
    data:
    {
        user: {
            strategies: Strategy[]
        }
    }
}



export const useQueryHook = () => {
    const { address } = useAccount()
    const [client, setClient] = useState<ApolloClient<NormalizedCacheObject>>()
    const [strategies, setStrategies] = useState<ApolloQueryResult<any>>()




    const makeQuery = async () => {
        try {
            if (client) {
                console.log("QUERY", query)
                const res = await client
                    .query({
                        query: gql(query),
                        variables: {
                            id: address?.toLowerCase()
                        }

                    })
                console.log("AAAAA", res)
                const strats = res.data?.user?.strategies
                setStrategies(strats)
            }
        } catch (error) {
            console.log(error)
        }
    }

    useEffect(() => {
        if (!client) {
            const client = new ApolloClient({
                uri: APIURL,
                cache: new InMemoryCache(),
            })
            setClient(client)
        }
    })


    useEffect(() => {
        makeQuery()
    }, [client])

    return { strategies }
}