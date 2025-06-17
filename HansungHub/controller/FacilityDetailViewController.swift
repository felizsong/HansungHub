import UIKit
class FacilityDetailViewController: UIViewController {
    var facilityTitle: String?
    var facilityImage: UIImage?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var reserveBtn: UIButton!
    
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
    }

    @IBAction func reserveButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let reserveVC = storyboard.instantiateViewController(withIdentifier: "ReserveViewController") as? ReserveViewController {
            reserveVC.facilityTitle = titleLabel.text  // 또는 facilityTitle
            self.navigationController?.pushViewController(reserveVC, animated: true)
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
