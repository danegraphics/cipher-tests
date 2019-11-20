#Crash Cipher
# This is a cipher that uses a combination of substitutions and 
# additions modulo to both create a random keystream and encrypt the plaintext
import random

message = raw_input("Message: ")
alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
message = message.upper()
message = message.replace(" ", "_")
message = "".join(i for i in message if alpha.find(i) > -1)

#pad message with two random characters
message = "".join(random.sample(alpha,1) + random.sample(alpha,1)) + message

#get the key
key = raw_input("Key: ")

#generate a new key if there isn't one
if (len(key) < (len(alpha) + 1)):
    key = "".join(random.sample(alpha, len(alpha)) + random.sample(alpha,1))
    print("Key: " + key)

#prepare keystream
keystream = key[-2:]

ciphertext = ""
subMessage = ""
subCipher = ""

#begin encryption
for i in range(len(message)):
    #encrypt to get ciphertext
    
    #substitute the plaintext
    subMessage += key[alpha.find(message[i])]
    #encrypt substituted message with the keystream
    cIntermediate = alpha[(alpha.find(subMessage[i]) + alpha.find(keystream[i+1])) % len(alpha)]
    subCipher += cIntermediate
    #substitute the ciphertext
    ciphertext += key[alpha.find(cIntermediate)]
    
    #generate next character in keystream
    cValue = key[alpha.find(ciphertext[i])]
    kValue = key[alpha.find(keystream[i])]
    keystream += key[(alpha.find(cValue) + alpha.find(kValue)) % len(alpha)]

print("Message:    " + message)
print("SubMessage: " + subMessage)
print("Keystream: " + keystream)
print("subCipher:  " + subCipher)
print("Ciphertext: " + ciphertext)
