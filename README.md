> Prepare `cardano-node` in `PATH` in advance.

```
$ ./serve.sh
...
```

```
$ CARDANO_NODE_SOCKET_PATH=./data/node.socket cardano-cli query tip --testnet-magic 42
{
    "blockNo": 0,
    "headerHash": "***",
    "slotNo": 0
}
```

