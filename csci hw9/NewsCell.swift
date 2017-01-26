//
//  NewsCell.swift
//  csci hw9
//
//  Created by LiShunni on 5/4/16.
//  Copyright © 2016 LiShunni. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsContent: UILabel!
    @IBOutlet weak var newsSource: UILabel!
    @IBOutlet weak var newsDate: UILabel!
    var tolink: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
