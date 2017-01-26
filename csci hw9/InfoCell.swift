//
//  InfoCell.swift
//  csci hw9
//
//  Created by LiShunni on 5/5/16.
//  Copyright © 2016 LiShunni. All rights reserved.
//

import UIKit

class InfoCell: UITableViewCell {

    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var cap: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
