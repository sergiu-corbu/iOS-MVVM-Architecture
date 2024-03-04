//
//  WebViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 23.11.2023.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    let sourceURL: URL
    private var webView: WKWebView?
    
    init(sourceURL: URL) {
        self.sourceURL = sourceURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        let webView = WKWebView()
        webView.backgroundColor = .cultured
        view = webView
        self.webView = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView?.load(URLRequest(url: sourceURL))
        webView?.allowsBackForwardNavigationGestures = true
    }
}
