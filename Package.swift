// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "NKModalPresenter",
	platforms: [.iOS(.v9)],
	products: [
		.library(
			name: "NKModalPresenter",
			targets: ["NKModalPresenter"]),
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "NKModalPresenter",
			dependencies: [],
			path: "NKModalPresenter",
			exclude: ["Example"])
	]
)
