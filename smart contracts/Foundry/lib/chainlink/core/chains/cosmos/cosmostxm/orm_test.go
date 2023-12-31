package cosmostxm_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	cosmosdb "github.com/smartcontractkit/chainlink-cosmos/pkg/cosmos/db"

	"github.com/smartcontractkit/chainlink/v2/core/chains/cosmos/cosmostxm"
	"github.com/smartcontractkit/chainlink/v2/core/internal/testutils/cosmostest"
	"github.com/smartcontractkit/chainlink/v2/core/internal/testutils/pgtest"
	"github.com/smartcontractkit/chainlink/v2/core/logger"
)

func TestORM(t *testing.T) {
	db := pgtest.NewSqlxDB(t)
	lggr := logger.TestLogger(t)
	logCfg := pgtest.NewQConfig(true)
	chainID := cosmostest.RandomChainID()
	o := cosmostxm.NewORM(chainID, db, lggr, logCfg)

	// Create
	mid, err := o.InsertMsg("0x123", "", []byte("hello"))
	require.NoError(t, err)
	assert.NotEqual(t, 0, int(mid))

	// Read
	unstarted, err := o.GetMsgsState(cosmosdb.Unstarted, 5)
	require.NoError(t, err)
	require.Equal(t, 1, len(unstarted))
	assert.Equal(t, "hello", string(unstarted[0].Raw))
	assert.Equal(t, chainID, unstarted[0].ChainID)
	t.Log(unstarted[0].UpdatedAt, unstarted[0].CreatedAt)

	// Limit
	unstarted, err = o.GetMsgsState(cosmosdb.Unstarted, 0)
	assert.Error(t, err)
	assert.Empty(t, unstarted)
	unstarted, err = o.GetMsgsState(cosmosdb.Unstarted, -1)
	assert.Error(t, err)
	assert.Empty(t, unstarted)
	mid2, err := o.InsertMsg("0xabc", "", []byte("test"))
	require.NoError(t, err)
	assert.NotEqual(t, 0, int(mid2))
	unstarted, err = o.GetMsgsState(cosmosdb.Unstarted, 1)
	require.NoError(t, err)
	require.Equal(t, 1, len(unstarted))
	assert.Equal(t, "hello", string(unstarted[0].Raw))
	assert.Equal(t, chainID, unstarted[0].ChainID)
	unstarted, err = o.GetMsgsState(cosmosdb.Unstarted, 2)
	require.NoError(t, err)
	require.Equal(t, 2, len(unstarted))
	assert.Equal(t, "test", string(unstarted[1].Raw))
	assert.Equal(t, chainID, unstarted[1].ChainID)

	// Update
	txHash := "123"
	err = o.UpdateMsgs([]int64{mid}, cosmosdb.Started, &txHash)
	require.NoError(t, err)
	err = o.UpdateMsgs([]int64{mid}, cosmosdb.Broadcasted, &txHash)
	require.NoError(t, err)
	broadcasted, err := o.GetMsgsState(cosmosdb.Broadcasted, 5)
	require.NoError(t, err)
	require.Equal(t, 1, len(broadcasted))
	assert.Equal(t, broadcasted[0].Raw, unstarted[0].Raw)
	require.NotNil(t, broadcasted[0].TxHash)
	assert.Equal(t, *broadcasted[0].TxHash, txHash)
	assert.Equal(t, chainID, broadcasted[0].ChainID)

	err = o.UpdateMsgs([]int64{mid}, cosmosdb.Confirmed, nil)
	require.NoError(t, err)
	confirmed, err := o.GetMsgsState(cosmosdb.Confirmed, 5)
	require.NoError(t, err)
	require.Equal(t, 1, len(confirmed))
}
