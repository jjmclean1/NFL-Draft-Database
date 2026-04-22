import SwiftUI
import WebKit

private let draftAvg: [String: Double] = [
    "Receptions":  52,
    "Yards":       820,
    "TDs":         7,
    "Yards/RR":    1.85,
    "ADOT":        12.1,
    "Catch Rate":  61.0,
    "Drop %":      6.0,
    "YAC/R":       4.1,
    "Target Rate": 18.0,
]

private let invertedStats: Set<String> = ["Drop %"]

struct StatDef: Identifiable, Hashable {
    let id = UUID()
    let key: String
    let label: String
    let format: (Double) -> String

    static func == (lhs: StatDef, rhs: StatDef) -> Bool { lhs.key == rhs.key }
    func hash(into hasher: inout Hasher) { hasher.combine(key) }
}

private let allStatDefs: [StatDef] = [
    StatDef(key: "Receptions",  label: "REC",   format: { String(Int($0)) }),
    StatDef(key: "Yards",       label: "YDS",   format: { String(Int($0)) }),
    StatDef(key: "TDs",         label: "TD",    format: { String(Int($0)) }),
    StatDef(key: "Yards/RR",    label: "YPRR",  format: { String(format: "%.2f", $0) }),
    StatDef(key: "ADOT",        label: "ADOT",  format: { String(format: "%.1f", $0) }),
    StatDef(key: "Catch Rate",  label: "CTH%",  format: { String(format: "%.1f%%", $0) }),
    StatDef(key: "Drop %",      label: "DRP%",  format: { String(format: "%.1f%%", $0) }),
    StatDef(key: "YAC/R",       label: "YAC/R", format: { String(format: "%.1f", $0) }),
    StatDef(key: "Target Rate", label: "TGT%",  format: { String(format: "%.1f%%", $0) }),
]

private func heatRatio(key: String, value: Double) -> Double {
    guard let avg = draftAvg[key], avg != 0 else { return 0 }
    let raw = (value - avg) / avg
    return invertedStats.contains(key) ? -raw : raw
}

private func heatColors(ratio: Double) -> (bg: Color, text: Color, sub: Color) {
    let c = max(-1.0, min(1.0, ratio))
    let dead = 0.08

    if abs(c) < dead {
        let intensity = 1.0 - (abs(c) / dead)
        return (
            bg:   Color(red: 0.72, green: 0.62, blue: 0.10).opacity(0.10 + intensity * 0.08),
            text: Color(red: 0.90, green: 0.80, blue: 0.35),
            sub:  Color(red: 0.72, green: 0.62, blue: 0.22).opacity(0.75)
        )
    } else if c > 0 {
        let t = min(c / 0.6, 1.0)
        return (
            bg:   Color(red: 0.06, green: 0.55 + t * 0.25, blue: 0.20).opacity(0.13 + t * 0.10),
            text: Color(red: 0.20, green: 0.78 + t * 0.10, blue: 0.38),
            sub:  Color(red: 0.14, green: 0.58 + t * 0.10, blue: 0.28).opacity(0.75)
        )
    } else {
        let t = min(-c / 0.6, 1.0)
        return (
            bg:   Color(red: 0.65 + t * 0.18, green: 0.20 - t * 0.10, blue: 0.18).opacity(0.13 + t * 0.10),
            text: Color(red: 0.90 + t * 0.06, green: 0.28 - t * 0.06, blue: 0.24),
            sub:  Color(red: 0.72 + t * 0.06, green: 0.20 - t * 0.04, blue: 0.18).opacity(0.75)
        )
    }
}

private func pctLabel(_ ratio: Double) -> String {
    let p = Int(ratio * 100)
    return p >= 0 ? "+\(p)%" : "\(p)%"
}

struct PlayerProfileView: View {
    let prospect: Prospect
    let bgDark = Color(red: 0.03, green: 0.05, blue: 0.08)

    var teamPrimary: Color   { Color(hex: prospect.primaryColorHex) }
    var teamSecondary: Color { Color(hex: prospect.secondaryColorHex) }

