class Dragon {
    let name : String

    var limited : Limited
    
    let rarity : Rarity
    let elements : Set<DragonElement>
    let breedRequirements : Set<BreedRequirement>
    let breedTime : String
    let breedPercentage : BreedPercentage
    let cloneSocialPercentage : BreedPercentage
    let cloneNormalPercentage : BreedPercentage
    let cloneRiftPercentage : BreedPercentage    
    let quest : String

    init?(name: String, limited: Limited, rarity: Rarity, elements: Set<DragonElement>, breedRequirements: Set<BreedRequirement>, breedTime: String, breedPercentage: BreedPercentage, cloneSocialPercentage: BreedPercentage, cloneNormalPercentage: BreedPercentage, cloneRiftPercentage: BreedPercentage, quest: String) {
        self.name = name
        self.limited = limited
        self.rarity = rarity
        self.elements = elements
        self.breedRequirements = breedRequirements
        self.breedTime = breedTime
        self.breedPercentage = breedPercentage
        self.cloneSocialPercentage = cloneSocialPercentage
        self.cloneNormalPercentage = cloneNormalPercentage
        self.cloneRiftPercentage = cloneRiftPercentage
        self.quest = quest
    }

    convenience init?(fields: [String]) {        
        guard fields.count == 11 else {
        print("Unexpected field length when processing \(fields) of count \(fields.count).")
        return nil
    }
        var dragonElements : Set<DragonElement> {
            var dragonElements = Set<DragonElement>()
            var elementTag = ""
            for c in fields[3] {
                if c.isUppercase, let dragonElement = DragonElement(elementTag) {                 
                    dragonElements.insert(dragonElement)
                    elementTag = ""
                }
                elementTag.append(c)
            }
            if let lastElement = DragonElement(elementTag) {
                dragonElements.insert(lastElement)
            }
            return dragonElements
        }
        
        var breedRequirements : Set<BreedRequirement> {
            let requirements = fields[4].separate(at: "+")
            var breedRequirements = Set<BreedRequirement>()
            for requirement in requirements {
                if let breedRequirement = BreedRequirement(requirement) {
                    breedRequirements.insert(breedRequirement)
                }
           }
            return breedRequirements
       }
        
        if let rarity = Rarity(fields[2]),
           let breedPercentage = BreedPercentage(fields[6]),
           let cloneSocialPercentage = BreedPercentage(fields[7]),
           let cloneNormalPercentage = BreedPercentage(fields[8]),
           let cloneRiftPercentage = BreedPercentage(fields[9]) {
            self.init(name: fields[0], limited: Limited(fields[1]), rarity: rarity, elements: dragonElements, breedRequirements: breedRequirements, breedTime: fields[5], breedPercentage: breedPercentage, cloneSocialPercentage: cloneSocialPercentage, cloneNormalPercentage: cloneNormalPercentage, cloneRiftPercentage: cloneRiftPercentage, quest: fields[10])
        } else {
            return nil
        }
    }    

    convenience init?(line: String) {
        let fields = line.components(separatedBy: ",")
        self.init(fields: fields)
    }

    func hasElement(_ dragonElement: DragonElement) -> Bool {
        return elements.contains(dragonElement)
    }    

    func hasElements(_ dragonElements: [DragonElement]) -> Bool {
        for element in dragonElements {
            if !hasElement(element) {
                return false
            }
        }
        return true
    }

    func primaryElements() -> Set<PrimaryElement> {
        var primaryElements = Set<PrimaryElement>()
        for element in elements {
            if case let .primary(primaryElement) = element {
                primaryElements.insert(primaryElement)
            }
        }
        return primaryElements
    }

    func hasName(_ dragonName: String) -> Bool {
        return name == dragonName
    }

    func isBreedResult(_ breedInformation: BreedInformation) -> Bool {
        let breedComponents = breedInformation.breedComponents
        for breedRequirement in breedRequirements {
            switch breedRequirement {
            case .dragon(let dragon):
                if !breedComponents.contains(.dragon(dragon)) {
                    return false
                }
            case .dragonElement(let element):
                if !breedComponents.contains(.dragonElement(element)) {
                    return false
                }
            case .elementCount(let count):
                if count > breedInformation.elementCount {
                    return false
                }
            case .unbreedable:
                return false
            case .specialRequirement:
                break
            }
        }                
        if limited == .unavailable {
            return false
        }
        return true
    }

