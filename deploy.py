from solcx import compile_standard
import json
from web3 import Web3

with open("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()

# Compile Our Solidity

compiled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}
            }
        },
    },
    solc_version="0.6.0",
)
# print(compiled_sol)
with open("compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)

# get bytecode
bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"][
    "bytecode"
]["object"]

# get abi
abi = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]

# for connecting to ganache
w3 = Web3(Web3.HTTPProvider("HTTP://127.0.0.1:7545"))
chain_id = 5777
my_address = "0x4d87b81cc321a3CE0e45aaa88e25f8D543C36973"
# private keys MUST start with 0x, if don't have it, put it
private_key = "0xf248e2cb9373a887191b721bbc60d59478ef2ca8c4ed39d416ffe4009812a014"

# Create the contract in python
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)
#Get the latesttest transaction
nonce = w3.eth.getTransactionCount(my_address)
print(nonce)
#1. Build a transaction
#2. Sign a transaction
#3. Send a transaction
                                            #transaction parameters
transaction = SimpleStorage.constructor().buildTransaction({
    "gasPrice": w3.eth.gas_price,
    "chainID": chain_id, 
    "from": my_address, 
    "nonce": nonce
    })

print(transaction)




