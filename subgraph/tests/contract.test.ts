import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt, Bytes } from "@graphprotocol/graph-ts"
import { NewUserStrategy } from "../generated/schema"
import { NewUserStrategy as NewUserStrategyEvent } from "../generated/Contract/Contract"
import { handleNewUserStrategy } from "../src/contract"
import { createNewUserStrategyEvent } from "./contract-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let user = Address.fromString("0x0000000000000000000000000000000000000001")
    let userStrategy = "ethereum.Tuple Not implemented"
    let strategyIndex = BigInt.fromI32(234)
    let newNewUserStrategyEvent = createNewUserStrategyEvent(
      user,
      userStrategy,
      strategyIndex
    )
    handleNewUserStrategy(newNewUserStrategyEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("NewUserStrategy created and stored", () => {
    assert.entityCount("NewUserStrategy", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "NewUserStrategy",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "user",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "NewUserStrategy",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "userStrategy",
      "ethereum.Tuple Not implemented"
    )
    assert.fieldEquals(
      "NewUserStrategy",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "strategyIndex",
      "234"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
