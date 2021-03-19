//
//  String+extensions.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 06.03.2021.
//

import Foundation

extension String {
    mutating func convertString() -> String {
        var stringCopy = self
        var arrayOfCharacters = Array<Character>(stringCopy)
        for character in arrayOfCharacters{
            if character == " " {
                let index = arrayOfCharacters.firstIndex(of: character)
                arrayOfCharacters[index!] = "_"
            }
        }
        var stringArray = [String]()
        for item in arrayOfCharacters {
            stringArray.append(String(item))
        }
        let string = stringArray.joined().lowercased()
        return string
    }
}
