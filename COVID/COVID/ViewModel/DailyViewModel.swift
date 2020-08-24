//
//  DailyViewModel.swift
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

class DailyViewModel{

    var dailyModelArray : [DailyModel]? = []
    
    let KEY = "275SOeWhh3LwvRCgwP41JMJ5jr2X%2FPfr%2BwYAl%2F3KKOjzd7QtFHIaA6PpmiHW793B1ZLz%2B9z5ZFmV4Q%2BIZIAbYg%3D%3D"
    let URL = "http://openapi.data.go.kr/openapi/service/rest/Covid19/getCovid19InfStateJson"
    
    var selectedDate_variable = Variable<String>("20200320")
    var dailyModelArray_observable : Observable<[DailyModel]> = Observable<[DailyModel]>.just([])
    
    init() {
        self.getCOVIDData()
    }
    
    func getCOVIDData(){
        self.requestAPI(date: selectedDate_variable.value) { (response) in
            self.dailyModelArray_observable = self.selectedDate_variable.asObservable()
                .map { _ in return response }
        }
    }

    func requestAPI(date : String, completionHandler: @escaping ([DailyModel]) -> Void) {
        let params = ["pageNo": "1","numOfRows":"10" ,"startCreateDt": "20200811" ,"endCreateDt": "20200817"]
        let url = self.getURL(url: self.URL, params: params)
        AF.request(url, method: .get, encoding: URLEncoding.default).responseString { (response) in
            switch response.result{
            case .success:
                self.dailyModelArray?.removeAll()
                let responseString = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue )
                let xml = try! XML.parse(String(responseString!))
                for element in xml.response.body.items.item {
                    let stateDT = element["stateDt"].text ?? ""
                    let stateTIME = element["stateTime"].text ?? ""
                    let decideCNT = element["decideCnt"].text ?? ""
                    let clearCNT = element["clearCnt"].text ?? ""
                    let examCNT = element["examCnt"].text ?? ""
                    let deathCNT = element["deathCnt"].text ?? ""
                    let careCNT = element["careCnt"].text ?? ""
                    let resultNegCNT = element["resutlNegCnt"].text ?? ""
                    let accExamCNT = element["accExamCnt"].text ?? ""
                    let accExamCompCNT = element["accExamCompCnt"].text ?? ""
                    let accDefRate = element["accDefRate"].text ?? ""
                    let createDT = element["createDt"].text ?? ""
                    let updateDT = element["updateDt"].text ?? ""
           
                    let dailyModel = DailyModel(stateDT: stateDT, stateTIME: stateTIME, decideCNT: decideCNT, clearCNT: clearCNT, examCNT: examCNT, deathCNT: deathCNT, careCNT: careCNT, resultNegCNT: resultNegCNT, accExamCNT: accExamCNT, accExamCompCNT: accExamCompCNT, accDefRate: accDefRate, createDT: createDT, updateDT: updateDT)
                
                    self.dailyModelArray?.append(dailyModel)
                }
                completionHandler(self.dailyModelArray!)
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
