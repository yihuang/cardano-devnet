#!/bin/sh
rm -rf example
./mkfiles.sh
supervisord -n -c supervisor.conf &

export CARDANO_NODE_SOCKET_PATH=example/node-bft1/node.sock
while [ ! -S "$CARDANO_NODE_SOCKET_PATH" ]; do
  echo "Waiting 5 seconds for node to start"; sleep 5
done

echo "Done"
wait
