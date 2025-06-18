import UIKit
class FacilityDetailViewController: UIViewController {
    var facilityTitle: String?
    var facilityImage: UIImage?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var reserveBtn: UIButton!
    
    @IBOutlet weak var naksanButton: UIButton!
    @IBOutlet weak var sangsangButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = facilityTitle
        imageView.image = facilityImage
        
        reserveBtn.titleLabel?.font = UIFont(name: "MangoDdobak-B", size: 16)

        reserveBtn.layer.cornerRadius = reserveBtn.frame.height / 2  // 원형
        reserveBtn.clipsToBounds = true

        // 그림자
        reserveBtn.layer.shadowColor = UIColor.black.cgColor
        reserveBtn.layer.shadowOpacity = 0.3
        reserveBtn.layer.shadowRadius = 6
        reserveBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        // 초기 상태: 하위 버튼 숨김
        naksanButton.isHidden = true
        sangsangButton.isHidden = true

        if facilityTitle == "체육시설" {
            reserveBtn.setTitle("예약하기", for: .normal)
        } else {
            // 다른 시설이면 기존 예약 흐름 유지
            naksanButton.isHidden = true
            sangsangButton.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 버튼 라운딩 여기서 보장
        naksanButton.layer.cornerRadius = naksanButton.frame.height / 2
        sangsangButton.layer.cornerRadius = sangsangButton.frame.height / 2
    }

    func configureFacilityButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "MangoDdobak-B", size: 16)
        button.backgroundColor = UIColor(hex: "50453B")
    }
    
    @IBAction func reserveButtonTapped(_ sender: UIButton) {
        if facilityTitle == "체육시설" {
            // 체육시설이면 하위 버튼 표시
            naksanButton.isHidden = false
            sangsangButton.isHidden = false
            configureFacilityButton(naksanButton, title: "낙산관")
            configureFacilityButton(sangsangButton, title: "상상관")
        } else {
            // 기존 예약 흐름
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let reserveVC = storyboard.instantiateViewController(withIdentifier: "ReserveViewController") as? ReserveViewController {
                reserveVC.facilityTitle = titleLabel.text
                reserveVC.reservationURL = reservationURL(for: facilityTitle)
                self.navigationController?.pushViewController(reserveVC, animated: true)
            }
        }
    }
    
    @IBAction func naksanTapped(_ sender: UIButton) {
        downloadFile(urlString: "https://www.hansung.ac.kr/sites/hansung/files/1540433329327.hwp")
    }

    @IBAction func sangsangTapped(_ sender: UIButton) {
        downloadFile(urlString: "https://www.hansung.ac.kr/sites/hansung/학교시설물이용신청서%20(1).hwp")
    }

    func downloadFile(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    
    func reservationURL(for title: String?) -> String? {
        switch title {
        case "상상베이스":
            return "https://www.hansung.ac.kr/resve/onestop/21/artclRegistView.do?layout=unknown"
        case "상상파크 플러스":
            return "https://www.hansung.ac.kr/resve/cncschool/6/artclRegistView.do?layout=unknown"
        default:
            return nil
        }
    }

}
