//
//  main.swift
//  Consume
//
//  Created by Steven Mortensen on 7/9/16.
//  Copyright © 2016 Steven Mortensen. All rights reserved.
//

//  This is a cipher that uses a deck of cards as a random number generator in order to produce a secure keystream.

import Cocoa

var alphabet = "_ABCDEFGHIJKLMNOPQRSTUVWXYZ"
//var deck = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,0]
var deck = [26, 5, 15, 15, 25, 10, 19, 6, 24, 2, 9, 21, 14, 25, 19, 1, 17, 12, 22, 21, 18, 6, 12, 9, 11, 0, 13, 24, 7, 3, 16, 3, 4, 17, 1, 11, 2, 23, 13, 4, 7, 8, 26, 20, 0, 10, 5, 14, 22, 8, 16, 23, 20, 18]
var resDeck = deck

func consumeEncrypt(_ myMessage: String, PTAProt: Bool, Pad: Bool) -> String {
    var plainText = myMessage.uppercased()
    plainText = plainText.replacingOccurrences(of: " ", with: "_")
    plainText = cleanInput(plainText)
    
    if Pad {
        var PTPadding = ""
        for i in 0..<4 {
            PTPadding += String(alphabet[alphabet.characters.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(26)))])
        }
        plainText = PTPadding + plainText
    }
    
    var cipherText = ""
    for pChar in plainText.characters {
        let pValue = alphabet.characters.distance(from: alphabet.startIndex, to: alphabet.range(of: String(pChar))!.lowerBound)
        var key = 0
        if(PTAProt) {
            key = (deck[0]+deck[53])%27
        } else {
            key = deck[0]
        }
        let cValue = (pValue + key)%27
        
        //print("\(pChar, pValue, cValue, alphabet[alphabet.startIndex.advancedBy(cValue)])")
        
        cutDeck(cValue, bottom: deck[0])
        cipherText += String(alphabet[alphabet.characters.index(alphabet.startIndex, offsetBy: cValue)])
    }
    return cipherText
}

func consumeDecrypt(_ myEncryptedMessage: String, PTAProt: Bool, Pad: Bool) -> String {
    var cipherText = myEncryptedMessage.uppercased()
    cipherText = cipherText.replacingOccurrences(of: " ", with: "_")
    cipherText = cleanInput(cipherText)
    var plainText = ""
    for cChar in cipherText.characters {
        let cValue = alphabet.characters.distance(from: alphabet.startIndex, to: alphabet.range(of: String(cChar))!.lowerBound)
        var key = 0
        if(PTAProt) {
            key = (deck[0]+deck[53])%27
        } else {
            key = deck[0]
        }
        let pValue = (cValue + 27 - key)%27
        
        //print("\(cChar, cValue, pValue, alphabet[alphabet.startIndex.advancedBy(pValue)])")
        
        cutDeck(cValue, bottom: deck[0])
        plainText += String(alphabet[alphabet.characters.index(alphabet.startIndex, offsetBy: pValue)])
    }
    if(Pad){
        plainText.removeSubrange(plainText.startIndex..<plainText.index(plainText.startIndex, offsetBy: 4))
    }
    return plainText
}

func cleanInput(_ input: String) -> String {
    let okayChars : Set<Character> = Set("_ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters)
    return String(input.characters.filter {okayChars.contains($0) })
}

func cutDeck(_ top: Int, bottom: Int) {
    var b = bottom
    var t = top
    if b == 0 {
        b = 27
    }
    if t == 0 {
        t = 27
    }
    let topExchange = deck[0...(t-1)]
    let bottomExchange = deck[(53-(b-1))...53]
    var middle = deck
    middle.removeFirst(t)
    middle.removeLast(b)
    deck = Array<Int>(bottomExchange + middle + topExchange)
}

//This allows me to deck.shuffle() for a new random deck
extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count.toIntMax() - 1 {
            let j = Int64(arc4random_uniform(UInt32(count.toIntMax() - i))) + i
            guard i != j else { continue }
            swap(&self[Int(i)], &self[Int(j)])
        }
    }
}

extension String {
    func insert(_ string:String,ind:Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
}

func resetDeck() {
    deck = resDeck
}

func randomDeck() {
    resDeck = deck.shuffle()
    deck = resDeck
    printDeck(resDeck)
}

func setDeck(_ newDeck: Array<Int>) {
    resDeck = newDeck
    deck = resDeck
}

func setDeck(_ newDeck: String) {
    var deckArray: Array<Int> = []
    for char in newDeck.characters {
        deckArray += [alphabet.characters.distance(from: alphabet.startIndex, to: alphabet.range(of: String(char))!.lowerBound)]
    }
    if deckArray.count == 54 {
        resDeck = deckArray
        deck = resDeck
    } else {
        print("Sorry, there was an incorrect number of cards in the deck. There must be 54.")
    }
}

func printDeck(_ pDeck: Array<Int>) {
    var deckString = ""
    for i in 0...(pDeck.count-1) {
        deckString += String(alphabet[alphabet.characters.index(alphabet.startIndex, offsetBy: pDeck[i])])
    }
    print(deckString)
}

//Start Program

var command = ""
var running = true
var ptaprotected = true
var padding = true

while running {
    print("Consume Cipher: \n  e – encrypt,\n  d – decrypt,\n  s – set the deck,\n  r – generate random deck,\n  pr – print restart deck,\n  p – print resulting deck,\n  prot – toggle pta protection,\n  pad - toggle padding,\n  x – exit:")
    command = readLine(strippingNewline: true)!
    if command == "e" || command == "E" {
        print("What would you like to encrypt?:")
        command = readLine(strippingNewline: true)!
        resetDeck()
        print("\(consumeEncrypt(command, PTAProt: ptaprotected, Pad: padding))\n")
        /*if (ptaprotected) {
            print("\(consumeEncrypt(command, PTAProt: true))\n")
        } else {
            print("\(consumeEncrypt(command, PTAProt: false))\n")  //TODO: THE saem fro dec
        }*/
    } else if command == "d" || command == "D" {
        print("What would you like to decrypt?:")
        command = readLine(strippingNewline: true)!
        resetDeck()
        print("\(consumeDecrypt(command, PTAProt: ptaprotected, Pad: padding))\n")
        /*if (ptaprotected) {
            print("\(consumeDecrypt(command, PTAProt: true))\n")
        } else {
            print("\(consumeDecrypt(command, PTAProt: false))\n")
        }*/
    } else if command == "s" || command == "S" {
        print("Set the deck:")
        command = readLine(strippingNewline: true)!
        setDeck(command)
    } else if command == "r" || command == "R" {
        randomDeck()
    } else if command == "p" || command == "P" {
        printDeck(deck)
    } else if command == "pr" || command == "PR" {
        printDeck(resDeck)
    } else if command == "x" || command == "X" {
        running = false
    } else if command == "prot" || command == "PROT" {
        if (ptaprotected == false) {
            ptaprotected = true
            print("PTA Protection Active")
        } else {
            ptaprotected = false
            print("No PTA Protection")
        }
    } else if command == "pad" || command == "PAD" {
        if (padding == false) {
            padding = true
            print("Padding Active")
        } else {
            padding = false
            print("No Padding")
        }
    }
}