    @State private var selectedMenu = "COMPS"
    let menuItems = ["STATS", "TESTING", "FILM", "COMPS", "REPORTS"]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomTrailing) {
                    LinearGradient(
                        colors: [teamPrimary, bgDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    AsyncImage(url: URL(string: prospect.teamLogoURL)) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFit().opacity(0.15).offset(x: 50, y: 0)
                        }
                    }
                    .frame(height: 280).clipped()

                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.top, 16).padding(.bottom, 24)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(prospect.firstName)
                                .font(.custom("MicrogrammaD-BoldExte", size: 28)).foregroundColor(.white)
                            Text(prospect.lastName)
                                .font(.custom("MicrogrammaD-BoldExte", size: 40)).foregroundColor(.white).padding(.bottom, 8)

                            HStack(spacing: 8) {
                                Text(prospect.position)
                                    .font(.custom("MicrogrammaD-BoldExte", size: 9)).foregroundColor(.white)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Color.white.opacity(0.2)).cornerRadius(4)
                                Text("#\(prospect.number)").font(.custom("MicrogrammaD-BoldExte", size: 14)).foregroundColor(.white)
                                Text("|").foregroundColor(.white.opacity(0.5))
                                AsyncImage(url: URL(string: prospect.teamLogoURL)) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: { ProgressView() }
                                .frame(width: 20, height: 20)
                                Text(prospect.teamName)
                                    .font(.custom("MicrogrammaD-BoldExte", size: 14)).foregroundColor(.white)
                                    .lineLimit(10).minimumScaleFactor(0.8)
                            }
                            .padding(.bottom, 8)

                            Text("\(prospect.height) • \(prospect.weight) • \(prospect.age)y/o")
                                .font(.custom("MicrogrammaD-BoldExte", size: 12)).foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.bottom, 24).padding(.trailing, 160)
                    }
                    .padding(.horizontal, 20).frame(maxWidth: .infinity, alignment: .leading)

                    AsyncImage(url: URL(string: prospect.headshotURL)) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFit().frame(width: 170)
                        } else if phase.error != nil {
                            Image(systemName: "person.crop.rectangle.fill")
                                .resizable().scaledToFit().frame(width: 170).foregroundColor(.white.opacity(0.3))
                        } else {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 170, height: 170)
                        }
                    }
                    .offset(x: -10, y: 0)
                }
                .clipShape(Rectangle())

                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(menuItems, id: \.self) { item in
                                Button(action: { selectedMenu = item }) {
                                    VStack(spacing: 8) {
                                        Text(item)
                                            .font(.custom("MicrogrammaD-BoldExte", size: 11))
                                            .foregroundColor(selectedMenu == item ? .white : .gray)
                                        Rectangle()
                                            .fill(selectedMenu == item ? teamSecondary : Color.clear)
                                            .frame(height: 3)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20).padding(.top, 16)
                    }
                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                }
                .background(bgDark)

                if selectedMenu == "STATS" {
                    VStack(spacing: 24) {
                        Text(prospect.bio)
                            .font(.system(size: 13, design: .monospaced)).foregroundColor(.gray)
                            .multilineTextAlignment(.leading).lineSpacing(4)
                            .padding(.horizontal, 20).padding(.top, 20)

                        HStack(alignment: .top, spacing: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "bolt.fill").foregroundColor(teamSecondary)
                                    Text("OFFENSIVE").font(.custom("MicrogrammaD-BoldExte", size: 10)).foregroundColor(teamSecondary)
                                }
                                .padding(.bottom, 4)
                                StatRow(label: "ADJ_IMPACT", score: prospect.adjImpact, color: teamSecondary)
                                StatRow(label: "YAC_ABILITY", score: prospect.yacAbility, color: teamSecondary)
                                StatRow(label: "SEPARATION",  score: prospect.separation, color: teamSecondary)
                                StatRow(label: "HANDS",       score: 92, color: teamSecondary)
                                StatRow(label: "CONTESTED",   score: 85, color: teamSecondary)
                            }
                            .padding().border(Color.white.opacity(0.1))

                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "shield.fill").foregroundColor(.gray)
                                    Text("PHYSICALITY").font(.custom("MicrogrammaD-BoldExte", size: 10)).foregroundColor(.gray)
                                }
                                .padding(.bottom, 4)
                                StatRow(label: "RUN_BLOCK", score: prospect.runBlock, color: .gray)
                                StatRow(label: "PRESS_REL", score: prospect.pressRel, color: .gray)
                                StatRow(label: "STRENGTH",  score: 71, color: .gray)
                                StatRow(label: "HEIGHT",    score: 60, color: .gray)
                                StatRow(label: "WEIGHT",    score: 45, color: .gray)
                            }
                            .padding().border(Color.white.opacity(0.1))
                        }
                        .padding(.horizontal)

                        Divider().background(Color.white.opacity(0.1)).padding(.vertical, 8)
                        AdvancedMetricsTable(prospect: prospect, teamSecondary: teamSecondary)

                        if let logs = prospect.gameLogs {
                            GameLogTable(logs: logs).padding(.top, 16)
                        }
                        if let seasons = prospect.seasonStats {
                            CareerSeasonTable(stats: seasons, teamSecondary: teamSecondary).padding(.top, 24)
                        }

                        Spacer().frame(height: 40)
                    }
                    .background(bgDark)

                } else if selectedMenu == "TESTING" {
                    AthleticTestingTable(prospect: prospect, teamSecondary: teamSecondary)
                        .padding(.top, 24).padding(.bottom, 40)

                } else if selectedMenu == "FILM" {
                    FilmView(prospect: prospect)
                        .padding(.top, 10).background(bgDark)

                } else if selectedMenu == "COMPS" {
                    StatMatrixView(prospect: prospect)
                        .padding(.top, 16).padding(.bottom, 40)

                } else {
                    VStack {
                        Spacer().frame(height: 50)
                        Text("// MODULE_UNDER_CONSTRUCTION")
                            .font(.system(.caption, design: .monospaced)).foregroundColor(.gray)
                        Spacer().frame(height: 200)
                    }
                    .frame(maxWidth: .infinity).background(bgDark)
                }
            }
        }
        .background(bgDark.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.dark)
        .navigationBarHidden(true)
    }
}

