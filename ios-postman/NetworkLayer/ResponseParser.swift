//
//  ResponseParser.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-02.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation

let ResponseParser = ResponseParserManager()

struct ResponseParserManager {
    
    var html: (Data) -> NSAttributedString?
    var json: (Data) -> NSAttributedString?
    var response: (Data) -> NSAttributedString?
    
    init() {
        html = { $0.html }
        json = { $0.json }
        response = { $0.response }
    }
    
}

extension Data {
    
    fileprivate var html: NSAttributedString? {
        try? NSAttributedString(
            data: self,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
    }
    
    fileprivate var json: NSAttributedString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        print(prettyPrintedString)
        
        return NSAttributedString(string: prettyPrintedString)
    }

    fileprivate var response: NSAttributedString {
        if let json = json { return json }
        if let html = html { return html }
        
        return NSAttributedString()
    }
    
}
