//
// Created by Sergey Kuznetsov on 2018-10-14.
// Copyright (c) 2018 IT Erudit, Inc. All rights reserved.
//

import Foundation

extension String {

    var isDirectory: Bool {
        return self.suffix(1) == "/"
    }
}

public class JarReader {
    var filename: String? = nil

    init(filename: String) {
        self.filename = filename
    }

    private func executeCommand(command: String, args: [String]) -> Data {

        let task = Process()
        task.launchPath = command
        task.arguments = args

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()

        return data
    }

    public var list: [String] {
        if self.filename == nil {
            return []
        }
        let data = executeCommand(command: "/usr/bin/unzip", args: ["-l", self.filename!])
        let string: String? = String(data: data, encoding: String.Encoding.utf8)
        var list: [String] = string!.components(separatedBy:  "\n")
        list = [String](list.suffix(from: 3).prefix(through: list.count - 4))
        list = list.map{
            var result = $0.split(separator: " ", maxSplits: 3, omittingEmptySubsequences: true)
            return String(result[3]).trimmingCharacters(in: [" "])
        }

        return list
    }
    public func getFile(fileName: String) -> Data? {
        if self.filename == nil {
            return nil
        }
        let data = executeCommand(command: "/usr/bin/unzip", args: ["-p", self.filename!, fileName])
        return data
    }
}
