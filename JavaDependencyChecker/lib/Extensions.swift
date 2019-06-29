//
// Created by Sergey Kuznetsov on 2018-10-15.
// Copyright (c) 2018 IT Erudit, Inc. All rights reserved.
//

import Foundation

infix operator =~ : ComparisonPrecedence
infix operator !~ : ComparisonPrecedence

extension String {
    public func match(_ regex: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: regex) else { return false }
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }

    public func replace(regex: String, with: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: regex) else { return nil }
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.stringByReplacingMatches(in: self, range: range, withTemplate: with)
    }

    static func =~ (lhs: String, rhs: String) -> Bool {
        return lhs.match(rhs)
    }

    static func !~ (lhs: String, rhs: String) -> Bool {
        return !lhs.match(rhs)
    }
}

extension FileManager {
    public func directoryExists(dirName: String) -> Bool {
        return (try? FileManager.default.contentsOfDirectory(atPath: dirName)) != nil
    }
}

