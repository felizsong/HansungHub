import UIKit

class TimeCell: UICollectionViewCell {
    @IBOutlet weak var timeButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 버튼 제약 코드 설정
        timeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            timeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            timeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            timeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        // 스타일 설정
        timeButton.layer.cornerRadius = 15
        timeButton.layer.borderWidth = 1
        timeButton.layer.borderColor = UIColor(hex: "#D0D0D0").cgColor
        timeButton.clipsToBounds = true
        timeButton.isUserInteractionEnabled = false
        timeButton.contentEdgeInsets = .zero

        // 폰트 및 텍스트 스타일
        timeButton.titleLabel?.font = UIFont(name: "MangoDdobak-R", size: 12)
        timeButton.titleLabel?.numberOfLines = 1
        timeButton.titleLabel?.lineBreakMode = .byTruncatingTail
        timeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        timeButton.titleLabel?.minimumScaleFactor = 0.8
    }

    func configure(title: String, selected: Bool, disabled: Bool = false) {
        timeButton.setTitle(title, for: .normal)

        if disabled {
            timeButton.backgroundColor = .white
            timeButton.setTitleColor(UIColor(hex: "#AAAAAA"), for: .normal)
            timeButton.layer.borderColor = UIColor(hex: "#D0D0D0").cgColor
        } else {
            if selected {
                timeButton.backgroundColor = UIColor(hex: "#50453B")
                timeButton.setTitleColor(UIColor(hex: "#FBFAF9"), for: .normal)
                timeButton.layer.borderColor = UIColor.clear.cgColor
            } else {
                timeButton.backgroundColor = .white
                timeButton.setTitleColor(.black, for: .normal)
                timeButton.layer.borderColor = UIColor(hex: "#D0D0D0").cgColor
            }
        }

        timeButton.layer.cornerRadius = 20
        timeButton.layer.borderWidth = 1
        timeButton.clipsToBounds = true
    }

}