    func breedComponents() -> Set<BreedRequirement> {
        var breedingComponents = Set<BreedRequirement>([.dragon(name)])
        for element in elements {
            breedingComponents.insert(.dragonElement(element))
        }
        return breedingComponents
    }

    func satisfiesBreedRequirements(_ breedRequirements: Set<BreedRequirement>) -> Bool {
        var satisfied = true
        for requirement in breedRequirements {
            satisfied = satisfiesBreedRequirement(requirement)
            if !satisfied {
                return false
            }
        }
        return true
    }

    func satisfiesBreedRequirement(_ breedRequirement: BreedRequirement) -> Bool {
        if case let .dragon(dragonName) = breedRequirement {
            return name == dragonName
        }
        if case let .dragonElement(dragonElement) = breedRequirement {
            return elements.contains(dragonElement)
        }
        return true
    }
}

extension Dragon : CustomStringConvertible {
    var description : String {
        var description = "\(name),"
        description += "\(limited),"
        description += "\(rarity),"
        for element in Array(elements).sorted() {
            switch element {
            case .primary(let primaryElement) :
                switch primaryElement {
                case .plant: description += "P"
                case .fire: description += "F"
                case .earth: description += "E"
                case .cold: description += "C"
                case .lightning: description += "L"
                case .water: description += "W"
                case .air: description += "A"
                case .metal: description += "M"
                case .light: description += "I"
                case .dark: description += "D"                             
                }                
                case .epic(let epicElement) :
                    switch epicElement {
                    case .rift : description += "R"
                    case .apocalypse : description += "Ap"
                    case .aura : description += "Au"
                    case .chrysalis : description += "Ch"
                    case .crystalline : description += "Cr"
                    case .dream : description += "Dr"
                    case .galaxy : description += "Ga"
                    case .gemstone : description += "Ge"
                    case .hidden : description += "Hi"
                    case .melody : description += "Me"
                    case .monolith : description += "Mh"
                    case .moon : description += "Mo"
                    case .olympus : description += "Ol"
                    case .ornamental : description += "Or"
                    case .rainbow : description += "Rb"
                    case .seasonal : description += "Se"
                    case .snowflake : description += "Sn"
                    case .sun : description += "Su"
                    case .surface : description += "Sf"
                    case .treasure : description += "Tr"
                    case .zodiac : description += "Zo"
                }
            }
        }
        description += ","
        for requirementIndex in 0 ..< breedRequirements.count {
            description += "\(Array(breedRequirements)[requirementIndex])"
            if requirementIndex < breedRequirements.count - 1 {
                description += "+"
            }
        }
        description += ",\(breedTime),"
        description += "\(breedPercentage),"
        description += "\(cloneSocialPercentage),"
        description += "\(cloneNormalPercentage),"
        description += "\(cloneRiftPercentage),"        
        return description + "\(quest)"
    }
}

extension Dragon : Equatable {
    static func ==(lhs: Dragon, rhs: Dragon) -> Bool {
        return lhs.name == rhs.name
          && lhs.limited == rhs.limited
          && lhs.rarity == rhs.rarity
          && lhs.elements == rhs.elements
          && lhs.breedRequirements == rhs.breedRequirements
          && lhs.breedTime == rhs.breedTime
          && lhs.breedPercentage == rhs.breedPercentage
          && lhs.cloneSocialPercentage == rhs.cloneSocialPercentage
          && lhs.cloneNormalPercentage == rhs.cloneNormalPercentage
          && lhs.cloneRiftPercentage == rhs.cloneRiftPercentage
          && lhs.quest == rhs.quest
    }       
}

extension Dragon : Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(limited)
        hasher.combine(rarity)
        hasher.combine(elements)
        hasher.combine(breedRequirements)
        hasher.combine(breedTime)
        hasher.combine(breedPercentage)
        hasher.combine(cloneSocialPercentage)
        hasher.combine(cloneNormalPercentage)
        hasher.combine(cloneRiftPercentage)
        hasher.combine(quest)
    }
}

extension Dragon : Comparable {
    static func <(lhs: Dragon, rhs: Dragon) -> Bool {
        return lhs.name < rhs.name
    }
}