// swift-tools-version:5.0
//
//  Package.swift
//  Demo
//
//  Created by Daniel Yang on 2019/4/11.
//  Copyright © 2019 Daniel Yang. All rights reserved.
//


import PackageDescription

let package = Package(
    name: "VerticalTree",
    platforms: [.iOS("10.0")],
    products: [
        .library(
            name: "VerticalTree", 
            targets: ["VerticalTree"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "VerticalTree",
            dependencies: []),
        
    ]
)
