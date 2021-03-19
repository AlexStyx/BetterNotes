//
//  Cell.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 06.02.2021.
//

import UIKit


class NoteCell: UITableViewCell {
    
    @IBOutlet weak var noteHeadtitleLabel: UILabel!
    
    @IBOutlet weak var noteTextLabel: UILabel!
}


extension NoteCell {
    
    override open var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.y += 10
            frame.origin.x += 10
            frame.size.height -= 2 * 10
            frame.size.width -= 2 * 10
            super.frame = frame
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 0.1
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 15
        layer.masksToBounds = false
    }
}
