//
//  SSLPinningDelegate.swift
//  Articles
//
//  Created by Dwistari on 15/04/25.
//

import Foundation

class SSLPinningDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Load local cert
        guard let certPath = Bundle.main.path(forResource: "spaceflightnewsapi_der", ofType: "cer"),
              let localCertData = try? Data(contentsOf: URL(fileURLWithPath: certPath)) else {
            print("❌ Local certificate not found or unreadable")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Compare server certs
        var isPinned = false
        let certCount = SecTrustGetCertificateCount(serverTrust)
        for i in 0..<certCount {
            if let certChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] {
                for cert in certChain {
                    let serverCertData = SecCertificateCopyData(cert) as Data
                    if serverCertData == localCertData {
                        isPinned = true
                        break
                    }
                }
            }
        }
        
        if isPinned {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            print("❌ Local certificate not found or unreadable")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
        
    }
}
