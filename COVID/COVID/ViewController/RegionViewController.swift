//
//  RegionViewController.swift
//  COVID
//
//  Created by CHANGSEOK LEE on 2020/08/20.
//  Copyright © 2020 mangoslab. All rights reserved.
//

import UIKit
import Charts
import TinyConstraints
import RxSwift
import RxCocoa
import Alamofire
import SwiftyXMLParser

class RegionViewController: UIViewController {
    
    @IBOutlet weak var regionFirstView: UIView!
    @IBOutlet weak var regionSecondView: UIView!
    
    var regionViewModel = RegionViewModel()
    let disposeBag = DisposeBag()
    
    let KEY = "275SOeWhh3LwvRCgwP41JMJ5jr2X%2FPfr%2BwYAl%2F3KKOjzd7QtFHIaA6PpmiHW793B1ZLz%2B9z5ZFmV4Q%2BIZIAbYg%3D%3D"
    let URL = "http://openapi.data.go.kr/openapi/service/rest/Covid19/getCovid19SidoInfStateJson"
  
    var regionModelArray : [RegionModel]? = []
    var pieChartData_deathCnt: [PieChartDataEntry] = []
    var pieChartData_ioslClearCnt: [PieChartDataEntry] = []
    
    lazy var firstPieChartView : PieChartView = {
        let chartView = PieChartView()
        chartView.backgroundColor = .white
        return chartView
    }()
    
    lazy var secondPieChartView : PieChartView = {
        let chartView = PieChartView()
        chartView.backgroundColor = .white
        return chartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initFirstPieGraph()
        initSecondPieGraph()
        requestAPI()
    }
    
    func initFirstPieGraph(){
        regionFirstView.addSubview(firstPieChartView)
        firstPieChartView.centerInSuperview()
        firstPieChartView.width(to: regionFirstView)
        firstPieChartView.heightToWidth(of: regionFirstView)
    }
    
    func initSecondPieGraph(){
        regionSecondView.addSubview(secondPieChartView)
        secondPieChartView.centerInSuperview()
        secondPieChartView.width(to: regionSecondView)
        secondPieChartView.heightToWidth(of: regionSecondView)
    }
    
    func setFirstPieGraphData(){
        for data in regionModelArray!{
            let regionName = data.regionName
            let deathCNT = Double(data.deathCNT) ?? 0

            if Int(deathCNT) > 10 {
                pieChartData_deathCnt.append(PieChartDataEntry(value: deathCNT, label: regionName))
            }
            
        }
        let set_decideCNT = PieChartDataSet(entries: pieChartData_deathCnt, label: "사망자 수")
        set_decideCNT.sliceSpace = 2
        set_decideCNT.colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        let data = PieChartData(dataSet: set_decideCNT)
        firstPieChartView.data = data
    }
    
    func setSecondPieGraphData(){
        for data in regionModelArray!{
            let regionName = data.regionName
            let isolClearCNT = Double(data.isolClearCNT) ?? 0

            if Int(isolClearCNT) > 1000 {
                pieChartData_ioslClearCnt.append(PieChartDataEntry(value: isolClearCNT, label: regionName))
            }
        }
        let set_ioslClearCnt = PieChartDataSet(entries: pieChartData_ioslClearCnt, label: "격리해제 수")
        set_ioslClearCnt.sliceSpace = 2
        set_ioslClearCnt.colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        let data = PieChartData(dataSet: set_ioslClearCnt)
        secondPieChartView.data = data
    }
    
    func requestAPI(){
        let params = ["pageNo": "1","numOfRows":"10" ,"startCreateDt": "20200810" ,"endCreateDt": "20200810"]
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
                self.setFirstPieGraphData()
                self.setSecondPieGraphData()
            case .failure:
                print("failure")
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
