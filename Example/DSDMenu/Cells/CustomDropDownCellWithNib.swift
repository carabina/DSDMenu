//
//  CustomDropDownCell.swift
//  DropDownButton
//
//  Created by m3g0byt3 on 21/05/2018.
//  Copyright © 2018 m3g0byt3. All rights reserved.
//

import UIKit
import DSDMenu

final class CustomDropDownCellWithNib: DropDownCell {

    // MARK: - IBOutlets

    @IBOutlet private weak var customTextLabel: UILabel!
    @IBOutlet private weak var customImageView: UIImageView!

    // MARK: - Public API

    func configureUsing(_ model: Meal) {
        customTextLabel.text = model.name
        customImageView.image = model.image
    }

    override func prepareForReuse() {
        customTextLabel.text = nil;
        customImageView.image = nil;
    }
}
