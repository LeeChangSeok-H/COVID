//
//  RegionModel.swift
//  COVID
//
//  Created by CHANGSEOK LEE on 2020/08/20.
//  Copyright © 2020 mangoslab. All rights reserved.
//

import Foundation

struct RegionModel {
    
    let regionName : String         // 시도명
    let deathCNT : String           // 사망자 수
    let incDec : String             // 전일대비 증감수
    let isolClearCNT : String       // 격리 해제 수
    let qurRate : String            // 10만명당 발생률
    let stdDay : String             // 기준일시
    let creatDT : String            // 등록일시분초
    let updateDT : String           // 수정일시분초
    
}
