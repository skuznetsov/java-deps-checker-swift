//
//  main.swift
//  JavaDependencyChecker
//
//  Created by Sergey Kuznetsov on 2018-10-07.
//  Copyright © 2018 IT Erudit, Inc. All rights reserved.
//

import Foundation


let loader = ClassLoader();

loader.loadClassesFromClasspath(dirName: "/Users/sergey/Projects/Java/apache-tomcat-9.0.12/lib/")
print(loader)