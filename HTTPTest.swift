//
//  HTTPTest.swift
//  iOSTestApp2
//
//  Copyright © 2021 NowSecure. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class HTTPTest: UIViewController {
    @IBOutlet var memoryCapacityTextField: UITextField!
    @IBOutlet var diskCapacityTextField: UITextField!
    @IBOutlet var cacheTypeSegmentedControl: UISegmentedControl!
    @IBOutlet var urlTextField: UITextField!
    @IBOutlet var requestActivityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.memoryCapacityTextField.delegate = self
        self.diskCapacityTextField.delegate = self
        self.urlTextField.delegate = self
    }
    
    @IBAction func didTapMakeRequest(_ sender: Any) {
        guard let url = URL(string: self.urlTextField.text ?? "") else {
            self.showAlert("Invalid URL")
            return
        }
        
        makeRequest(with: url)
    }
    
    func makeRequest(with url: URL) {
        guard
            let memoryCapacity = Int(memoryCapacityTextField.text ?? ""),
            let diskCapacity = Int(diskCapacityTextField.text ?? "") else {
                self.showAlert("Invalid memory or disk capacity")
                return
            }
   
        let cache = CacheType(rawValue: self.cacheTypeSegmentedControl.selectedSegmentIndex)!
        let config = URLSessionConfiguration.default
        
        switch cache {
        case .shared:
            URLCache.shared = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        case .subclass:
            config.urlCache = MyCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        case .stock:
            config.urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        }
       
        self.requestActivityIndicatorView.startAnimating()
        
        let session = URLSession(configuration: config)
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.showAlert("An error occured while making the request: " + error!.localizedDescription)
                return
            }
            
            guard let data = data else {
                self.showAlert("<no data>")
                return
            }

            let body = String(data: data, encoding: .ascii)!
            self.showAlert(body)
        }
        
        task.resume()
    }
   
    func showAlert(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.requestActivityIndicatorView.stopAnimating()
        }
    }
}

@available(iOS 13.0, *)
extension HTTPTest: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

enum CacheType: Int {
    case shared = 0
    case subclass
    case stock
}

class MyCache: URLCache {
    override func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        print("storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest")
    }
    
    override func storeCachedResponse(_ cachedResponse: CachedURLResponse, for dataTask: URLSessionDataTask) {
        print("storeCachedResponse(_ cachedResponse: CachedURLResponse, for dataTask: URLSessionDataTask")
    }
}