struct StatMatrixView: View {
    let prospect: Prospect

    let bgDark    = Color(red: 0.02, green: 0.05, blue: 0.08)
    let headerBg  = Color(red: 0.03, green: 0.07, blue: 0.10)
    let border    = Color.white.opacity(0.06)
    let nameColW: CGFloat = 130
    let cellW: CGFloat    = 58
    let cellH: CGFloat    = 46

    var teamSecondary: Color { Color(hex: prospect.secondaryColorHex) }

    @State private var activeStats: Set<String>   = ["Receptions", "Yards", "TDs", "Yards/RR", "Catch Rate", "Drop %"]
    @State private var activeComps: Set<String>   = []
    @State private var showSearch = false
    @State private var searchQuery = ""

    var availableComps: [String] {
        (prospect.comparisonData?.keys).map { Array($0).sorted() } ?? []
    }

    var visibleStats: [StatDef] {
        allStatDefs.filter { activeStats.contains($0.key) }
    }

    var visibleComps: [(name: String, data: [String: Double])] {
        guard let cd = prospect.comparisonData else { return [] }
        return availableComps
            .filter { activeComps.contains($0) }
            .compactMap { name in cd[name].map { (name: name, data: $0) } }
    }

    var filteredSearchResults: [String] {
        searchQuery.isEmpty
            ? availableComps.filter { !activeComps.contains($0) }
            : availableComps.filter { !activeComps.contains($0) && $0.localizedCaseInsensitiveContains(searchQuery) }
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbarSection(label: "STATS") {
                ForEach(allStatDefs) { stat in
                    pillButton(
                        label: stat.label,
                        isOn: activeStats.contains(stat.key),
                        accent: teamSecondary
                    ) {
                        if activeStats.contains(stat.key) {
                            if activeStats.count > 1 { activeStats.remove(stat.key) }
                        } else {
                            activeStats.insert(stat.key)
                        }
                    }
                }
            }

            ZStack(alignment: .topLeading) {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Color.clear.frame(width: nameColW, height: 30)
                            ForEach(visibleStats) { stat in
                                Text(stat.label)
                                    .font(.custom("MicrogrammaD-BoldExte", size: 12))
                                    .foregroundColor(Color.white.opacity(0.25))
                                    .frame(width: cellW, height: 30)
                            }
                        }
                        .background(headerBg)

                        Divider().background(border)

                        matrixRow(
                            name: "\(prospect.firstName) \(prospect.lastName)".uppercased(),
                            sub: "\(prospect.position) · \(prospect.teamName.uppercased())",
                            isSubject: true,
                            data: nil
                        )

                        Divider().background(border)

                        ForEach(visibleComps, id: \.name) { comp in
                            matrixRow(
                                name: comp.name.uppercased(),
                                sub: "",
                                isSubject: false,
                                data: comp.data
                            )
                            Divider().background(border)
                        }
                        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { showSearch = true } }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus").font(.system(size: 10))
                                Text("ADD COMP")
                                    .font(.custom("MicrogrammaD-BoldExte", size: 10))
                            }
                            .foregroundColor(teamSecondary.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, nameColW + 12)
                            .frame(height: cellH)
                        }
                    }
                }

                VStack(spacing: 0) {
                    Color(red: 0.03, green: 0.07, blue: 0.10)
                        .frame(width: nameColW, height: 31)

                    frozenNameCell(
                        name: "\(prospect.firstName) \(prospect.lastName)".uppercased(),
                        sub: "\(prospect.position) · \(prospect.teamName.uppercased())",
                        isSubject: true
                    )
                    .frame(height: cellH)
                    .overlay(Rectangle().frame(height: 0.5).foregroundColor(teamSecondary.opacity(0.4)), alignment: .top)

                    Divider().background(border).frame(width: nameColW)

                    ForEach(visibleComps, id: \.name) { comp in
                        frozenNameCell(name: comp.name.uppercased(), sub: "", isSubject: false)
                            .frame(height: cellH)
                        Divider().background(border).frame(width: nameColW)
                    }

                    Color(red: 0.02, green: 0.05, blue: 0.08)
                        .frame(width: nameColW, height: cellH)
                }
            }
            .background(bgDark)

            if showSearch {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: { withAnimation { showSearch = false; searchQuery = "" } }) {
                            Image(systemName: "xmark").foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    .background(Color.black.opacity(0.4))

                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray).font(.system(size: 13))
                        TextField("Search...", text: $searchQuery)
                            .font(.custom("MicrogrammaD-BoldExte", size: 11))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color.white.opacity(0.05))

                    ForEach(filteredSearchResults, id: \.self) { name in
                        Button(action: {
                            activeComps.insert(name)
                            withAnimation { showSearch = false; searchQuery = "" }
                        }) {
                            HStack {
                                Text(name)
                                    .font(.custom("MicrogrammaD-BoldExte", size: 12))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "plus.circle").foregroundColor(teamSecondary)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 11)
                        }
                        Divider().background(border)
                    }

                    if filteredSearchResults.isEmpty {
                        Text(searchQuery.isEmpty ? "All comps added" : "No results")
                            .font(.custom("MicrogrammaD-BoldExte", size: 11))
                            .foregroundColor(.gray)
                            .padding(20)
                    }
                }
                .background(Color(red: 0.03, green: 0.08, blue: 0.12))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(teamSecondary.opacity(0.25), lineWidth: 0.5))
                .padding(.horizontal, 16).padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(bgDark)
        .onAppear {
            if activeComps.isEmpty, let comps = prospect.comparisonData {
                activeComps = Set(Array(comps.keys.sorted().prefix(3)))
            }
        }
    }

    @ViewBuilder
    private func matrixRow(name: String, sub: String, isSubject: Bool, data: [String: Double]?) -> some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: nameColW, height: cellH)
            ForEach(visibleStats) { stat in
                let val: Double? = isSubject ? prospect.value(for: stat.key) : data?[stat.key]
                if let v = val {
                    MatrixDataCell(stat: stat, value: v, cellW: cellW, cellH: cellH)
                } else {
                    Color.clear.frame(width: cellW, height: cellH)
                }
            }
        }
        .background(isSubject ? Color.white.opacity(0.015) : Color.clear)
    }

    @ViewBuilder
    private func frozenNameCell(name: String, sub: String, isSubject: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.custom("MicrogrammaD-BoldExte", size: 10))
                .foregroundColor(isSubject ? teamSecondary : Color(white: 0.70))
                .lineLimit(1)
                .truncationMode(.tail)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            if !sub.isEmpty {
                Text(sub)
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(Color(white: 0.30))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.leading, 12)
        .padding(.trailing, 8)
        .frame(width: nameColW, height: cellH, alignment: .leading)
        .background(bgDark)
        .clipped()
    }

    @ViewBuilder
    private func toolbarSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("// \(label)")
                .font(.custom("MicrogrammaD-BoldExte", size: 14))
                .foregroundColor(Color(white: 0.22))
                .padding(.horizontal, 12).padding(.top, 10).padding(.bottom, 6)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) { content() }
                    .padding(.horizontal, 12).padding(.bottom, 18)
            }
        }
        .background(headerBg)
    }

    @ViewBuilder
    private func pillButton(label: String, isOn: Bool, accent: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.custom("MicrogrammaD-BoldExte", size: 9))
                .padding(.horizontal, 9).padding(.vertical, 5)
                .foregroundColor(isOn ? accent : Color(white: 0.28))
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(isOn ? accent.opacity(0.12) : Color.white.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(isOn ? accent.opacity(0.45) : Color.white.opacity(0.07), lineWidth: 0.5)
                )
        }
    }
}

