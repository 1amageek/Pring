//
//  MediaDataSourceViewCell.swift
//  Sample
//
//  Created by 1amageek on 2018/03/06.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit

class MediaDataSourceViewCell: UICollectionViewCell {

    let label: UILabel = UILabel(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textAlignment = .center
        self.contentView.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var text: String? {
        didSet {
            self.label.text = text
            self.setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.frame = self.bounds
    }
}
