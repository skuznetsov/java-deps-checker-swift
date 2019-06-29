//
// Created by Sergey Kuznetsov on 2018-10-08.
// Copyright (c) 2018 IT Erudit, Inc. All rights reserved.
//

import Foundation

public class ConstantPoolReader {

    var minorVersion : UInt16 = 0
    var majorVersion : UInt16 = 0
    var accessFlags : UInt16 = 0
    var thisClass : UInt16 = 0
    var superClass : UInt16 = 0
    var reader : CodeReader? = nil
    var constantPool: ConstantPool? = nil

    init (rawData : Data?) {
        reader = CodeReader(from: rawData)
        constantPool = ConstantPool(self)
    }

    public func getClassName() -> String {
        var cp = constantPool
        var idx : Int = Int((cp![Int(thisClass)] as? ClassTag)!.nameIndex)
        var result = (cp![idx] as? Utf8Tag)!.string
        return result
    }

    public func getFriendlyClassName(className: String? ) -> String {
        var name = className ?? self.getClassName()
        name = name.replacingOccurrences(of: "/", with: ".")
        return name
    }

    public func getSuperClassName() -> String? {
        var cp = constantPool
        var idx : Int = Int((cp![Int(superClass)] as? ClassTag)!.nameIndex)
        var result = (cp![idx] as? Utf8Tag)!.string
        return result
    }

    public func getConstantPool() -> ConstantPool? {
        return self.constantPool
    }

    public func getExternalClasses() -> [String] {
        var cp = constantPool
        var results: [String] = []

        if cp != nil {
            var idx = 0
            while( idx < cp!.cp.count) {
                var cp_entry = cp!.cp[idx]
                if cp_entry == nil {
                    continue
                }
                if cp_entry! is ClassTag && idx != thisClass {
                    results.append((cp_entry! as! ClassTag).text)
                }
            }
        }

        return results
    }

    public func read() throws {
        let magic = self.reader!.readUInt()
        self.minorVersion = self.reader!.readUShort()
        self.majorVersion = self.reader!.readUShort()

        let constantPoolCount = self.reader!.readUShort()
        var idx = 1
        while ( idx < constantPoolCount ) {
            idx += 1
            var tagCode = ConstantType.init(rawValue: self.reader!.readByte())
            switch tagCode! {
                case ConstantType.Class:
                    var tag = ClassTag(self.constantPool)
                    tag.nameIndex = self.reader!.readUShort()
                    self.constantPool!.addTag(tag)
                    break

                case ConstantType.Utf8:
                    var tag = Utf8Tag(self.constantPool)
                    var length = self.reader!.readUShort()
                    tag.string = self.reader!.readString(Int(length))!
                    self.constantPool!.addTag(tag)
                    break

                case ConstantType.NameAndType:
                    var tag = NameAndTypeTag(self.constantPool)
                    tag.nameIndex = self.reader!.readUShort()
                    tag.signatureIndex = self.reader!.readUShort()
                    self.constantPool!.addTag(tag)
                    break

                case ConstantType.String:
                    var tag = StringTag(self.constantPool)
                    tag.stringIndex = self.reader!.readUShort()
                    self.constantPool!.addTag(tag)
                    break

                case ConstantType.Float:
                    var tag = FloatTag(self.constantPool)
                    tag.float = self.reader!.readFloat()
                    self.constantPool!.addTag(tag)
                    break

                case ConstantType.Integer:
                    var tag = IntegerTag(self.constantPool)
                    tag.integer = self.reader!.readInt()
                    self.constantPool!.addTag(tag)
                    break

                case ConstantType.Double:
                    var tag = DoubleTag(self.constantPool)
                    tag.double = self.reader!.readDouble()
                    self.constantPool!.addTag(tag)
                    idx += 1
                    self.constantPool!.addTag(nil)
                    break

                case ConstantType.Long:
                    var tag = LongTag(self.constantPool)
                    tag.long = self.reader!.readLong()
                    self.constantPool!.addTag(tag)
                    idx += 1
                    self.constantPool!.addTag(nil)
                    break

                case ConstantType.Fieldref:
                    var tag = FieldRefTag(self.constantPool)
                    tag.classIndex = self.reader!.readUShort()
                    tag.nameAndTypeIndex = self.reader!.readUShort()
                    self.constantPool!.addTag(tag)
                    break

                case ConstantType.Methodref:
                    var tag = MethodRefTag(self.constantPool)
                    tag.classIndex = self.reader!.readUShort()
                    tag.nameAndTypeIndex = self.reader!.readUShort()
                    self.constantPool!.addTag(tag)
                    break

                case ConstantType.InterfaceMethodref:
                    var tag = InterfaceMethodRefTag(self.constantPool)
                    tag.classIndex = self.reader!.readUShort()
                    tag.nameAndTypeIndex = self.reader!.readUShort()
                    self.constantPool!.addTag(tag)
                    break

                case ConstantType.MethodHandle:
                    var tag = MethodHandleTag(self.constantPool)
                    tag.referenceKind = self.reader!.readByte()
                    tag.referenceIndex = self.reader!.readUShort()
                    self.constantPool!.addTag(tag)
                    break

                case ConstantType.MethodType:
                    var tag = MethodTypeTag(self.constantPool)
                    tag.descriptorIndex = self.reader!.readUShort()
                    self.constantPool!.addTag(tag)
                    break

                case ConstantType.InvokeDynamic:
                    var tag = InvokeDynamicTag(self.constantPool)
                    tag.bootstrapMethodAttributeIndex = self.reader!.readUShort()
                    tag.nameAndTypeIndex = self.reader!.readUShort()
                    self.constantPool!.addTag(tag)
                    break

                case ConstantType.Module:
                    var tag = ModuleTag(self.constantPool)
                    tag.moduleNameIndex = self.reader!.readUShort()
                    self.constantPool!.addTag(tag)
                    break

                case ConstantType.Package:
                    var tag = PackageTag(self.constantPool)
                    tag.packageNameIndex = self.reader!.readUShort()
                    self.constantPool!.addTag(tag)
                    break
                default:
                    print("Unknown constant tag")
            }
        }
        self.accessFlags = self.reader!.readUShort()
        self.thisClass = self.reader!.readUShort()
        self.superClass = self.reader!.readUShort()
    }






}
