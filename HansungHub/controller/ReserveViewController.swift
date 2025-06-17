import UIKit

class ReserveViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    var facilityTitle: String?

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var applicationBtn: UIButton!
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

            applicationBtn.layer.cornerRadius = applicationBtn.frame.height / 2
            applicationBtn.clipsToBounds = true
            applicationBtn.titleLabel?.font = UIFont(name: "MangoDdobak-B", size: 16)

            // 텍스트 필드 설정
            studentIdField.delegate = self
            countField.delegate = self

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
            selectRoom.transform = CGAffineTransform(rotationAngle: .pi * 1.5)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleArrow))
            selectRoom.isUserInteractionEnabled = true
            selectRoom.addGestureRecognizer(tapGesture)

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
    

            // 날짜 영역 화살표
        selectCalendar.transform = CGAffineTransform(rotationAngle: .pi * 1.5)

            let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(toggleArrow2))
            selectCalendar.isUserInteractionEnabled = true
            selectCalendar.addGestureRecognizer(tapGesture2)
        
        // 시간 영역 화살표
        selectTimeImage.transform = CGAffineTransform(rotationAngle: .pi * 1.5)

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
            let angle: CGFloat = isExpanded ? .pi * 1.5 : .pi / 2
            isExpanded.toggle()

            UIView.animate(withDuration: 0.3) {
                self.selectRoom.transform = CGAffineTransform(rotationAngle: angle)
            }

            collectionView.isHidden = !isExpanded
            let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
            selectRoomHeight.constant = isExpanded ? contentHeight + 70 : 54
        }

        @objc func toggleArrow2() {
            let angle: CGFloat = isExpandedCalendar ? .pi * 1.5 : .pi / 2
            isExpandedCalendar.toggle()

            UIView.animate(withDuration: 0.3) {
                self.selectCalendar.transform = CGAffineTransform(rotationAngle: angle)
            }

            calendarCollectionView.isHidden = !isExpandedCalendar
            let contentHeight = calendarCollectionView.collectionViewLayout.collectionViewContentSize.height
            calendarContainerHeight.constant = isExpandedCalendar ? contentHeight + 70 : 54
        }
    
    @objc func toggleArrow3() {
        let angle: CGFloat = isExpandedTimer ? .pi * 1.5 : .pi / 2
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
            let isSelected = selectedTimeIndices.contains(indexPath.item)
            cell.configure(title: time[indexPath.item], selected: isSelected)
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
        } else if collectionView == timeCollection {
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
    
    // 엔터 누르면 키보드 내려감
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // 섹션
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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
