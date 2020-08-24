//
//  RegionViewModel.swift
//  COVID
//
//  Created by CHANGSEOK LEE on 2020/08/20.
//  Copyright © 2020 mangoslab. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyXMLParser
import Charts

class RegionViewModel{

    var regionModelArray : [RegionModel]? = []
    
    let KEY = "275SOeWhh3LwvRCgwP41JMJ5jr2X%2FPfr%2BwYAl%2F3KKOjzd7QtFHIaA6PpmiHW793B1ZLz%2B9z5ZFmV4Q%2BIZIAbYg%3D%3D"
    let URL = "http://openapi.data.go.kr/openapi/service/rest/Covid19/getCovid19SidoInfStateJson"
    
    var selectedDate_variable = Variable<String>("")
    var regionModelArray_observable : Observable<[RegionModel]> = Observable<[RegionModel]>.just([])
    
    init() {
        self.getCOVIDData()
    }
    
    func getCOVIDData(){
        self.requestAPI(date: selectedDate_variable.value) { (response) in
            self.regionModelArray_observable = self.selectedDate_variable.asObservable()
                .map { _ in return response }
        }
    }

    func requestAPI(date : String, completionHandler: @escaping ([RegionModel]) -> Void) {
        let params = ["pageNo": "1","numOfRows":"10" ,"startCreateDt": "20200820" ,"endCreateDt": "20200820"]
        let url = self.getURL(url: self.URL, params: params)
        AF.request(url, method: .get, encoding: URLEncoding.default).responseString { (response) in
            switch response.result{
            case .success:
                self.regionModelArray?.removeAll()
                let responseString = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue )
                let xml = try! XML.parse(String(responseString!))
                for element in xml.response.body.items.item {
                    let regionName = element["gubun"].text ?? ""
                    let deathCNT = element["deathCnt"].text ?? ""
                    let incDec = element["incDec"].text ?? ""
                    let isolClearCNT = element["isolClearCnt"].text ?? ""
                    let qurRate = element["qurRate"].text ?? ""
                    let stdDay = element["stdDay"].text ?? ""
                    let creatDT = element["createDt"].text ?? ""
                    let updateDT = element["updateDt"].text ?? ""
                  
                    if regionName != "합계"{
                        let regionModel = RegionModel(regionName : regionName, deathCNT : deathCNT, incDec : incDec, isolClearCNT : isolClearCNT, qurRate : qurRate, stdDay : stdDay, creatDT : creatDT, updateDT : updateDT )
                        
                        self.regionModelArray?.append(regionModel)
                    }
                }
                completionHandler(self.regionModelArray!)
            case .failure:
                print("failure")
                completionHandler([])
            }
        }
    }
    
    func getURL(url:String, params:[String: Any]) -> URL {
        let urlParams = params.flatMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        let withURL = url + "?\(urlParams)"
        let encoded = withURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! + "&serviceKey=" + KEY
        return Foundation.URL(string:encoded)!
    }
}
