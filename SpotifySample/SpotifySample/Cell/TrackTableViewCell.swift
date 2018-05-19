//
//  TrackTableViewCell.swift
//  SpotifySample
//
//  Created by Rafael Moraes on 19/05/18.
//  Copyright © 2018 Rafael Moraes. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {

    static let identifier = "TrackTableViewCell"

    var track: Track? {
        didSet {
            lblTitle.text = track?.name
        }
    }

    @IBOutlet fileprivate weak var lblTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