struct MatrixDataCell: View {
    let stat: StatDef
    let value: Double
    let cellW: CGFloat
    let cellH: CGFloat

    private var ratio: Double { heatRatio(key: stat.key, value: value) }

    var body: some View {
        let c = heatColors(ratio: ratio)
        VStack(spacing: 3) {
            Text(stat.format(value))
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(c.text)
        }
        .frame(width: cellW, height: cellH)
        .background(c.bg)
    }
}

struct AdvancedMetricsTable: View {
    let prospect: Prospect
    let teamSecondary: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("ADVANCED METRICS")
                        .font(.custom("MicrogrammaD-BoldExte", size: 16))
                        .foregroundColor(teamSecondary)
                    Spacer()
                    Image(systemName: "questionmark.circle").foregroundColor(.gray)
                }
            }

            VStack(spacing: 12) {
                HStack {
                    Text("USAGE & ALIGNMENT")
                        .font(.custom("MicrogrammaD-BoldExte", size: 12)).foregroundColor(teamSecondary)
                    Spacer()
                }
                Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                HStack(spacing: 0) {
                    MetricColumn(title: "TGT%",  value: formatPercent(prospect.targetShare),        subValue: "99", subColor: .cyan, width: 60, alignment: .leading)
                    MetricColumn(title: "ADOT",  value: String(format: "%.1f", prospect.ADOT),      subValue: "88", subColor: .cyan, width: 50)
                    MetricColumn(title: "SLOT%", value: formatPercent(prospect.slotRate),           subValue: "45", subColor: .gray, width: 60)
                    MetricColumn(title: "WIDE%", value: formatPercent(prospect.wideRate),           subValue: "92", subColor: .cyan, width: 60)
                    MetricColumn(title: "CTGT%", value: formatPercent(prospect.contestedTargetRate), subValue: "78", subColor: .cyan, width: 60)
                }
            }

            VStack(spacing: 12) {
                HStack {
                    Text("RECEIVING EFFICIENCY")
                        .font(.custom("MicrogrammaD-BoldExte", size: 12)).foregroundColor(teamSecondary)
                    Spacer()
                }
                Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                HStack(spacing: 0) {
                    MetricColumn(title: "YPRR",   value: String(format: "%.2f", prospect.yardsPerRouteRun),          subValue: "96", subColor: .cyan, width: 50, alignment: .leading)
                    MetricColumn(title: "YPT",    value: String(format: "%.1f", prospect.yardsPerTarget),            subValue: "91", subColor: .cyan, width: 45)
                    MetricColumn(title: "CATCH%", value: formatPercent(prospect.catchRate),                          subValue: "85", subColor: .cyan, width: 65)
                    MetricColumn(title: "CTST%",  value: formatPercent(prospect.contestedCatchRate),                 subValue: "94", subColor: .cyan, width: 60)
                    MetricColumn(title: "DROP%",  value: formatPercent(prospect.dropRate),                           subValue: "99", subColor: .cyan, width: 55)
                    MetricColumn(title: "YAC/R",  value: String(format: "%.1f", prospect.yardsAfterCatchperReception), subValue: "89", subColor: .cyan, width: 50)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    func formatPercent(_ decimal: Double) -> String { String(format: "%.1f%%", decimal * 100) }
}

struct AthleticTestingTable: View {
    let prospect: Prospect
    let teamSecondary: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("ATHLETIC PROFILE")
                        .font(.custom("MicrogrammaD-BoldExte", size: 16)).foregroundColor(teamSecondary)
                    Spacer()
                }
                Text("Combine & Pro Day measurables.")
                    .font(.system(size: 11, design: .monospaced)).foregroundColor(.gray)
            }

            VStack(spacing: 12) {
                HStack {
                    Text("MEASURABLES")
                        .font(.custom("MicrogrammaD-BoldExte", size: 12)).foregroundColor(teamSecondary)
                    Spacer()
                }
                Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                HStack(spacing: 0) {
                    MetricColumn(title: "HEIGHT", value: prospect.height, subValue: "-", width: 60, alignment: .leading)
                    MetricColumn(title: "WEIGHT", value: prospect.weight, subValue: "-", width: 70)
                    MetricColumn(title: "HANDS",  value: prospect.handSize, subValue: "-", width: 60)
                    Spacer()
                }
            }

            VStack(spacing: 12) {
                HStack {
                    Text("TESTING")
                        .font(.custom("MicrogrammaD-BoldExte", size: 12)).foregroundColor(teamSecondary)
                    Spacer()
                }
                Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                HStack(spacing: 0) {
                    MetricColumn(title: "40-YD",   value: prospect.fortyYardDash,        subValue: prospect.fortyYardDash == "N/A"        ? "-" : "82", subColor: .cyan, width: 50, alignment: .leading)
                    MetricColumn(title: "VERT",    value: prospect.verticalJump,          subValue: prospect.verticalJump == "N/A"          ? "-" : "75", subColor: .cyan, width: 50)
                    MetricColumn(title: "BROAD",   value: prospect.broadJump,             subValue: "-", width: 55)
                    MetricColumn(title: "3-CONE",  value: prospect.threeCone,             subValue: prospect.threeCone == "N/A"             ? "-" : "91", subColor: .cyan, width: 65)
                    MetricColumn(title: "SHUTTLE", value: prospect.twentyYardShuttle,     subValue: prospect.twentyYardShuttle == "N/A"     ? "-" : "88", subColor: .cyan, width: 65)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct MetricColumn: View {
    var title: String
    var value: String
    var subValue: String
    var subColor: Color = .gray
    var width: CGFloat
    var alignment: HorizontalAlignment = .center

    var body: some View {
        VStack(alignment: alignment, spacing: 6) {
            Text(title).font(.system(size: 10, design: .monospaced)).foregroundColor(.gray)
            Text(value).font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundColor(.white)
            Text(subValue).font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(subColor)
        }
        .frame(width: width, alignment: alignment == .leading ? .leading : .center)
    }
}

struct GameLogTable: View {
    let logs: [GameLog]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("GAME LOG").font(.custom("MicrogrammaD-BoldExte", size: 10)).foregroundColor(.white)
                Text("[2026] Regular Season").font(.system(size: 12, design: .monospaced)).foregroundColor(.gray)
                Spacer()
                Image(systemName: "arrow.up.left.and.arrow.down.right").font(.caption).foregroundColor(.gray)
            }
            .padding().background(Color.white.opacity(0.05))

            HStack(spacing: 0) {
                Text("DATE").frame(width: 45, alignment: .leading)
                Text("OPPONENT").frame(width: 80, alignment: .leading)
                Text("SNP").frame(width: 35, alignment: .center)
                Text("TGT").frame(width: 35, alignment: .center)
                Text("REC").frame(width: 35, alignment: .center)
                Text("YDS").frame(width: 45, alignment: .center).foregroundColor(.cyan)
                Text("TD").frame(width: 30, alignment: .center).foregroundColor(.cyan)
                Text("YAC").frame(width: 35, alignment: .center)
            }
            .font(.custom("MicrogrammaD-BoldExte", size: 8)).foregroundColor(.gray)
            .padding(.horizontal, 12).padding(.vertical, 8).background(Color.black.opacity(0.3))

            ForEach(logs) { log in
                HStack(spacing: 0) {
                    Text(log.date).frame(width: 45, alignment: .leading).foregroundColor(.gray)
                    Text(log.opponent).frame(width: 80, alignment: .leading)
                    Text("\(log.snaps)").frame(width: 35, alignment: .center).foregroundColor(.gray)
                    Text("\(log.targets)").frame(width: 35, alignment: .center)
                    Text("\(log.receptions)").frame(width: 35, alignment: .center)
                    Text("\(log.yards)").frame(width: 45, alignment: .center).foregroundColor(.cyan)
                    Text("\(log.touchdowns)").frame(width: 30, alignment: .center).foregroundColor(log.touchdowns > 0 ? .cyan : .gray)
                    Text("\(log.yac)").frame(width: 35, alignment: .center).foregroundColor(.gray)
                }
                .font(.system(size: 11, design: .monospaced)).foregroundColor(.white)
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(logs.firstIndex(where: { $0.id == log.id })! % 2 == 0 ? Color.clear : Color.white.opacity(0.02))
            }
        }
        .border(Color.white.opacity(0.1)).padding(.horizontal, 20)
    }
}

