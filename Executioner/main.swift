//
//  main.swift
//  Executioner
//
//  Created by Blazej Wdowikowski on 30/06/2022.
//

import Foundation
import ArgumentParser

/* TODO:
 - ignore list as option, by default [".", "Pods"]
 - account .gitignor to ignore list
 - keep full path
 */

struct Executioner: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Your pal in xcode's conflicts",
        subcommands: [Bloodhound.self],
        defaultSubcommand: Bloodhound.self
    )
}


Executioner.main()
