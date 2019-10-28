//
//  musicTableViewCell.swift
//  Mindses
//
//  Created by hacku on 26/10/2017.
//  Copyright © 2017 Profil Software. All rights reserved.
//

import UIKit

class cardsTableViewCell: UITableViewCell {

    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var descriptionView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
