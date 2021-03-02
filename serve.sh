#!/bin/sh
rm -rf example
./mkfiles.sh
supervisord -n -c supervisor.conf &

export CARDANO_NODE_SOCKET_PATH=example/node-bft1/node.sock
while [ ! -S "$CARDANO_NODE_SOCKET_PATH" ]; do
  echo "Waiting 5 seconds for bft node to start"; sleep 5
done

cardano-cli submit-tx \
            --testnet-magic 42 \
            --tx example/tx0.tx
cardano-cli submit-tx \
            --testnet-magic 42 \
            --tx example/tx1.tx

wait
