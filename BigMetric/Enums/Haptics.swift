//  Haptics.swift
//  howFar Watch App
//
//  Created by Grant Perry on: 3/3/23.
//						Modified on: Sunday December 31, 2023 at 10:20:57 AM

import WatchKit

enum PlayHaptic {
   case start, 
		  stop,
		  success,
		  critical,
		  notify,
		  up,
		  down,
		  fail

   static func tap(_ type: PlayHaptic) {
#if os(watchOS)
      let device = WKInterfaceDevice.current()
      switch type {
         case .start:
            device.play(.start)
         case .stop:
            device.play(.stop)
         case .success:
            device.play(.success)
         case .critical:
            device.play(.underwaterDepthCriticalPrompt)
         case .notify:
            device.play(.notification)
         case .up:
            device.play( .directionUp)
         case .down:
            device.play(.directionDown)
			case .fail:
				device.play(.failure)
      }
#elseif os(iOS)
      switch type {
         case .start:
            print(".start")
         case .stop:
            print(".stop")
         case .success:
         print(".success")
         default:
            print("default")

      }
#endif
   }
}




