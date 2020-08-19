//
//  ViewController.swift
//  ERFileManager
//
//  Created by Mahmudul Hasan on 2020/7/27.
//  Copyright © 2020 Matrix Solution Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let image = UIImage(named: "test")
        let data = image?.pngData()
        
        var endURL = ERFileManager.sharedInstance.getURLFor(directoryType: .documentDirectory, subDirectory: "Test/01")!
        print(ERFileManager.sharedInstance.writeItem(directory: endURL, fileName: "test", fileExtension: FileType.PNG.rawValue, filedata: data!))
        
        
        endURL = endURL.appendingPathComponent("test.png")
        let isRename = ERFileManager.sharedInstance.renameItem(exisitngURL: endURL, newName: "hello.png")
    }
}

