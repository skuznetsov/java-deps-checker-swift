//
// Created by Sergey Kuznetsov on 2018-10-08.
// Copyright (c) 2018 IT Erudit, Inc. All rights reserved.
//

import Foundation


public class ConstantTag {
    var constantPool : ConstantPool? = nil
    public var tag : ConstantType? = nil
    init(_ cp : ConstantPool?) {
        constantPool = cp
    }
}

public class ClassTag: ConstantTag {
    public let tagName: String = "Class"
    public var text: String = ""
    public var className: String = ""
    public var nameIndex: UInt16 = 0

    override init (_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .Class
    }
}

public class FieldRefTag : ConstantTag {
    public var tagName: String = "FieldRef"
    var text: String = ""
    var className: String = ""
    var classIndex: UInt16 = 0
    var nameAndTypeIndex: UInt16 = 0
    var fieldName: String = ""
    var fieldType: String = ""

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .Fieldref
    }
}

public class MethodRefTag : ConstantTag {
    public var tagName : String = "MethodRef"
    public var className : String = ""
    public var classIndex : UInt16 = 0
    public var nameAndTypeIndex : UInt16 = 0
    public var methodName : String = ""
    public var methodType : String = ""
    public var text : String = ""

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .Methodref
    }
}

public class InterfaceMethodRefTag : ConstantTag {
    public var tagName : String = "InterfaceMethodRef"
    public var className : String = ""
    public var classIndex : UInt16 = 0
    public var nameAndTypeIndex : UInt16 = 0
    public var interfaeMethodName : String = ""
    public var interfaeMethodType : String = ""
    public var text : String = ""

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .InterfaceMethodref
    }
}

public class StringTag : ConstantTag {
    public var tagName : String = "String"
    public var stringIndex : UInt16 = 0

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .String
    }
}

public class IntegerTag : ConstantTag {
    public var tagName : String = "Integer"
    public var text : String = ""
    public var integer : Int32 = 0

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .Integer
    }
}

public class FloatTag : ConstantTag {
    public var tagName : String = "Float"
    public var text : String = ""
    public var float : Float = 0.0

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .Float
    }
}

public class LongTag : ConstantTag {
    public var tagName : String = "Long"
    public var text : String = ""
    public var long : Int64 = 0

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .Long
    }
}

public class DoubleTag : ConstantTag {
    public var tagName : String = "Double"
    public var text : String = ""
    public var double : Float64 = 0.0

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .Double
    }
}

public class NameAndTypeTag : ConstantTag {
    public var tagName : String = "NameAndType"
    public var name : String = ""
    public var nameIndex : UInt16 = 0
    public var type : String = ""
    public var signatureIndex : UInt16 = 0
    public var text : String = ""

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .NameAndType
    }
}

public class Utf8Tag : ConstantTag {
    public var tagName : String = "Utf8"
    public var string : String = ""

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .Utf8
    }
}

public class MethodHandleTag : ConstantTag {
    public var tagName : String = "MethodHandle"
    public var kind : String = ""
    public var referenceKind : UInt8? = nil
    public var reference : String = ""
    public var referenceIndex : UInt16? = nil
    public var text : String = ""

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .MethodHandle
    }
}

public class MethodTypeTag : ConstantTag {
    public var tagName : String = "MethodType"
    public var descriptor : String = ""
    public var descriptorIndex : UInt16 = 0
    public var text : String = ""

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .MethodType
    }
}

public class InvokeDynamicTag : ConstantTag {
    public var tagName : String = "InvokeDynamic"
    public var bootstrapMethodAttributeIndex : UInt16 = 0
    public var nameAndTypeIndex : UInt16 = 0
    public var name : String = ""
    public var type : String = ""
    public var text : String = ""

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .InvokeDynamic
    }
}

public class ModuleTag : ConstantTag {
    public var tagName : String = "Module"
    public var text : String = ""
    public var name : String = ""
    public var moduleNameIndex : UInt16 = 0

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .Module
    }
}

public class PackageTag : ConstantTag {
    public var tagName : String = "Package"
    public var text : String = ""
    public var name : String = ""
    public var packageNameIndex : UInt16 = 0

    override init(_ cp: ConstantPool?) {
        super.init(cp)
        self.tag = .Package
    }
}

public class ConstantPool {
    var ca : ConstantPoolReader? = nil
    var cp : [ConstantTag?]

    init (_ ca : ConstantPoolReader) {
        self.ca = ca
        self.cp = [ConstantTag(nil)]
    }

    public var length : Int {
        return self.cp.count
    }

    public func addTag(_ tagData : ConstantTag?) {
        self.cp.append(tagData)
    }

    public subscript (idx : Int ) -> ConstantTag?  {
        if idx < 0 || idx >= self.cp.count {
            return nil
        }
        return self.cp[idx]
    }
}
