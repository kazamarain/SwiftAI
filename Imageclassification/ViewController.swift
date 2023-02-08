//
//  ViewController.swift
//  Imageclassification
//
//  Created by ユウ・カザマ on 2023/02/08.
//

//hogehoge

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,
        UIImagePickerControllerDelegate,
        UINavigationControllerDelegate  {
    
    var model = try! VNCoreMLModel(for: MobileNetV2().model)

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            // Do any additonal setup after loading the view.
        }
    
    //actionsheetを開く
    func showActionsheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title:"フォトライブラリ",style: .default) {
            action in
            self.showPicker(shource: .photoLibrary)
        })
        actionSheet.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
            
        }
    }
    

