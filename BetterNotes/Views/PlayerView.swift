//
//  PlayerView.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 19.03.2021.
//

import Foundation
import UIKit

class PlayerView: UIView {
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        
    }
    
    @IBOutlet weak var timer: UILabel!
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    private func configureView() {
        guard let view = self.loadViewFromNib(nibName: "PlayerView") else { return }
        view.frame = self.bounds
        self.addSubview(view)
        view.backgroundColor = .blue
    }
}
