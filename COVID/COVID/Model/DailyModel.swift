//
//  DailyModel.swift
//  COVID
//
//  Created by CHANGSEOK LEE on 2020/08/20.
//  Copyright © 2020 mangoslab. All rights reserved.
//

import Foundation

struct DailyModel {
    let stateDT : String            // 기준일
    let stateTIME : String          // 기준시간
    let decideCNT : String          // 확진자 수
    let clearCNT : String           // 격리해제 수
    let examCNT : String            // 검사진행 수
    let deathCNT : String           // 사망자 수
    let careCNT : String            // 치료중 환자 수
    let resultNegCNT : String       // 결과 음성 수
    let accExamCNT : String         // 누적 검사 수
    let accExamCompCNT : String     // 누적 검사 완료 수
    let accDefRate : String         // 누적 확진률
    let createDT : String           // 등록일시분초
    let updateDT : String           // 수정일시분초
}
