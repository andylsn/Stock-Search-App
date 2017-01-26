//
//  CustomCell.swift
//  csci hw9
//
//  Created by LiShunni on 5/4/16.
//  Copyright © 2016 LiShunni. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var rowHead: UILabel!
    @IBOutlet weak var rowData: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
