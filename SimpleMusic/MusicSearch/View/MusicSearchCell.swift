//
//  MusicSearchCell.swift
//  SimpleMusic
//
//  Created by 薛焱 on 16/7/6.
//  Copyright © 2016年 薛焱. All rights reserved.
//

import UIKit

class MusicSearchCell: UITableViewCell {
    @IBOutlet weak var indexLab: UILabel!

    @IBOutlet weak var picImage: UIImageView!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var singerNameLab: UILabel!
    @IBOutlet weak var titleLab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
