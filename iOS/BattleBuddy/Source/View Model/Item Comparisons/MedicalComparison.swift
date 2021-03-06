//
//  MedicalComparison.swift
//  BattleBuddy
//
//  Created by Mike on 7/14/19.
//  Copyright © 2019 Veritas. All rights reserved.
//

import UIKit

struct MedicalComparison: ItemComparison {
    var propertyType: ComparablePropertyType = .medical
    var itemsBeingCompared: [Comparable]
    var possibleOptions: [Comparable] = []//ItemController(itemFilter: MedicalFilter()).getItems()
    var recommendedOptions: [Comparable]
    var recommendedOptionsTitle: String?
    var secondaryRecommendedOptions: [Comparable] = []
    var secondaryRecommendedOptionsTitle: String? = nil
    var propertyOptions: [ComparableProperty] = ComparableProperty.propertiesForType(type: .medical)
    var preferRecommended: Bool = true

    init(_ initialMed: Medical? = nil, allMedical: [Medical]) {
        if let medical = initialMed {
            self.itemsBeingCompared = MedicalComparison.generateRecommendedOptions(medical, allMedical: allMedical)
            recommendedOptions = self.itemsBeingCompared

            // Filter out recommendations from all possible
            for recommended in recommendedOptions {
                possibleOptions.removeAll{ $0.identifier == recommended.identifier }
            }
        } else {
            itemsBeingCompared = []
            recommendedOptions = []
        }
    }

    private static func generateRecommendedOptions(_ initialMed: Medical, allMedical: [Medical]) -> [Medical] {
        let medicalMatchingType = allMedical.filter {
            if initialMed.medicalItemType != $0.medicalItemType { return false }
            return true
        }
        return medicalMatchingType
    }

    func getComparedItemsSummaryMap() -> [ComparableProperty : PropertyRange] {
        var useCountRange = PropertyRange()
        var useTimeRange = PropertyRange()
        var effectDurationRange = PropertyRange()

        for case let med as Medical in itemsBeingCompared {
            useCountRange.updatedRangeIfNeeded(candidateValue: Float(med.totalUses))
            useTimeRange.updatedRangeIfNeeded(candidateValue: Float(med.useTime))
            effectDurationRange.updatedRangeIfNeeded(candidateValue: Float(med.effectDuration))
        }

        return [
            .useCount: useCountRange,
            .useTime: useTimeRange,
            .effectDuration: effectDurationRange,
            .removesBloodloss: PropertyRange(minValue: 0, maxValue: 1),
            .removesPain: PropertyRange(minValue: 0, maxValue: 1),
            .removesFracture: PropertyRange(minValue: 0, maxValue: 1),
            .removesContusion: PropertyRange(minValue: 0, maxValue: 1)
        ]
    }

    func getPercentValue(item: Comparable, property: ComparableProperty, traitCollection: UITraitCollection) -> Float {
        guard let med = item as? Medical else { fatalError() }
        let range = getComparedItemsSummaryMap()[property]!

        switch property {
        case .useCount: return scaledValue(propertyValue: Float(med.totalUses), range: range, traitCollection: traitCollection)
        case .useTime: return scaledValue(propertyValue: Float(med.useTime), range: range, traitCollection: traitCollection)
        case .effectDuration: return scaledValue(propertyValue: Float(med.effectDuration), range: range, traitCollection: traitCollection)
        case .removesBloodloss: return scaledValue(boolValue: med.removesBloodloss, range: range, traitCollection: traitCollection)
        case .removesPain: return scaledValue(boolValue: med.removesPain, range: range, traitCollection: traitCollection)
        case .removesFracture: return scaledValue(boolValue: med.removesFracture, range: range, traitCollection: traitCollection)
        case .removesContusion: return scaledValue(boolValue: med.removesContusion, range: range, traitCollection: traitCollection)
        default: fatalError()
        }
    }
}
