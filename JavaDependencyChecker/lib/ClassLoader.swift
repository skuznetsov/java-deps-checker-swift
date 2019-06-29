//
// Created by Sergey Kuznetsov on 2018-10-12.
// Copyright (c) 2018 IT Erudit, Inc. All rights reserved.
//

import Foundation
//import Zip

public class ClassLoader {

    var paths : [String] = []
    var classRegistry : [String: Int32] = [:]
    var classes : [String : ConstantPoolReader] = [:]
    var jars : [(inUse: Bool, fileName: String)] = []

    init() {
        let path = FileManager.default.currentDirectoryPath
        paths.append(path)
    }

//def logWarning (logEntry)
//logEntry = Time.now.to_s + ": " + logEntry
//puts logEntry
//end

    public func addPath (_ path: String) {
        if !paths.contains(path) {
            paths.append(path)
        }
    }

    public func addClasspath (_ path: String) {
        self.addPath(path)
    }

    public func markJarInUse (className: String) {
        if self.classRegistry.contains(where: {$0.key == className}) {
            let jarIndex = Int(self.classRegistry[className]!)
            if jarIndex > -1 {
                self.jars[jarIndex].inUse = true
            }
        }
    }

    public func getJarNameByClassName (className: String) -> String? {
        if self.classRegistry.contains(where: {$0.key == className}) {
            let jarIndex = Int(self.classRegistry[className]!)
            if jarIndex > -1 && jarIndex < self.jars.count {
                return self.jars[jarIndex].fileName
            } else {
                return nil
            }
        }
        return nil
    }

    public func loadClassBytes (_ bytes: Data?) -> ConstantPoolReader {
        let classObject = ConstantPoolReader(rawData: bytes)
        try? classObject.read()
        self.classes[classObject.getClassName()] = classObject
        return classObject
    }

    public func loadClassFromJar (className: String) -> ConstantPoolReader? {
        let classData = self.classes[className]
        if classData != nil {
            return classData
        }

        if className.hasPrefix("javax") {
            return nil
        }

        let jarIndex = self.classRegistry[className]
        if jarIndex == nil {
            // TODO: Add to separate structure to output in formatted way for further analysis
            print("WARNING: Class '\(className)' is not found in the CLASSPATH.")
            return nil
        }

        let classPath = self.jars[Int(jarIndex!)].fileName
        if classPath == nil {
            if !className.hasPrefix("javax") {
                print("Class \(className) cannot be found in the paths defined in the CLASSPATH. Please add the path and try again.")
            }
            return nil
        }

        var data: Data? = nil
        if FileManager.default.fileExists(atPath: classPath) {
            if classPath.hasSuffix(".jar") {

                let jarReader = JarReader(filename: classPath)
                data = jarReader.getFile(fileName: "\(className).class")
            } else {
                data = try! Data(contentsOf: URL(fileURLWithPath: classPath))
            }

            let ca = self.loadClassBytes(data)

            return ca
        }
        if !className.hasPrefix("java") {
            print("Class \(className) cannot be found in the paths defined in the CLASSPATH. Please add the path and try again.")
        }
        return nil
    }


    public func loadClassFile (fileName: String ) -> ConstantPoolReader? {
        let bytes = try! Data(contentsOf: URL(fileURLWithPath: fileName))
        let ca = self.loadClassBytes(bytes)
        let classes = ca.getExternalClasses()
        for className in classes {
            if !self.classes.contains(where: {$0.key == className}) {
                self.getClass(className: className)
            }
        }
        return ca
    }

    public func indexJarFile (fileName: String) {
        if !self.jars.contains(where: { $0.fileName == fileName }) {
            print("WARNING! Jar file '\(fileName)' was already added.")
        }
        self.jars.append((fileName: fileName, inUse: false))
        let jarIndex = self.jars.count - 1
        let jarReader = JarReader(filename: fileName)
        let zipEntries = jarReader.list
        zipEntries.forEach { zipEntry in
            if !zipEntry.isDirectory {
                if zipEntry.hasSuffix(".class") {
                    let className = zipEntry.replace(regex: "\\.class$", with: "")
                    if self.classRegistry[className!] != nil {
                        let jarFile = self.jars[Int(self.classRegistry[className!]!)].fileName
                        print("\(fileName) -> WARNING! Jar file '\(className!)' was already defined in \(jarFile).")
                    } else {
                        self.classRegistry[className!] = Int32(jarIndex)
                    }
                }
            }
        }
    }

    public func loadAllClassesFromJarFile (fileName: String) {
        let jarReader = JarReader(filename: fileName)
        let zipEntries = jarReader.list
        for zipEntry in zipEntries {
            if !zipEntry.isDirectory {
                if zipEntry.hasSuffix(".class") {
                    let bytes = jarReader.getFile(fileName: zipEntry)
                    self.loadClassBytes(bytes)
                }
            }
        }
    }


    public func isSimpleArray (_ className: String) -> Bool {
        return className.hasPrefix("[") && className !~ "^\\[+L"
    }

    public func getClass(className: String) -> ConstantPoolReader? {

        if self.isSimpleArray(className) {
            return nil
        }

        let className = className.replace(regex: "^\\[*L|;$", with: "")
        let ca = self.classes[className!]

        if ca != nil {
            return ca
        }

        for path in self.paths {
            let fileName = "\(path)/\(className!).class"
            if FileManager.default.fileExists(atPath: fileName) {
                return self.loadClassFile(fileName: fileName)
            }
        }

        let classData = self.loadClassFromJar(className: className!)

        if classData != nil {
            return classData
        }

        print("Implementation of the \(className!) class is not found.")

        return nil
    }

    public func loadClassFiles(dirName: String) {
        self.addPath(dirName);
        let files = try? FileManager.default.contentsOfDirectory(atPath: dirName)
        for file in files! {
            let p = "\(dirName)/\(file)"
            if FileManager.default.fileExists(atPath: p) {
                if file.hasSuffix(".class") {
                    self.loadClassFile(fileName: p)
                }
            } else if FileManager.default.directoryExists(dirName: p) {
                self.loadClassFiles(dirName: p)
            }
        }
    }


    public func indexJarFiles(dirName: String) {
        self.addPath(dirName);
        let files = try? FileManager.default.contentsOfDirectory(atPath: dirName)
        for file in files! {
            let p = "\(dirName)/\(file)"
            if FileManager.default.fileExists(atPath: p) {
                if file.hasSuffix(".jar") {
                    self.indexJarFile(fileName: p)
                }
            } else if FileManager.default.directoryExists(dirName: p) {
                self.indexJarFiles(dirName: p)
            }
        }
    }

    public func loadClassesFromClasspath(dirName: String) {
        self.addPath(dirName);
        let files = try? FileManager.default.contentsOfDirectory(atPath: dirName)
        for file in files! {
            let p = "\(dirName)/\(file)"
            if FileManager.default.fileExists(atPath: p) {
                if file.hasSuffix(".jar") {
                    self.loadAllClassesFromJarFile(fileName: p)
                } else if file.hasSuffix(".class") {
                    self.loadClassFile(fileName: file)
                }
            } else if FileManager.default.directoryExists(dirName: p) {
                self.loadClassesFromClasspath(dirName: p)
            }
        }
    }
}
