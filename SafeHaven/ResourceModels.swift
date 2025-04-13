import Foundation
import SwiftUI
import CoreLocation

enum ResourceCategory: String, CaseIterable, Identifiable {
    case all = "All Resources"
    case shelter = "Shelter & Housing"
    case food = "Food & Meals"
    case healthcare = "Healthcare"
    case mentalHealth = "Mental Health"
    case substanceSupport = "Substance Support"
    case crisis = "Crisis Services"
    case legalAid = "Legal Aid"
    case immigration = "Immigration Help"
    case financial = "Financial Assistance"
    case employment = "Employment"
    case education = "Education"
    case transportation = "Transportation"
    case family = "Family Services"
    case veterans = "Veterans Services"
    case lgbtq = "LGBTQ+ Support"
    case youthServices = "Youth Services"
    case domesticViolence = "Domestic Violence"
    case communityCenter = "Community Centers"
    case seniorServices = "Senior Services"
    case disabilityServices = "Disability Services"
    case childcare = "Childcare"
    case utilities = "Utility Assistance"
    case clothing = "Clothing & Essentials"
    case internet = "Internet Access"
    case phoneServices = "Phone Services"
    case dental = "Dental Services"
    case vision = "Vision Services"
    case prescriptions = "Prescription Help"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .shelter: return "house.fill"
        case .food: return "fork.knife"
        case .healthcare: return "cross.fill"
        case .mentalHealth: return "brain.head.profile"
        case .substanceSupport: return "pills.fill"
        case .crisis: return "exclamationmark.triangle.fill"
        case .legalAid: return "building.columns.fill"
        case .immigration: return "globe"
        case .financial: return "dollarsign.circle.fill"
        case .employment: return "briefcase.fill"
        case .education: return "book.fill"
        case .transportation: return "bus.fill"
        case .family: return "figure.2.and.child.holdinghands"
        case .veterans: return "shield.fill"
        case .lgbtq: return "heart.fill"
        case .youthServices: return "figure.child"
        case .domesticViolence: return "house.lodge"
        case .communityCenter: return "person.3.fill"
        case .seniorServices: return "figure.walk.motion"
        case .disabilityServices: return "figure.roll"
        case .childcare: return "figure.and.child.holdinghands"
        case .utilities: return "bolt.fill"
        case .clothing: return "tshirt.fill"
        case .internet: return "wifi"
        case .phoneServices: return "phone.fill"
        case .dental: return "mouth.fill"
        case .vision: return "eye.fill"
        case .prescriptions: return "cross.case.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return Color(hex: "6A89CC")
        case .shelter: return Color(hex: "F9844A")
        case .food: return Color(hex: "4D908E")
        case .healthcare: return Color(hex: "F94144")
        case .mentalHealth: return Color(hex: "577590")
        case .substanceSupport: return Color(hex: "F8961E")
        case .crisis: return Color(hex: "E63946")
        case .legalAid: return Color(hex: "90BE6D")
        case .immigration: return Color(hex: "0096C7")
        case .financial: return Color(hex: "43AA8B")
        case .employment: return Color(hex: "277DA1")
        case .education: return Color(hex: "577590")
        case .transportation: return Color(hex: "277DA1")
        case .family: return Color(hex: "F3722C")
        case .veterans: return Color(hex: "1D3557")
        case .lgbtq: return Color(hex: "F37EF9")
        case .youthServices: return Color(hex: "FFC8DD")
        case .domesticViolence: return Color(hex: "D00000")
        case .communityCenter: return Color(hex: "7209B7")
        case .seniorServices: return Color(hex: "4361EE")
        case .disabilityServices: return Color(hex: "3A0CA3")
        case .childcare: return Color(hex: "F72585")
        case .utilities: return Color(hex: "FFD60A")
        case .clothing: return Color(hex: "FB8B24")
        case .internet: return Color(hex: "4CC9F0")
        case .phoneServices: return Color(hex: "480CA8")
        case .dental: return Color(hex: "FB5607")
        case .vision: return Color(hex: "3A86FF")
        case .prescriptions: return Color(hex: "FF006E")
        }
    }
    
    // Extensive search keywords for each category
    var searchKeywords: [String] {
        switch self {
        case .all:
            return ["help", "assistance", "resources", "support", "services", "aid", "community", "outreach", "social services", "nonprofit", "charity", "community resources"]
            
        case .shelter:
            return ["shelter", "homeless shelter", "emergency housing", "transitional housing",
                    "affordable housing", "rent help", "housing assistance", "eviction",
                    "women's shelter", "men's shelter", "temporary shelter", "homeless",
                    "place to stay", "housing crisis", "housing program", "rapid rehousing",
                    "low income housing", "section 8", "housing authority", "motel voucher",
                    "emergency shelter", "family shelter", "domestic violence shelter",
                    "housing subsidy", "rental assistance", "housing first", "housing support",
                    "housing stability", "permanent housing", "supportive housing"]
            
        case .food:
            return ["food bank", "food pantry", "free meals", "soup kitchen", "meal program",
                    "grocery assistance", "emergency food", "community meals", "food stamps",
                    "SNAP benefits", "WIC", "hunger", "feeding program", "free groceries",
                    "food assistance", "senior meals", "meals on wheels", "food distribution",
                    "backpack program", "summer meals", "ebt", "food resources", "food share",
                    "food co-op", "community garden", "gleaning", "holiday meals", "breakfast program",
                    "lunch program", "food delivery", "congregate meals", "food boxes", "community fridge"]
            
        case .healthcare:
            return ["free clinic", "community health", "medical care", "doctor", "health center",
                    "emergency medical", "dental care", "vision care", "prescription", "medication assistance",
                    "health insurance", "medicaid", "medicare", "community clinic", "federally qualified health center",
                    "sliding scale clinic", "urgent care", "telehealth", "virtual doctor", "mobile health clinic",
                    "health department", "family medicine", "pediatric care", "women's health", "men's health",
                    "preventive care", "primary care", "specialty care", "chronic disease management",
                    "immunizations", "vaccines", "screening", "healthcare for homeless", "rural health clinic"]
            
        case .mentalHealth:
            return ["mental health", "counseling", "therapy", "psychiatrist", "psychologist",
                    "depression", "anxiety", "trauma", "crisis counseling", "support group",
                    "mental illness", "behavioral health", "mental health services", "telemental health",
                    "online therapy", "virtual counseling", "grief support", "PTSD", "trauma-informed care",
                    "mental health screening", "suicide prevention", "bipolar", "schizophrenia",
                    "mood disorders", "cognitive behavioral therapy", "DBT", "psychiatric services",
                    "peer support", "mental wellness", "mental health resources", "mental health hotline",
                    "emotional support", "mental health assistance", "mental health program"]
            
        case .substanceSupport:
            return ["substance abuse", "addiction", "recovery", "detox", "rehab", "treatment center",
                    "alcoholics anonymous", "narcotics anonymous", "sober living", "drug counseling",
                    "alcohol treatment", "opioid treatment", "substance use disorder", "drug rehabilitation",
                    "recovery support", "harm reduction", "needle exchange", "MAT", "medication assisted treatment",
                    "recovery coach", "addiction counselor", "sobriety", "drug court", "alcohol detox",
                    "suboxone", "methadone", "naloxone", "recovery house", "sober house", "drug intervention",
                    "addiction medicine", "addiction resources", "recovery resources", "12 step program"]
            
        case .crisis:
            return ["crisis center", "suicide prevention", "crisis hotline", "emergency services",
                    "crisis intervention", "disaster relief", "emergency assistance", "crisis support",
                    "mobile crisis", "crisis team", "crisis counseling", "crisis stabilization",
                    "emergency mental health", "crisis line", "crisis text line", "crisis chat",
                    "crisis response", "emergency shelter", "crisis management", "disaster services",
                    "emergency preparedness", "disaster recovery", "emergency response", "crisis resources",
                    "trauma services", "emergency fund", "crisis hotline", "suicide hotline", "988", "211"]
            
        case .legalAid:
            return ["legal aid", "free legal", "legal assistance", "lawyer", "attorney", "legal rights",
                    "legal clinic", "public defender", "legal advocacy", "law help", "court help",
                    "legal services", "tenant rights", "consumer rights", "legal resources", "pro bono",
                    "legal consultation", "court assistance", "legal advice", "legal representation",
                    "eviction prevention", "landlord tenant", "family law", "protective order",
                    "restraining order", "divorce assistance", "child custody", "legal documents",
                    "expungement", "civil legal aid", "immigration legal", "benefits advocacy", "legal hotline"]
            
        case .immigration:
            return ["immigration services", "immigrant rights", "refugee", "asylum", "immigration lawyer",
                    "deportation", "DACA", "citizenship", "green card", "visa help", "immigration legal",
                    "undocumented", "migrant", "immigrant resource center", "immigration advocacy",
                    "immigration assistance", "naturalization", "TPS", "temporary protected status",
                    "immigration forms", "immigration application", "immigration status", "ICE",
                    "USCIS", "border issues", "detention", "immigration bond", "immigration court",
                    "newcomer services", "refugee resettlement", "immigrant community", "language services",
                    "cultural orientation", "ESL", "citizenship classes", "immigration clinic"]
            
        case .financial:
            return ["financial assistance", "emergency cash", "bill pay assistance", "utility assistance",
                    "rent assistance", "financial counseling", "debt help", "tax help", "benefits",
                    "financial aid", "low income", "welfare", "financial support", "TANF", "temporary assistance",
                    "financial literacy", "money management", "credit counseling", "budget help",
                    "financial coaching", "financial education", "financial empowerment", "asset building",
                    "matched savings", "IDA", "VITA", "free tax preparation", "earned income tax credit",
                    "financial crisis", "emergency financial", "economic support", "economic assistance",
                    "financial stability", "financial wellness", "basic needs assistance"]
            
        case .employment:
            return ["job training", "employment center", "job search", "career counseling", "resume help",
                    "vocational training", "workforce development", "job placement", "unemployment",
                    "work program", "job skills", "job fair", "career center", "employment services",
                    "job readiness", "job coaching", "apprenticeship", "workforce program", "career pathways",
                    "on the job training", "supported employment", "job development", "career exploration",
                    "interview skills", "job club", "workforce solutions", "employment assistance",
                    "career advancement", "professional development", "job supports", "employment resources",
                    "reentry employment", "second chance hiring", "career assessment", "labor exchange"]
            
        case .education:
            return ["adult education", "GED program", "literacy program", "ESL class", "educational assistance",
                    "school supplies", "tutoring", "college access", "financial aid", "scholarship",
                    "education resources", "computer training", "adult learning", "high school equivalency",
                    "HSE", "ABE", "adult basic education", "continuing education", "college preparation",
                    "college readiness", "college access", "educational support", "student success",
                    "academic support", "academic counseling", "educational advocacy", "digital literacy",
                    "alternative education", "special education", "education rights", "learning differences",
                    "college opportunity", "educational equity", "vocational education"]
            
        case .transportation:
            return ["transportation assistance", "bus pass", "reduced fare", "ride service", "medical transport",
                    "free transportation", "car repair", "gas voucher", "transit", "ride share", "commuter assistance",
                    "paratransit", "non-emergency medical transportation", "NEMT", "volunteer driver", "senior transportation",
                    "disabled transportation", "transportation voucher", "transportation subsidy", "carpool",
                    "vehicle donation", "vehicle repair program", "transportation barrier", "transit assistance",
                    "mobility management", "mobility services", "accessible transportation", "car ownership program",
                    "transportation coordination", "travel training", "mileage reimbursement", "car seats", "bike program"]
            
        case .family:
            return ["family support", "childcare", "parenting classes", "family counseling", "child support",
                    "family resources", "after school", "family assistance", "children services",
                    "family crisis", "parent help", "home visiting", "parent education", "early childhood",
                    "family preservation", "family stabilization", "family strengthening", "family engagement",
                    "family navigation", "family advocacy", "child welfare", "kinship care", "grandparents raising grandchildren",
                    "family resource center", "family success center", "parent support group", "family therapy",
                    "fatherhood program", "child development", "family case management", "family coaching",
                    "respite care", "family activities", "parenting support", "family reunification"]
            
        case .veterans:
            return ["veteran services", "VA", "veteran benefits", "veteran housing", "veteran healthcare",
                    "veteran employment", "military", "veteran assistance", "veteran support",
                    "VA hospital", "veteran counseling", "veteran mental health", "veteran homelessness",
                    "veteran housing", "SSVF", "veteran peer support", "service officer", "veteran claims",
                    "veteran compensation", "disability claims", "veteran pension", "veteran burial",
                    "veteran education", "GI Bill", "veteran job training", "veteran transition",
                    "veteran outreach", "veteran resources", "combat veteran", "wounded warrior",
                    "veteran stand down", "veteran legal", "veteran benefits assistance", "veteran affairs"]
            
        case .lgbtq:
            return ["LGBTQ", "LGBTQ+ support", "gay", "lesbian", "transgender", "queer", "LGBTQ health",
                    "LGBTQ youth", "LGBTQ housing", "LGBTQ counseling", "LGBTQ center", "LGBTQ resources",
                    "LGBT", "LGBTQIA", "LGBT friendly", "transgender services", "LGBTQ advocacy",
                    "LGBTQ support group", "LGBTQ community center", "LGBTQ shelter", "LGBTQ healthcare",
                    "LGBTQ mental health", "LGBTQ crisis", "LGBTQ peer support", "trans health",
                    "gender affirming", "gender identity", "sexual orientation", "LGBTQ outreach",
                    "LGBTQ youth services", "LGBTQ senior services", "LGBTQ family", "LGBTQ legal",
                    "LGBTQ domestic violence", "LGBTQ inclusive", "LGBTQ housing"]
            
        case .youthServices:
            return ["youth services", "teen center", "youth shelter", "youth program", "children services",
                    "youth counseling", "after school program", "juvenile", "teen support",
                    "foster youth", "runaway", "youth outreach", "youth development", "teen program",
                    "youth mentoring", "youth leadership", "youth empowerment", "summer program",
                    "youth recreation", "youth activities", "youth support group", "adolescent services",
                    "transition age youth", "TAY", "independent living", "youth housing", "youth employment",
                    "youth education", "youth opportunity", "youth enrichment", "youth arts", "youth sports",
                    "youth prevention", "youth violence prevention", "youth crisis", "youth resource center"]
            
        case .domesticViolence:
            return ["domestic violence", "abuse shelter", "women's shelter", "abuse hotline", "safety planning",
                    "protective order", "family violence", "intimate partner violence", "abuse support",
                    "safe house", "victim services", "battering", "relationship violence", "sexual assault",
                    "sexual violence", "violence prevention", "victim advocacy", "victim rights",
                    "victim compensation", "legal advocacy", "court advocacy", "trauma support",
                    "abuse recovery", "violence intervention", "violence prevention", "crisis intervention",
                    "emergency shelter", "trauma-informed", "survivor services", "survivor support",
                    "safety planning", "shelter services", "dv shelter", "violence survivor", "abuse prevention"]
            
        case .communityCenter:
            return ["community center", "neighborhood center", "recreation center", "civic center",
                    "community hub", "community space", "cultural center", "service center",
                    "multipurpose center", "community gathering", "community resource center",
                    "community outreach", "community support", "community services", "community assistance",
                    "community programs", "local center", "resource hub", "activity center",
                    "neighborhood house", "settlement house", "community building", "community engagement",
                    "community development", "community organization", "community activities", "community events"]
            
        case .seniorServices:
            return ["senior services", "elder services", "older adult", "aging services", "senior center",
                    "elder care", "geriatric", "retired", "senior assistance", "senior support",
                    "aging in place", "senior housing", "senior meals", "senior activities",
                    "senior health", "senior transportation", "medicare help", "senior benefits",
                    "elder abuse prevention", "caregiver support", "fall prevention", "senior nutrition",
                    "adult day services", "senior companion", "friendly visitor", "senior recreation",
                    "senior social", "senior wellness", "elderly services", "senior outreach", "senior resources"]
            
        case .disabilityServices:
            return ["disability services", "disability support", "disability resources", "ADA", "accessible",
                    "adaptive", "developmental disability", "intellectual disability", "physical disability",
                    "cognitive disability", "disability rights", "disability advocacy", "disability benefits",
                    "disability housing", "disability employment", "supported employment", "supported living",
                    "independent living", "accessibility", "assistive technology", "adaptive equipment",
                    "personal assistance", "disability transportation", "disability education", "special needs",
                    "disability healthcare", "disability accommodations", "inclusion", "disability community",
                    "disability recreation", "disability assistance", "disability navigation", "disability options"]
            
        case .childcare:
            return ["childcare", "daycare", "child care", "early childhood", "preschool", "babysitting",
                    "after school care", "childcare assistance", "childcare subsidy", "head start",
                    "early head start", "child development", "early learning", "childcare center",
                    "family childcare", "in-home childcare", "childcare voucher", "childcare financial assistance",
                    "affordable childcare", "quality childcare", "licensed childcare", "childcare options",
                    "childcare resources", "childcare referral", "emergency childcare", "drop-in childcare",
                    "respite care", "childcare provider", "childcare program", "childcare support", "CCDF"]
            
        case .utilities:
            return ["utility assistance", "energy assistance", "water assistance", "electric bill",
                    "gas bill", "heating assistance", "cooling assistance", "LIHEAP", "utility bill help",
                    "utility payment", "energy bill", "utility discount", "weatherization",
                    "energy efficiency", "utility shutoff", "disconnect prevention", "reconnection assistance",
                    "water bill", "utility company programs", "conservation program", "utility voucher",
                    "energy crisis", "utility arrearage", "power bill", "winter heating", "summer cooling",
                    "budget billing", "utility payment plan", "utility financial assistance"]
            
        case .clothing:
            return ["clothing", "clothes", "donation", "thrift store", "free clothes", "clothing bank",
                    "clothing closet", "professional attire", "work clothes", "school clothes",
                    "winter coats", "shoes", "uniforms", "clothing assistance", "clothing voucher",
                    "clothing resources", "clothing program", "clothing drive", "clothing distribution",
                    "free clothing", "donated clothing", "emergency clothing", "clothing pantry",
                    "uniform assistance", "back to school clothes", "winter clothing", "basic needs",
                    "essential items", "hygiene supplies", "personal care items", "household goods"]
            
        case .internet:
            return ["internet", "broadband", "wifi", "hotspot", "digital", "computer", "technology",
                    "internet access", "free wifi", "low-cost internet", "digital inclusion",
                    "digital equity", "computer center", "tech hub", "digital literacy", "computer training",
                    "affordable internet", "internet subsidy", "internet discount program", "EBB",
                    "emergency broadband benefit", "Affordable Connectivity Program", "ACP", "Lifeline",
                    "internet benefit", "free computer", "technology access", "public wifi", "community wifi",
                    "internet resources", "digital resources", "internet navigation", "tech support"]
            
        case .phoneServices:
            return ["phone", "telephone", "cell phone", "wireless", "free phone", "lifeline phone",
                    "government phone", "phone assistance", "phone service", "discounted phone",
                    "emergency phone", "phone program", "wireless assistance", "phone subsidy",
                    "cell phone program", "free cell phone", "low income phone", "basic phone",
                    "phone service assistance", "phone bill help", "communication assistance",
                    "free minutes", "free texts", "phone access", "mobile phone", "prepaid phone",
                    "phone resources", "telecommunications", "phone benefit", "phone allowance"]
            
        case .dental:
            return ["dental", "dentist", "teeth", "oral health", "dental clinic", "free dental",
                    "dental care", "dental services", "dental assistance", "dental exam",
                    "dental cleaning", "dental procedure", "dental emergency", "dental screening",
                    "dental hygiene", "dental extraction", "dental surgery", "dental pain",
                    "dental treatment", "dental discount", "dental program", "dentures",
                    "dental resources", "dental referral", "dental education", "dental prevention",
                    "mobile dental", "dental van", "dental outreach", "child dental", "senior dental"]
            
        case .vision:
            return ["vision", "eye", "glasses", "contacts", "eye exam", "vision care", "optometrist",
                    "eye doctor", "eyeglasses", "vision services", "vision assistance", "eye health",
                    "vision exam", "vision screening", "free glasses", "low-cost glasses",
                    "vision program", "vision resources", "eye care", "visual health", "eye test",
                    "corrective lenses", "vision correction", "vision voucher", "vision assistance program",
                    "optical services", "vision referral", "vision discount", "vision benefit",
                    "vision outreach", "vision support", "eye health", "children's vision", "senior vision"]
            
        case .prescriptions:
            return ["prescription", "medication", "medicine", "pharmacy", "prescription assistance",
                    "medication help", "prescription drug", "medication cost", "prescription coverage",
                    "free medication", "low-cost medication", "discount prescription", "drug discount",
                    "prescription program", "medication assistance program", "PAP", "pharmaceutical assistance",
                    "prescription resources", "medication management", "prescription card",
                    "medication subsidy", "pharmacy discount", "medication voucher", "prescription savings",
                    "medication benefit", "drug benefit", "copay assistance", "medicine costs",
                    "prescription access", "prescription navigation", "medication support"]
        }
    }
}

struct ResourceLocation: Identifiable, Hashable {
    let id: String
    let name: String
    let category: ResourceCategory
    let address: String
    let phoneNumber: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let icon: String
    let website: String?
    let hours: String?
    let services: [String]
    
    // For SwiftUI sheet presentation and Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ResourceLocation, rhs: ResourceLocation) -> Bool {
        lhs.id == rhs.id
    }
    
    // Add Equatable conformance for CLLocationCoordinate2D
    private func coordinatesEqual(_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// MARK: - Custom Views for Resource Display

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color : color.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : color)
        }
    }
}

// Helper function to determine category based on search terms or place attributes
func determineCategoryFromSearch(_ query: String, placeName: String) -> ResourceCategory {
    let lowercaseQuery = query.lowercased()
    let lowercaseName = placeName.lowercased()
    
    // Check each category's keywords for matches
    for category in ResourceCategory.allCases where category != .all {
        for keyword in category.searchKeywords.prefix(10) {
            if lowercaseQuery.contains(keyword) || lowercaseName.contains(keyword) {
                return category
            }
        }
    }
    
    // Default to all if no matches
    return .all
}
