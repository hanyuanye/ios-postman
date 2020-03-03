//
//  ResponseParser.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-02.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation

extension Data {
    public var html: NSAttributedString? {
        try? NSAttributedString(
            data: self,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
    }
    
    public var json: NSAttributedString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: []),
              let prettyPrintedString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return NSAttributedString(string: prettyPrintedString)
    }
    
    public var response: NSAttributedString {
        if let html = html { return html }
        if let json = json { return json }
        
        return NSAttributedString()
    }
}
