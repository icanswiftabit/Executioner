//
//  Bloodhound.swift
//  Executioner
//
//  Created by Blazej Wdowikowski on 01/07/2022.
//

import Foundation
import ArgumentParser
import XcodeProj
import PathKit

extension Executioner {
    struct Bloodhound: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Searches for not imported swift files"
        )

        @Argument(help: "Path to .xcodeproj")
        var xcodeprojPath: String

        func run() throws {
            let project = try XcodeProj(path: Path(xcodeprojPath))
            print("Scanning project's files...")
            let filesInProject = project.pbxproj.projects.map { findSwiftFiles(in: $0.mainGroup) }.flatMap { $0 }.sorted(by: <)
            let folder = Path(xcodeprojPath).parent()

            print("Scanning project's folder...")
            let filesInFolder = findSwiftFiles(at: folder).sorted(by: <)
            let diff = filesInFolder.difference(from: filesInProject)
            let outOfSyncFiles = diff.insertions.map { item -> String? in
                switch item {
                case .insert(offset: _, element: let element, associatedWith: _): return element
                default: return nil
                }
            }
                .compactMap { $0 }
            if diff.insertions.count > 0 {
                print("Number of out of sync files: \(outOfSyncFiles.count)")
                print(outOfSyncFiles.joined(separator: "\n"))
            } else {
                print("All is good!")
            }
        }

        private func findSwiftFiles(in group: PBXGroup) -> [String] {
            var files = [String]()
            for child in group.children {
                if let child = child as? PBXGroup {
                    files.append(contentsOf: findSwiftFiles(in: child))
                } else if let path = child.path,
                          !path.starts(with: "."),
                          path.contains(".swift"),
                          let file = path.split(separator: "/").last {
                    files.append(String(file))
                }
            }
            return files
        }

        private func findSwiftFiles(at path: Path) -> [String] {
            var files = [String]()
            guard let children = try? path.children() else {
                return files
            }
            for item in children {
                if item.lastComponentWithoutExtension.starts(with: ".") || item.lastComponentWithoutExtension.starts(with: "Pods")  {
                    continue
                }
                if item.isFile, item.lastComponent.contains(".swift") {
                    files.append(item.lastComponent)
                } else if !item.isFile {
                    files.append(contentsOf: findSwiftFiles(at: item))
                }
            }
            return files
        }
    }
}

