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

class RegionViewModel{
    let searchText = Variable("")
    
    lazy var data: Driver<[RegionModel]> = {
        
        return Observable.of([RegionModel]()).asDriver(onErrorJustReturn: [])
    }()
}
