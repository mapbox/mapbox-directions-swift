#!/usr/bin/swift

import Foundation
//import MapboxDirections
import SwiftCLI

// input Directions or Map Mathcing JSON
// input RouteOptions or MatchOptions as arguments (or filepath?)
// decode/encode it into objects
// output JSON

let command = CLI(singleCommand: ProcessCommand())
command.goAndExit()

//guard CommandLine.arguments.count >= 2 else {
//    print("Nothing to say?")
//    exit(0)
//}
//
//guard let token = ProcessInfo.processInfo.environment["MAPBOX_ACCESS_TOKEN"] else {
//    print("MAPBOX_ACCESS_TOKEN not found")
//    exit(0)
//}
//
//let text = CommandLine.arguments[1]
//let options = SpeechOptions(text: text)
//var speech = SpeechSynthesizer(accessToken: token)
//
//let url = speech.url(forSynthesizing: options)
//print("URL: \(url)")
//
//do {
//    let data = try Data(contentsOf: url)
//    print("Data: \(data)")
//
//    let audioPlayer = try AVAudioPlayer(data: data)
//    audioPlayer.play()
//
//    RunLoop.main.run(until: Date().addingTimeInterval(audioPlayer.duration))
//} catch {
//    print("Error occured: \(error)")
//}
