from gettext import install
from solcx import compile_standard, install_solc
from web3 import Web3
import os
from dotenv import load_dotenv

load_dotenv()

# from sympy import source
import json

with open("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()
    print(simple_storage_file)

install_solc("0.6.6")

compile_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}
            }
        },
    }
)

with open("compile_sol.json", "w") as file:
    json.dump(compile_sol, file)


# get bytecode

bytecode = compile_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"][
    "bytecode"
]["object"]

# get abi

abi = compile_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]

# for connecting to gnache

w3 = Web3(Web3.HTTPProvider("HTTP://127.0.0.1:7545"))
chain_id = 5777

# This address and private key will change via ganache everytime this gets executed as this is temp
my_address = "0x4d87b81cc321a3CE0e45aaa88e25f8D543C36973"
# private_key = "0xf248e2cb9373a887191b721bbc60d59478ef2ca8c4ed39d416ffe4009812a014"
private_key = os.getenv("PRIVATE_KEY")

# Create the contract in Python
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)
# Get the latest transaction
nonce = w3.eth.getTransactionCount(my_address)
# Submit the transaction that deploys the contract

print(nonce)

# Build a transaction
# Sign a transaction
# Send a transaction

transaction = SimpleStorage.constructor().buildTransaction(
    {
        "chainId": chain_id,
        "gasPrice": w3.eth.gas_price,
        "from": my_address,
        "nonce": nonce,
    }
)

# print(transaction)

signed_txn = w3.eth.account.sign_transaction(transaction, private_key=private_key)
print(signed_txn)

tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
tx_reciept = w3.eth.wait_for_transaction_receipt(tx_hash)

# working with contract
# contract address
# contract abi

simple_storage = w3.eth.contract(address=tx_reciept.contractAddress, abi=abi)

# call -> simulate making a call just to interact with BlockChain
# transact -> make a state change, to interact with BlockChain and make a state change

# initial value of favorite number
print(simple_storage.functions.retrieve().call())
print(simple_storage.functions.store(15).call())

##Code fails at this point
store_transaction = simple_storage.functions.store(15).buildTransaction(
    {
        "chainId": chain_id, 
        "from": my_address, 
        "nonce": nonce + 1
    }
)

signed_store_txn = w3.eth.account.sign_transaction(
    store_transaction, private_key=private_key
)

send_store_trx = w3.eth.send_raw_transaction(signed_store_txn.rawTransaction)
tx_reciept = w3.eth.wait_for_transaction_receipt(send_store_trx)

print('printing the transaction reciept')
print(tx_reciept)


Part that is failing here is :
store_transaction = simple_storage.functions.store(15).buildTransaction(
    {
        "gasPrice": w3.eth.gas_price, 
        "chainId": chain_id, 
        "from": my_address, 
        "nonce": nonce + 1
    }
)