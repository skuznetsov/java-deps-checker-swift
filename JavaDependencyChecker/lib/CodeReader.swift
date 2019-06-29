//
// Created by Sergey Kuznetsov on 2018-10-07.
// Copyright (c) 2018 IT Erudit, Inc. All rights reserved.
//

import Foundation

public class CodeReader {
    public var pc : Int
    private var data: Data? = nil

    init( from data: Data? ) {
        self.data = data
        self.pc = 0
    }

    // TODO: Fix it
    public func eof() -> Bool {
        return self.pc >= self.data!.count
    }

    public func readByte() -> UInt8 {
        let value : UInt8 = self.data![self.pc]
        self.pc += 1
        return value
    }

    public func readUShort() -> UInt16 {
        let value : UInt16 = UInt16(readByte()) << 8 + UInt16(readByte())
        return value
    }

    public func readShort() -> Int16 {
        let value : Int16 = Int16(readByte()) << 8 | Int16(readByte())
        return value
    }

    public func readUInt() -> UInt32 {
        let value : UInt32 = UInt32(readUShort()) << 16 | UInt32(readUShort())
        return value
    }

    public func readInt() -> Int32 {
        let value : Int32 = Int32(readShort()) << 16 | Int32(readShort())
        return value
    }

    public func readULong() -> UInt64 {
        let value : UInt64 = UInt64(readUInt()) << 32 | UInt64(readUInt())
        return value
    }

    public func readLong() -> Int64 {
        let value : Int64 = Int64(readInt()) << 32 | Int64(readInt())
        return value
    }

    public func readFloat() -> Float {
        let rawValue = readUInt()
        return Float(bitPattern: rawValue) // UInt32(bigEndian: rawValue )
    }

    public func readDouble() -> Double {
        let rawValue = readULong()
        return Double(bitPattern: rawValue) // UInt32(bigEndian: rawValue )
    }

    public func readBytes(_ length : Int) -> [UInt8] {
        let count = self.data!.count / MemoryLayout<UInt8>.size
        var byteArray = [UInt8](repeating: 0, count: count)
        self.data![pc..<pc+length].copyBytes(to: &byteArray, count: count)
        pc += length
        return byteArray
    }

    public func readString(_ length : Int) -> String? {
        let subdata = self.data![pc..<pc+length]
        let result : String? = String(data: subdata, encoding: String.Encoding.utf8)
        pc += length
        return result
    }
}
