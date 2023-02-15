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
    
    //actionsheetを開く
    func showActionsheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title:"フォトライブラリ",style: .default) {
            action in
            self.showPicker(sourceType: .photoLibrary)
        })
        actionSheet.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //起動時に呼ばれる
    override func viewDidAppear(_ animated: Bool) {
        if self.imageView.image == nil {
            showActionsheet()
        }
    }
    
    // 画面タップ時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        showActionsheet()
    }
    
    //imagePikcerを開く
    func showPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        // sourceTypeが .photoLibraryなのでフォトライブラリーから画像を取得
        picker.delegate = self
        //フォトライブラリを起動
        self.present(picker, animated: true, completion: nil)
    }
    
    //imagePickerの画像取得時の処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMedeiaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        //画像の取得
        var image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        //画面の向きの補正
        let size = image.size
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //画像の指定
        self.imageView.image = image
        
        //imagePickerを閉じる
        picker.presentingViewController!.dismiss(animated: true, completion: nil)
        
        //画像分類の実行
        predict(image)
        
    }
    
    //imagePickerのキャンセル時の処理
    func imagePickerConrollerDidCancel(_ picker: UIImagePickerController) {
        //imagePickerを閉じる
        picker.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    //アラートの表示
    func showAlert(_ text: String!) {
        let alert = UIAlertController(title: text, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //画面分類の実行
    func  predict(_ image: UIImage) {
        DispatchQueue.global(qos: .default).async {
            //リクエストの生成
            let request = VNCoreMLRequest(model: self.model) {
                request, error in
                //結果取得次の処理
                //エラーアラート関連
                if error != nil {
                    self.showAlert(error!.localizedDescription)
                    return
                }
                
                //検出結果の取得
                //VNRequestのresultsプロパティを［VNClassification0bservation]にキャストして使用
                let observations = request.results as! [VNClassificationObservation]
                var text: String = "\n"
                
                //予想結果の第三位を検出
                for i in 0..<min(3, observations.count) {
                    let rate = Int(observations[i].confidence*100) //信頼度
                    let identfier = observations[i].identifier //分類名
                    text += "\(identfier) : \(rate)%\n"
                }
                
                //UI更新
                DispatchQueue.main.async {
                    self.resultText.text = text
                    print(text)
                    }
                }
            
            //入力画像のリサイズを指定
            //今回のモデルの入力画像は　「224×224ドット」のためフォトライブラリから取得した画像のリサイズしてから用いる
            request.imageCropAndScaleOption =  .centerCrop
            
            //UIImageをCIImageに変換
            //UIImageではリクエストに渡すことができなので(画像クラスの違い:https://giita.com/hrichii/items/c77a7cd07a42767985d5)
            let ciImage = CIImage(image: image)!
            
            //画像の向きを取得
            //画像クラスにはUIImageとCGImageがあるが、CIImageとCGImageは画像の向きを保持しない。なので画像の向きをUIImageから取得し、リクエストに指定する必要がある。
            //UIImageのUIImageOrienttationのプロパティでのUIImageの画像の向き　「UIImage.Orientation」を取得し「CGImagePropertOrienation」に変換してからリクエストに渡す
            let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
            
            //ハンドラの生成と実行
            //リクエストはハンドラを使って実行
            //ハンドラでのリクエストを実行後、結果がコールバックで買えさっる。コールバッグ型は　「VNRequestCompletionHandler」
            //VNRequestではresultプロパティで結果を保持
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            guard (try? handler.perform([request])) != nil else {
                return
                
            }
        }
    }
}





