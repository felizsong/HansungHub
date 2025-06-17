import UIKit

class DateCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
        self.clipsToBounds = false

        // label 중앙 정렬 강제
        dateLabel.font = UIFont(name: "MangoDdobak-R", size: 12)
        dateLabel.textAlignment = .center
        dateLabel.textColor = .darkGray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
    }

    func configure(date: Date, selected: Bool) {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"

        if date == Date.distantPast {
            dateLabel.text = ""
            backgroundColor = .clear
            layer.borderColor = UIColor.clear.cgColor
            return
        }

        dateLabel.text = formatter.string(from: date)
        dateLabel.textColor = selected ? .black : .darkGray
        backgroundColor = selected ? UIColor(hex: "#DCEEFF") : .clear
        layer.borderColor = selected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
    }
}
