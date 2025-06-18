import UIKit
import SwiftSoup

class MyPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var logoutLabel: UILabel!
    
    var reservations: [Reservation] = [
        Reservation(roomName: "상상베이스 IB108", date: "2025년 6월 19일 목", time: "13:00~14:00"),
        Reservation(roomName: "상상베이스 IB107", date: "2025년 5월 28일 수", time: "14:00~17:00"),
        Reservation(roomName: "상상베이스 IB103", date: "2025년 5월 20일 화", time: "19:00~21:00"),
        Reservation(roomName: "그룹스터디실 3F–2", date: "2025년 5월 20일 화", time: "15:00~18:00"),
        Reservation(roomName: "소모임실 Critical Thinking", date: "2025년 5월 8일 목", time: "14:00~16:00"),
        Reservation(roomName: "상상베이스 IB107", date: "2025년 3월 25일 화", time: "15:00~17:00"),
        Reservation(roomName: "그룹스터디실(3F-2)", date: "2025년 3월 20일 목", time: "13:00~15:00")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor(hex: "#FBFAF9")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
        logoutLabel.isUserInteractionEnabled = true
        logoutLabel.addGestureRecognizer(tap)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return reservations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let item = reservations[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

            cell.textLabel?.text = item.roomName
            cell.detailTextLabel?.text = "\(item.date) (\(item.time))"

            cell.textLabel?.font = UIFont(name: "MangoDdobak-B", size: 16)
            cell.detailTextLabel?.font = UIFont(name: "MangoDdobak-R", size: 16)

            // 셀 내부 라벨 간 간격 (line height 24pt처럼 보이게)
            cell.detailTextLabel?.numberOfLines = 0
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = 24
            paragraphStyle.maximumLineHeight = 24
            cell.detailTextLabel?.attributedText = NSAttributedString(
                string: cell.detailTextLabel?.text ?? "",
                attributes: [
                    .font: UIFont(name: "MangoDdobak-R", size: 16) ?? .systemFont(ofSize: 16),
                    .paragraphStyle: paragraphStyle
                ]
            )

            cell.backgroundColor = .clear
            cell.selectionStyle = .none

            return cell
    }

    // 셀 간 간격
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 72 // 글씨 2줄 + 여백
        }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 0.1 // 안 보이게
        }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            return 0.1
    }

    // 셀 간 간격용 투명 뷰 추가 (방법 2: spacing 효과)
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            return UIView()
    }
    

    
    // MARK: - 로그아웃 기능
    @objc func logoutTapped() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "isLogIn")
        defaults.removeObject(forKey: "studentId")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true, completion: nil)

    }

    
    struct Reservation {
        let roomName: String
        let date: String   // ex: "2025년 5월 28일 수"
        let time: String   // ex: "14:00~17:00"
    }
}

