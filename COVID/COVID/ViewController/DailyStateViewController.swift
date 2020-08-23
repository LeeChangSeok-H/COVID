//
//  DailyStateViewController.swift
//  COVID
//
//  Created by CHANGSEOK LEE on 2020/08/21.
//  Copyright © 2020 mangoslab. All rights reserved.
//
import UIKit
import Charts
import TinyConstraints
import RxSwift
import Alamofire
import SwiftyXMLParser

class DailyStateViewController: UIViewController {
    
    @IBOutlet weak var dailyFirstView: UIView!
    @IBOutlet weak var dailySecondView: UIView!
    
    let KEY = "275SOeWhh3LwvRCgwP41JMJ5jr2X%2FPfr%2BwYAl%2F3KKOjzd7QtFHIaA6PpmiHW793B1ZLz%2B9z5ZFmV4Q%2BIZIAbYg%3D%3D"
    let URL = "http://openapi.data.go.kr/openapi/service/rest/Covid19/getCovid19InfStateJson"
    
    var dailyModelArray : [DailyModel]? = []
    var barChartData_decideCNT: [BarChartDataEntry] = []
    var barChartData_clearCNT: [BarChartDataEntry] = []
    var barChartData_deathCNT: [BarChartDataEntry] = []
    var barChartData_accExamCNT: [BarChartDataEntry] = []
    var barChartData_accExamCompCNT: [BarChartDataEntry] = []
    
    
    lazy var firstBarChartView : BarChartView = {
        let chartView = BarChartView()
        chartView.backgroundColor = .white
        chartView.rightAxis.enabled = false
        return chartView
    }()
    
    lazy var secondBarChartView : BarChartView = {
        let chartView = BarChartView()
        chartView.backgroundColor = .white
        chartView.rightAxis.enabled = false
        return chartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initFirstBarGraph()
        initSecondBarGraph()
        requestAPI()
    }
    
    func initFirstBarGraph(){
        dailyFirstView.addSubview(firstBarChartView)
        firstBarChartView.centerInSuperview()
        firstBarChartView.width(to: dailyFirstView)
        firstBarChartView.heightToWidth(of: dailyFirstView)
        
        let xAxis_first = firstBarChartView.xAxis
        xAxis_first.labelFont = .systemFont(ofSize: 6, weight: .light)
        xAxis_first.centerAxisLabelsEnabled = true
    }
    
    func initSecondBarGraph(){
        dailySecondView.addSubview(secondBarChartView)
        secondBarChartView.centerInSuperview()
        secondBarChartView.width(to: dailySecondView)
        secondBarChartView.heightToWidth(of: dailySecondView)
        
        let xAxis_second = secondBarChartView.xAxis
        xAxis_second.labelFont = .systemFont(ofSize: 6, weight: .light)
        xAxis_second.centerAxisLabelsEnabled = true
    }
    
    func setFirstBarGraphData(){
        let barWidth = 0.05
        let barSpace = 0.01
        let groupSpace = 0.02
        let groupCount = dailyModelArray?.count
        
        for data in dailyModelArray!{
            let stateDT = Double(data.stateDT)
            let decideCNT = Double(data.decideCNT)
            let clearCNT = Double(data.clearCNT)
            let deathCNT = Double(data.deathCNT)
            barChartData_decideCNT.append(BarChartDataEntry(x: stateDT!, y: decideCNT!))
            barChartData_clearCNT.append(BarChartDataEntry(x: stateDT!, y: clearCNT!))
            barChartData_deathCNT.append(BarChartDataEntry(x: stateDT!, y: deathCNT!))
            
        }
        let set_decideCNT = BarChartDataSet(entries: barChartData_decideCNT, label: "확진자 수")
        set_decideCNT.setColor(.red)
        let set_clearCNT = BarChartDataSet(entries: barChartData_clearCNT, label: "격리해제 수")
        set_clearCNT.setColor(.blue)
        let set_deathCNT = BarChartDataSet(entries: barChartData_deathCNT, label: "사망자 수")
        set_deathCNT.setColor(.black)
        let data = BarChartData(dataSets: [set_decideCNT, set_clearCNT, set_deathCNT])
        
        data.barWidth = barWidth
        
        let startValue = dailyModelArray![dailyModelArray!.startIndex].stateDT
        
        // restrict the x-axis range
        firstBarChartView.xAxis.axisMinimum = Double(startValue)!
        
        // groupWidthWithGroupSpace(...) is a helper that calculates the width each group needs based on the provided parameters
        firstBarChartView.xAxis.axisMaximum = Double(startValue)! + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(groupCount!)
        
        data.groupBars(fromX: Double(startValue)!, groupSpace: groupSpace, barSpace: barSpace)
        
        firstBarChartView.data = data
 
    }
    
    func setSecondBarGraphData(){
        let barWidth = 0.05
        let barSpace = 0.01
        let groupSpace = 0.02
        let groupCount = dailyModelArray?.count
           
        for data in dailyModelArray!{
            let stateDT = Double(data.stateDT)
            let accExamCNT = Double(data.accExamCNT)
            let accExamCompCNT = Double(data.accExamCompCNT)
            barChartData_accExamCNT.append(BarChartDataEntry(x: stateDT!, y: accExamCNT!))
            barChartData_accExamCompCNT.append(BarChartDataEntry(x: stateDT!, y: accExamCompCNT!))
               
        }
        let set_accExamCNT = BarChartDataSet(entries: barChartData_accExamCNT, label: "누적검사 수")
        set_accExamCNT.setColor(.yellow)
        let set_accExamCompCNT = BarChartDataSet(entries: barChartData_accExamCompCNT, label: "누적검사 완료 수")
        set_accExamCompCNT.setColor(.green)
        let data = BarChartData(dataSets: [set_accExamCNT, set_accExamCompCNT])
           
        data.barWidth = barWidth
           
        let startValue = dailyModelArray![dailyModelArray!.startIndex].stateDT
           
        // restrict the x-axis range
        secondBarChartView.xAxis.axisMinimum = Double(startValue)!
           
        // groupWidthWithGroupSpace(...) is a helper that calculates the width each group needs based on the provided parameters
        secondBarChartView.xAxis.axisMaximum = Double(startValue)! + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(groupCount!)
           
        data.groupBars(fromX: Double(startValue)!, groupSpace: groupSpace, barSpace: barSpace)
           
        secondBarChartView.data = data
    }

    func requestAPI(){
        let params = ["pageNo": "1","numOfRows":"10" ,"startCreateDt": "20200810" ,"endCreateDt": "20200816"]
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
                    
                    print("clearCNT = \(clearCNT)")

                }
                self.setFirstBarGraphData()
                self.setSecondBarGraphData()
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
