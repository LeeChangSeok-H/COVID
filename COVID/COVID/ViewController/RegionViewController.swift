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
    @IBOutlet weak var regionDateTextField: UITextField!
    @IBOutlet weak var stackview: UIStackView!
    
    var regionViewModel = RegionViewModel()
    let disposeBag = DisposeBag()

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
        stackview.isHidden = true
        initFirstPieGraph()
        initSecondPieGraph()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "지역별 현황"
        regionDateTextField.text = SharedPreference.load(key: SharedPreferenceKey.SAVE_SELECTED_DATE)
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
    
    func bindViewModel(){
        regionDateTextField.rx.text.orEmpty
            .bind(to: regionViewModel.selectedDate_variable)
            .disposed(by: disposeBag)
        
        regionViewModel.regionModelArray_observable
        .subscribe(onNext: { regionModelArray in
            self.setFirstPieGraphData(array: regionModelArray)
            self.setSecondPieGraphData(array: regionModelArray)
        }).disposed(by: disposeBag)
    }
    
    func setFirstPieGraphData(array : [RegionModel]){
        for data in array{
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
    
    func setSecondPieGraphData(array : [RegionModel]){
        for data in array{
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
}
