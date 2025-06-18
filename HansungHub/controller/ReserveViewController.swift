import UIKit
import SwiftSoup

class ReserveViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    var facilityTitle: String?
    var reservationURL: String?

    @IBOutlet weak var mainView: UIView!
   // @IBOutlet weak var applicationBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var studentIdLabel: UILabel!
    @IBOutlet weak var studentIdField: UITextField!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countField: UITextField!

    @IBOutlet weak var selectRoomView: UIView!
    @IBOutlet weak var selectRoom: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!

    // 공간 선택 높이
    @IBOutlet weak var selectRoomHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    
    // 날짜 선택 관련
    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    
    var weekdayLabels: [UILabel] = []
    
    // 날짜 선택 높이
    @IBOutlet weak var calendarContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var calendarCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var selectCalendar: UIImageView!
    
    // 시간 선택
    @IBOutlet weak var selectTimeView: UIView!
    @IBOutlet weak var selectTimeImage: UIImageView!
    @IBOutlet weak var timeCollection: UICollectionView!
    
    @IBOutlet weak var timerCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var timerContainerHeight: NSLayoutConstraint!
    
    // 토글
    var isExpanded = true
    var selectedIndex: Int?
    
    var isExpandedCalendar = true
    var selectedDate: Date? = nil
    var calendarDates: [Date] = []
    
    var selectedTime: Int?
    var isExpandedTimer = true
    
    let time: [String] = (9...20).map { String(format: "%02d:00", $0) }
    var selectedTimeIndices: Set<Int> = []
    
    var disabledTimeSlots: Set<String> = []

    let BaseIdMap: [String: String] = [
        "IB111": "64", "IB101": "63", "IB102": "62", "IB103": "61",
        "IB104": "60", "IB105": "59", "IB106": "58", "IB107": "57", "IB108": "52"
    ]
    
    let roomsForBase = ["IB111", "IB101", "IB102", "IB103", "IB104", "IB105", "IB106", "IB107", "IB108"]
    let roomsForPark = [
        "소모임실 Challenge", "소모임실 Collaboration",
        "소모임실 Communication", "소모임실 Convergence",
        "소모임실 Creativity", "소모임실 Critical Thinking"
    ]
    let roomsForHakJeong = [
        "코워킹룸(3F 창의열람실)", "회의실(5F 상상커먼스)", "그룹스터디실(6F)", "그룹스터디실(5F)", "그룹스터디실(4F)", "그룹스터디실(3F-2)", "그룹스터디실(3F-1)"
    ]
    

    var rooms: [String] {
        switch facilityTitle {
        case "상상파크 플러스":
            return roomsForPark
        case "학술정보관":
            return roomsForHakJeong
        default:
            return roomsForBase
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // 기본 UI 셋업
        mainView.backgroundColor = UIColor(hex: "#FBFAF9")
        titleLabel.text = facilityTitle?.isEmpty == false ? facilityTitle : "상상베이스"

//            applicationBtn.layer.cornerRadius = applicationBtn.frame.height / 2
//            applicationBtn.clipsToBounds = true
//            applicationBtn.titleLabel?.font = UIFont(name: "MangoDdobak-B", size: 16)

        // 텍스트 필드 설정
        studentIdField.delegate = self
        countField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)


        // 카드 스타일 뷰
        selectRoomView.customRoundedCardStyle()
        selectRoomView.superview?.clipsToBounds = false
        calendarContainerView.customRoundedCardStyle()
        calendarContainerView.superview?.clipsToBounds = false
        selectTimeView.customRoundedCardStyle()
        selectTimeView.superview?.clipsToBounds = false

        // 공간 선택 CollectionView 설정
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
        }
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isHidden = false
            
        // 접기/펼치기 화살표
        selectRoom.transform = CGAffineTransform(rotationAngle: isExpanded ? .pi / 2 : -.pi / 2)
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(toggleArrow))
        selectRoom.isUserInteractionEnabled = true
        selectRoom.addGestureRecognizer(tapGesture1)

        // 높이 초기화
        selectRoomHeight.constant = 60

        // 날짜 선택 CollectionView 설정
        if let calendarLayout = calendarCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            calendarLayout.minimumLineSpacing = 10
            calendarLayout.minimumInteritemSpacing = 10
        }
        // 높이 초기화
        selectRoomHeight.constant = 60
    
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarContainerView.isHidden = false
        
        
        // 날짜 설정
        setupCalendarDates()
        setupCalendarHeader()

        calendarContainerHeight.constant = 80
        // 오늘 날짜 선택 및 비활성 시간 업데이트
        let today = Calendar.current.startOfDay(for: Date())
        selectedDate = today
        updateDisabledTimes()
        
        // 날짜 영역 화살표
        selectCalendar.transform = CGAffineTransform(rotationAngle: isExpandedCalendar ? .pi / 2 : -.pi / 2)

        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(toggleArrow2))
        selectCalendar.isUserInteractionEnabled = true
        selectCalendar.addGestureRecognizer(tapGesture2)
    
        // 시간 영역 화살표
        selectTimeImage.transform = CGAffineTransform(rotationAngle: isExpandedTimer ? .pi / 2 : -.pi / 2)

        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(toggleArrow3))
        selectTimeImage.isUserInteractionEnabled = true
        selectTimeImage.addGestureRecognizer(tapGesture3)
    
        // 시간 선택 CollectionView 설정
        if let layout = timeCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
        }
        timeCollection.delegate = self
        timeCollection.dataSource = self
        timeCollection.isHidden = false

        // 높이 초기화
        timerContainerHeight.constant = 60
        
        let applyButton = UIButton(type: .system)
        applyButton.setTitle("신청", for: .normal)
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.backgroundColor = UIColor(hex: "#50453B")
        applyButton.titleLabel?.font = UIFont(name: "MangoDdobak-B", size: 16)
        applyButton.layer.cornerRadius = 18
        applyButton.frame = CGRect(x: 0, y: 0, width: 80, height: 34)
        applyButton.addTarget(self, action: #selector(didTapApplication(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: applyButton)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.layoutIfNeeded()
        calendarCollectionView.layoutIfNeeded()

        let roomContentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        let calendarContentHeight = calendarCollectionView.collectionViewLayout.collectionViewContentSize.height
        
        let timerContentHeight = timeCollection.collectionViewLayout.collectionViewContentSize.height
        
        collectionViewHeight.constant = roomContentHeight
        selectRoomHeight.constant = isExpanded ? roomContentHeight + 80 : 54

        calendarContainerHeight.constant = isExpandedCalendar ? calendarContentHeight + 80 : 54
        
        timerCollectionHeight.constant = timerContentHeight
        timerContainerHeight.constant = isExpandedTimer ? timerContentHeight + 80 : 54
    }


    // MARK: - 날짜 관련
    func setupCalendarDates() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekdayIndex = calendar.component(.weekday, from: today) - 1 // SUN = 0

        // 앞에 빈칸 채우기용 placeholder 날짜
        let paddingDates = Array(repeating: Date.distantPast, count: weekdayIndex)
        let realDates = (0..<14).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
        
        calendarDates = paddingDates + realDates
    }

    func setupCalendarHeader() {
        let today = Date()
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLLL yyyy"

        // 1. monthLabel
        let monthLabel = UILabel()
        monthLabel.text = monthFormatter.string(from: today)
        monthLabel.textAlignment = .center
        monthLabel.font = UIFont(name: "MangoDdobak-B", size: 16)

        // 2. weekdayStack
        let weekdayStack = UIStackView()
        weekdayStack.axis = .horizontal
        weekdayStack.distribution = .fillEqually
        weekdayStack.spacing = 0

        let weekdaySymbols = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        for (i, symbol) in weekdaySymbols.enumerated() {
            let label = UILabel()
            label.text = symbol
            label.textAlignment = .center
            label.font = UIFont(name: "MangoDdobak-R", size: 13)
            label.textColor = (i == 0) ? .systemRed : (i == 6 ? .systemBlue : .darkGray)
            weekdayStack.addArrangedSubview(label)
        }

        // 3. headerStack
        let headerStack = UIStackView(arrangedSubviews: [monthLabel, weekdayStack])
        headerStack.axis = .vertical
        headerStack.spacing = 8
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        calendarContainerView.addSubview(headerStack)

        // 4. 기존 calendarCollectionView 제약 먼저 제거 (스토리보드에서 연결돼 있음)
        calendarCollectionView.removeConstraints(calendarCollectionView.constraints)
        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        calendarContainerView.addSubview(calendarCollectionView)

        // 5. 제약 설정
        NSLayoutConstraint.activate([
            // headerStack
            headerStack.topAnchor.constraint(equalTo: calendarContainerView.topAnchor, constant: 22),
            headerStack.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor, constant: 12),
            headerStack.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor, constant: -5),

            // calendarCollectionView 바로 아래에 붙이기
            calendarCollectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            calendarCollectionView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor, constant: 8),
            calendarCollectionView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor, constant: -8),
            calendarCollectionView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor, constant: -22)
        ])
    }


        // MARK: - 접기/펼치기 제어
        @objc func toggleArrow() {
            let angle: CGFloat = isExpanded ? -.pi / 2 : .pi / 2
            isExpanded.toggle()

            UIView.animate(withDuration: 0.3) {
                self.selectRoom.transform = CGAffineTransform(rotationAngle: angle)
            }

            collectionView.isHidden = !isExpanded
            let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
            selectRoomHeight.constant = isExpanded ? contentHeight + 70 : 54
        }

        @objc func toggleArrow2() {
            let angle: CGFloat = isExpandedCalendar ? -.pi / 2 : .pi / 2
            isExpandedCalendar.toggle()

            UIView.animate(withDuration: 0.3) {
                self.selectCalendar.transform = CGAffineTransform(rotationAngle: angle)
            }

            calendarCollectionView.isHidden = !isExpandedCalendar
            let contentHeight = calendarCollectionView.collectionViewLayout.collectionViewContentSize.height
            calendarContainerHeight.constant = isExpandedCalendar ? contentHeight + 70 : 54
        }
    
    @objc func toggleArrow3() {
        let angle: CGFloat = isExpandedTimer ? -.pi / 2 : .pi / 2
        isExpandedTimer.toggle()

        UIView.animate(withDuration: 0.3) {
            self.selectTimeImage.transform = CGAffineTransform(rotationAngle: angle)
        }

        timeCollection.isHidden = !isExpandedTimer
        let contentHeight = timeCollection.collectionViewLayout.collectionViewContentSize.height
        timerContainerHeight.constant = isExpandedCalendar ? contentHeight + 70 : 54
    }

    // MARK: - CollectionView 데이터소스 & 델리게이트
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == calendarCollectionView {
            return calendarDates.count
        } else if collectionView == timeCollection {
            return time.count
        }
        return rooms.count
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == calendarCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
            let date = calendarDates[indexPath.item]
            let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate ?? Date())
            cell.configure(date: date, selected: isSelected)
            return cell
        } else if collectionView == timeCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCell", for: indexPath) as! TimeCell
            let title = time[indexPath.item]
            let isSelected = selectedTimeIndices.contains(indexPath.item)
            let isDisabled = disabledTimeSlots.contains(title) // ✅ 비활성 여부 확인
                cell.configure(title: title, selected: isSelected, disabled: isDisabled)
                return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomCell", for: indexPath) as! RoomCell
            let isSelected = (indexPath.item == selectedIndex)
            cell.configure(title: rooms[indexPath.item], selected: isSelected)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == calendarCollectionView {
            let newDate = calendarDates[indexPath.item]
            guard newDate != Date.distantPast else { return }
            selectedDate = newDate
            collectionView.reloadData()
            
            updateDisabledTimes()
        } else if collectionView == timeCollection {
            guard selectedDate != nil, selectedIndex != nil else { return } // 공간+날짜 선택 안 했으면 무시
            
            if selectedTimeIndices.contains(indexPath.item) {
                selectedTimeIndices.remove(indexPath.item)
            } else {
                guard selectedTimeIndices.count < 3 else { return }
                selectedTimeIndices.insert(indexPath.item)
            }
            collectionView.reloadItems(at: [indexPath])
        } else {
            let previous = selectedIndex
            selectedIndex = indexPath.item
            var toReload: [IndexPath] = [indexPath]
            if let prev = previous, prev != indexPath.item {
                toReload.append(IndexPath(item: prev, section: 0))
            }
            collectionView.reloadItems(at: toReload)
            
            updateDisabledTimes()
        }
    }


        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 5
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 5
        }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == calendarCollectionView {
            let spacing: CGFloat = 3
            let totalSpacing = spacing * 6
            let width = (collectionView.bounds.width - totalSpacing) / 8
            return CGSize(width: width, height: width)
        } else if collectionView == timeCollection {
            let spacing: CGFloat = 12
            let totalSpacing = spacing * 3
            let width = (collectionView.bounds.width - totalSpacing) / 4
            return CGSize(width: width, height: 40)
        } else {
            guard indexPath.item < rooms.count else { return CGSize(width: 0, height: 0) }
            let title = rooms[indexPath.item]
            let font = UIFont(name: "MangoDdobak", size: 12) ?? .systemFont(ofSize: 12)
            let textWidth = (title as NSString).size(withAttributes: [.font: font]).width
            return CGSize(width: ceil(textWidth + 40), height: 40)
        }
    }
    
    func updateDisabledTimes() {
        guard let selectedDate = selectedDate,
              let selectedIndex = selectedIndex,
              rooms.indices.contains(selectedIndex) else {
            disabledTimeSlots = []
            timeCollection.reloadData()
            return
        }

        let roomName = rooms[selectedIndex]
        fetchDisabledTimeSlots(forRoom: roomName, on: selectedDate) { disabled in
            self.disabledTimeSlots = disabled
            self.timeCollection.reloadData()
        }
    }
    
    func fetchDisabledTimeSlots(forRoom roomName: String, on date: Date, completion: @escaping (Set<String>) -> Void) {
        guard let url = URL(string: "https://www.hansung.ac.kr/onestop/8952/subview.do") else {
            completion([])
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDateStr = dateFormatter.string(from: date)

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, let html = String(data: data, encoding: .utf8), error == nil else {
                print("❌ 네트워크 오류: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            

            do {
                let doc: Document = try SwiftSoup.parse(html)
                let elements = try doc.select("div.conBox")
                var disabledSet: Set<String> = []
                
                for element in elements {
                    var matchedRoom = false
                    var matchedDate = false
                    var commentRoomName = ""
                
                    for node in element.getChildNodes() {
                        if node.nodeName() == "#comment", let commentNode = node as? Comment {
                            let comment = try commentNode.getData()
                            matchedDate = comment.contains(selectedDateStr)
                        }

                        if let textNode = node as? TextNode {
                            let line = textNode.text().trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // 방 이름 매칭: 예) " - IB101" 또는 "IB101" 포함된 경우
                            if line.contains(roomName) && line.replacingOccurrences(of: "\"", with: "").contains("- \(roomName)") {
                                matchedRoom = true
                            }

                            // 시간 정보 파싱
                            if matchedRoom && matchedDate && line.contains("~") {
                                let cleanedLine = line.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                                let times = self.matches(in: cleanedLine, pattern: "\\d{2}:\\d{2}~\\d{2}:\\d{2}")

                                for range in times {
                                    let parts = range.components(separatedBy: "~")
                                    if parts.count == 2 {
                                        let start = self.timeStringToInt(parts[0])
                                        let end = self.timeStringToInt(parts[1])
                                        for t in start..<end {
                                            let slot = String(format: "%02d:00", t)
                                            disabledSet.insert(slot)
                                        }
                                    }
                                }
                            }
                        }
                       

                    }
                }

                DispatchQueue.main.async {
                    completion(disabledSet)
                }
                print("🚫 disabledSet: \(disabledSet)")

            } catch {
                print("❌ SwiftSoup 파싱 오류: \(error.localizedDescription)")
                completion([])
            }
        }.resume()
    }

    func matches(in text: String, pattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.compactMap {
                Range($0.range, in: text).map { String(text[$0]) }
            }
        } catch {
            return []
        }
    }

    func timeStringToInt(_ time: String) -> Int {
        let parts = time.split(separator: ":")
        if let hour = Int(parts[0]) {
            return hour
        }
        return -1
    }

    
    // 엔터 누르면 키보드 내려감
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // 섹션
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    @objc func didTapApplication(_ sender: Any) {
        guard let reservationURL = reservationURL, let url = URL(string: reservationURL) else { return }
        guard let studentId = studentIdField.text, !studentId.isEmpty,
              let count = countField.text, !count.isEmpty,
              let selectedDate = selectedDate,
              let roomIndex = selectedIndex,
              rooms.indices.contains(roomIndex) else {
            print("입력값 누락")
            return
        }

        // 하드코딩된 사용자 정보
        let userName = getSecret("userNm")
        let telno = getSecret("telno")
        let email = getSecret("email")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: selectedDate)
        let times = self.selectedTimeIndices.sorted().map { self.time[$0] }
        let savedStudentId = UserDefaults.standard.string(forKey: "studentId") ?? ""

        var components = URLComponents()
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "siteId", value: "onestop"),
            URLQueryItem(name: "fnctNo", value: "21"),
            URLQueryItem(name: "groupNm", value: "상상베이스"),
            URLQueryItem(name: "spceNm", value: self.rooms[roomIndex]),
            URLQueryItem(name: "resveSpceSeq", value: self.BaseIdMap[self.rooms[roomIndex]] ?? ""),
            URLQueryItem(name: "resveDeStr", value: dateStr),
            URLQueryItem(name: "userNm", value: userName),
            URLQueryItem(name: "hakbun", value: savedStudentId),
            URLQueryItem(name: "telno", value: telno),
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "addItemMustYn1", value: "Y"),
            URLQueryItem(name: "addItem1", value: studentId),
            URLQueryItem(name: "addItemMustYn2", value: "Y"),
            URLQueryItem(name: "addItem2", value: count),
            URLQueryItem(name: "group", value: "37"),
            URLQueryItem(name: "resveGroupSeq", value: "37"),
            URLQueryItem(name: "mngr", value: "학생원스톱지원센터"),
            URLQueryItem(name: "mngrTelno", value: "02-760-8000"),
            URLQueryItem(name: "identityCode", value: "교수,직원,조교,강사,학술연구원,기타교수,학사(재학생),대학원(재학생)")
        ]

        for t in times {
            queryItems.append(URLQueryItem(name: "resveTm", value: t))
        }

        components.queryItems = queryItems

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)

        if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            let cookieHeader = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
            request.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
        }

        if let body = request.httpBody, let bodyStr = String(data: body, encoding: .utf8) {
            print("📦 Body:\n\(bodyStr)")
        }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpCookieAcceptPolicy = .always
        sessionConfig.httpShouldSetCookies = true
        sessionConfig.httpCookieStorage = HTTPCookieStorage.shared
        let session = URLSession(configuration: sessionConfig)

        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                if let response = response as? HTTPURLResponse {
                    print("Response: \(response.statusCode)")
                    if (200...299).contains(response.statusCode) {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                if let data = data, let str = String(data: data, encoding: .utf8) {
                    print("Response Body: \(str)")
                }
            }
        }.resume()
    }
    
    func getSecret(_ key: String) -> String {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            return dict[key] ?? ""
        }
        return ""
    }


}

// 카드 스타일 확장
extension UIView {
    func customRoundedCardStyle(background: UIColor = .white, radius: CGFloat = 10) {
        self.backgroundColor = background
        self.layer.cornerRadius = radius
        self.layer.shadowColor = UIColor(hex: "#50453B").cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }
}
