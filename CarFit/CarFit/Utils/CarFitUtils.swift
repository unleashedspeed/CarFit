//
//  CarFitUtils.swift
//  CarFit
//
//  Created by Saurabh Gupta on 06/07/20.
//  Copyright © 2020 Test Project. All rights reserved.
//

import Foundation

class CarFitUtils {
    static func dataFromFile(_ filename: String) -> Data? {
        @objc class TestClass: NSObject { }
        let bundle = Bundle(for: TestClass.self)
        if let path = bundle.path(forResource: filename, ofType: "json") {
            return (try? Data(contentsOf: URL(fileURLWithPath: path)))
        }
        
        return nil
    }
}