struct StatRow: View {
    var label: String
    var score: Int
    var color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.custom("MicrogrammaD-BoldExte", size: 7)).foregroundColor(.gray)
                .frame(width: 65, alignment: .leading).lineLimit(1)
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Rectangle()
                        .fill(score > index * 20 ? color : Color.white.opacity(0.1))
                        .frame(height: 14)
                }
            }
            Text("\(score)")
                .font(.system(size: 11, weight: .bold, design: .monospaced)).foregroundColor(.white)
                .frame(width: 20, alignment: .trailing)
        }
    }
}

struct CareerSeasonTable: View {
    let stats: [SeasonStat]
    let teamSecondary: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("CAREER SEASON STATS")
                    .font(.custom("MicrogrammaD-BoldExte", size: 10)).foregroundColor(.white)
                Spacer()
            }
            .padding().background(Color.white.opacity(0.05))

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Text("").frame(width: 170)
                        Text("RECEIVING").frame(width: 120, alignment: .center).foregroundColor(.gray)
                        Text("RUSHING").frame(width: 120, alignment: .center).foregroundColor(.gray)
                        Text("SCRIMMAGE").frame(width: 120, alignment: .center).foregroundColor(.gray)
                    }
                    .font(.custom("MicrogrammaD-BoldExte", size: 8)).padding(.vertical, 4)

                    HStack(spacing: 0) {
                        Group {
                            Text("SEASON").frame(width: 45, alignment: .leading)
                            Text("TEAM").frame(width: 80, alignment: .leading)
                            Text("CONF").frame(width: 45, alignment: .leading)
                            Text("G").frame(width: 25, alignment: .center)
                        }
                        Group {
                            Text("REC").frame(width: 40, alignment: .center)
                            Text("YDS").frame(width: 40, alignment: .center).foregroundColor(.cyan)
                            Text("TD").frame(width: 40, alignment: .center)
                        }
                        Group {
                            Text("ATT").frame(width: 40, alignment: .center)
                            Text("YDS").frame(width: 40, alignment: .center).foregroundColor(.cyan)
                            Text("TD").frame(width: 40, alignment: .center)
                        }
                        Group {
                            Text("PLAYS").frame(width: 40, alignment: .center)
                            Text("YDS").frame(width: 40, alignment: .center).foregroundColor(.cyan)
                            Text("TD").frame(width: 40, alignment: .center)
                        }
                    }
                    .font(.custom("MicrogrammaD-BoldExte", size: 8)).foregroundColor(.gray)
                    .padding(.horizontal, 12).padding(.vertical, 8).background(Color.black.opacity(0.3))

                    ForEach(stats) { stat in
                        HStack(spacing: 0) {
                            Group {
                                Text(stat.year).frame(width: 45, alignment: .leading).foregroundColor(.gray)
                                Text(stat.team).frame(width: 80, alignment: .leading).lineLimit(1)
                                Text(stat.conf).frame(width: 45, alignment: .leading).foregroundColor(.gray)
                                Text("\(stat.gamesPlayed)").frame(width: 25, alignment: .center).foregroundColor(.gray)
                            }
                            Group {
                                Text("\(stat.receptions)").frame(width: 40, alignment: .center)
                                Text("\(stat.recYards)").frame(width: 40, alignment: .center).foregroundColor(.cyan)
                                Text("\(stat.recTD)").frame(width: 40, alignment: .center)
                            }
                            Group {
                                Text("\(stat.rushingAtt)").frame(width: 40, alignment: .center)
                                Text("\(stat.rushingYards)").frame(width: 40, alignment: .center).foregroundColor(.cyan)
                                Text("\(stat.rushingTD)").frame(width: 40, alignment: .center)
                            }
                            Group {
                                Text("\(stat.totalPlays)").frame(width: 40, alignment: .center)
                                Text("\(stat.totalYards)").frame(width: 40, alignment: .center).foregroundColor(.cyan)
                                Text("\(stat.totalTD)").frame(width: 40, alignment: .center)
                            }
                        }
                        .font(.system(size: 11, design: .monospaced)).foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(stats.firstIndex(where: { $0.id == stat.id })! % 2 == 0 ? Color.clear : Color.white.opacity(0.02))
                    }
                }
            }
        }
        .border(Color.white.opacity(0.1)).padding(.horizontal, 20)
    }
}

