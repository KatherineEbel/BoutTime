//
//  ErrorTypes.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/25/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

enum ResourceError: Error {
  case InvalidResource
  case ConversionError
}

enum BoutTimeError: Error {
  case LoadSoundError
  case StartRoundError
}
