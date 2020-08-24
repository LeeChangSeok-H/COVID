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
    @IBOutlet weak var dailyDate: UILabel!
    @IBOutlet weak var stackview: UIStackView!
    
    var dailyViewModel = DailyViewModel()
    let disposeBag = DisposeBag()
    
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
        stackview.isHidden = true
        initFirstBarGraph()
        initSecondBarGraph()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "날짜별 현황"
        dailyDate.text = SharedPreference.load(key: SharedPreferenceKey.SAVE_SELECTED_DATE)
    }
    override func viewDidDisappear(_ animated: Bool) {
        bindViewModel()
    }
    
    func initFirstBarGraph(){
        dailyFirstView.addSubview(firstBarChartView)
        firstBarChartView.centerInSuperview()
        firstBarChartView.width(to: dailyFirstView)
        firstBarChartView.heightToWidth(of: dailyFirstView)
        
        let xAxis_first = firstBarChartView.xAxis
        xAxis_first.enabled = false
    }
    
    func initSecondBarGraph(){
        dailySecondView.addSubview(secondBarChartView)
        secondBarChartView.centerInSuperview()
        secondBarChartView.width(to: dailySecondView)
        secondBarChartView.heightToWidth(of: dailySecondView)
        
        let xAxis_second = secondBarChartView.xAxis
        xAxis_second.enabled = false
    }
    
    func bindViewModel(){
        //dailyViewModel.selectedDate_variable = Variable<String>(date)
        
        dailyViewModel.dailyModelArray_observable
        .subscribe(onNext: { dailyModelArray in
            self.setFirstBarGraphData(array: dailyModelArray)
            self.setSecondBarGraphData(array: dailyModelArray)
        }).disposed(by: disposeBag)
    }
    
    func setFirstBarGraphData(array : [DailyModel]){
        let barWidth = 0.05
        let barSpace = 0.01
        let groupSpace = 0.02
        let groupCount = array.count
        
        for data in array{
            let stateDT = Double(data.stateDT)
            let decideCNT = Double(data.decideCNT)
            let clearCNT = Double(data.clearCNT)
            let deathCNT = Double(data.deathCNT)
            barChartData_decideCNT.append(BarChartDataEntry(x: stateDT!, y: decideCNT!))
            barChartData_clearCNT.append(BarChartDataEntry(x: stateDT!, y: clearCNT!))
            barChartData_deathCNT.append(BarChartDataEntry(x: stateDT!, y: deathCNT!))
            
        }
        let set_decideCNT = BarChartDataSet(entries: barChartData_decideCNT, label: "확진자수")
        set_decideCNT.setColor(.red)
        let set_clearCNT = BarChartDataSet(entries: barChartData_clearCNT, label: "격리해제수")
        set_clearCNT.setColor(.blue)
        let set_deathCNT = BarChartDataSet(entries: barChartData_deathCNT, label: "사망자수")
        set_deathCNT.setColor(.black)
        let data = BarChartData(dataSets: [set_decideCNT, set_clearCNT, set_deathCNT])
        
        data.barWidth = barWidth
        
        if groupCount != 0{
            let startValue = array[array.startIndex].stateDT
            
            // restrict the x-axis range
            firstBarChartView.xAxis.axisMinimum = Double(startValue)!
            
            // groupWidthWithGroupSpace(...) is a helper that calculates the width each group needs based on the provided parameters
            firstBarChartView.xAxis.axisMaximum = Double(startValue)! + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(groupCount)
            
            data.groupBars(fromX: Double(startValue)!, groupSpace: groupSpace, barSpace: barSpace)
            
            firstBarChartView.data = data
        }
    }
    
    func setSecondBarGraphData(array : [DailyModel]){
        let barWidth = 0.05
        let barSpace = 0.01
        let groupSpace = 0.02
        let groupCount = array.count
           
        for data in array{
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
           
        if groupCount != 0{
            let startValue = array[array.startIndex].stateDT
               
            // restrict the x-axis range
            secondBarChartView.xAxis.axisMinimum = Double(startValue)!
               
            // groupWidthWithGroupSpace(...) is a helper that calculates the width each group needs based on the provided parameters
            secondBarChartView.xAxis.axisMaximum = Double(startValue)! + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(groupCount)
               
            data.groupBars(fromX: Double(startValue)!, groupSpace: groupSpace, barSpace: barSpace)
               
            secondBarChartView.data = data
        }
    }
}