#Preview {
    let dummyProspect = Prospect(
        firstName: "Jordyn", lastName: "Tyson", position: "WR", number: 9,
        teamName: "Arizona State",
        height: "6'1 3/4\"", weight: "203lbs", age: 21,
        bio: "An explosive outside receiver with historic deep-ball tracking.",
        headshotURL: "https://a.espncdn.com/combiner/i?img=/i/headshots/college-football/players/full/4880281.png&w=350&h=254",
        teamLogoURL: "https://a.espncdn.com/i/teamlogos/ncaa/500/9.png",
        primaryColorHex: "8C2248", secondaryColorHex: "FFC226",
        adjImpact: 99, yacAbility: 95, separation: 88, runBlock: 65, pressRel: 82,
        targets: 87, receptions: 61, receivingYards: 711, receivingTouchdowns: 7,
        routesRun: 273, yardsPerGame: 70.0,
        targetShare: 0.227, ADOT: 14.2, catchRate: 0.536, contestedCatchRate: 0.441,
        contestedTargetRate: 0.168, dropRate: 0.044, yardsAfterCatchperReception: 4.9,
        slotRate: 0.279, wideRate: 0.716, yardsPerRouteRun: 2.20, yardsPerTarget: 6.9,
        handSize: "9 1/8\"", fortyYardDash: "4.46", verticalJump: "N/A",
        broadJump: "N/A", twentyYardShuttle: "N/A", threeCone: "N/A",
        gameLogs: [
            GameLog(date: "11/24", opponent: "Arizona",  snaps: 62, targets: 12, receptions: 9, yards: 145, touchdowns: 2, yac: 54, drops: 0),
            GameLog(date: "11/17", opponent: "Oregon",   snaps: 58, targets: 8,  receptions: 5, yards: 88,  touchdowns: 0, yac: 21, drops: 1),
            GameLog(date: "11/10", opponent: "Utah",     snaps: 65, targets: 10, receptions: 7, yards: 112, touchdowns: 1, yac: 45, drops: 0),
        ],
        seasonStats: [
            SeasonStat(year: "2022", team: "Colorado",   conf: "Pac-12", gamesPlayed: 9,  receptions: 22, recYards: 470,  recTD: 4,  rushingAtt: 3, rushingYards: -4, rushingTD: 0, totalPlays: 25, totalYards: 466,  totalTD: 4),
            SeasonStat(year: "2024", team: "Arizona St", conf: "Big 12", gamesPlayed: 12, receptions: 75, recYards: 1101, recTD: 10, rushingAtt: 1, rushingYards: 1,  rushingTD: 0, totalPlays: 76, totalYards: 1102, totalTD: 10),
        ],
        comparisonData: [
            "Makai Lemon":       ["Receptions": 87, "Yards": 1553, "TDs": 13, "Yards/RR": 3.06, "Catch Rate": 71.0, "Drop %": 3.3,  "YAC/R": 5.2, "ADOT": 13.8, "Target Rate": 31.0],
            "Carnell Tate":["Receptions": 67, "Yards": 1211, "TDs": 14, "Yards/RR": 3.44, "Catch Rate": 65.0, "Drop %": 8.2,  "YAC/R": 3.8, "ADOT": 15.1, "Target Rate": 26.0],
            "KC Concepcion":      ["Receptions": 89, "Yards": 1568, "TDs": 14, "Yards/RR": 3.64, "Catch Rate": 73.0, "Drop %": 5.3,  "YAC/R": 6.1, "ADOT": 11.9, "Target Rate": 34.0],
        ]
    )
    PlayerProfileView(prospect: dummyProspect)
}
