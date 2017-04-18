//
//  Store.swift
//  SwissHomeFinder
//
//  Created by Yannick Heinrich on 18.04.17.
//  Copyright © 2017 yageek. All rights reserved.
//

import Foundation

public enum APIError: Error {
    case PayloadError
    case SerializeError
}
class Store {

    fileprivate let queue = DispatchQueue(label: "storeQueue")

    private init() { }
    public static let sharedInstance = Store()

    private var _offers: [Offer] = []
    private var offers: [Offer] {

        get {
            var tmp: [Offer] = []
            self.queue.sync {
                tmp = _offers
            }
            return tmp
        }
        set {
            queue.sync(flags: .barrier){
                _offers = newValue
            }
        }
    }

    public func getOffers(clearCache: Bool = false, success succesBlock: @escaping ([Offer]) -> Void, error errorBlock: @escaping (Error) -> Void) {

        if clearCache {
            offers.removeAll()
        }

        if offers.isEmpty {

            let task = URLSession.shared.downloadTask(with: URL(string: "https://swisshomefinder-164208.appspot.com/offers.json")!, completionHandler: { (url, response, error) in

                if
                    let resp = response as? HTTPURLResponse,
                    let url = url,
                    let stream = InputStream(url: url), resp.statusCode == 200 {

                    defer {
                        stream.close()
                    }

                    stream.open()

                    do {
                        let offersJSON = try JSONSerialization.jsonObject(with: stream, options: [])
                        guard let offersObjects = offersJSON as? [[String: Any]] else {
                            throw APIError.PayloadError
                        }

                        let offers = offersObjects.flatMap { Offer(json: $0) }

                        guard offers.count == offersObjects.count else {
                            DispatchQueue.main.async {
                                errorBlock(APIError.SerializeError)
                            }
                            return
                        }

                        self.offers = offers
                        DispatchQueue.main.async {
                            succesBlock(self.offers)
                        }


                    } catch let error {
                        DispatchQueue.main.async  {
                            print("Can not serialize element: \(error)")
                            errorBlock(error)
                        }
                    }

                } else {
                    DispatchQueue.main.async(execute: { 
                        errorBlock(APIError.PayloadError)
                    })
                }
            })

            task.resume()

        } else {

            DispatchQueue.main.async {
                succesBlock(self.offers)
            }
        }

    }
}
