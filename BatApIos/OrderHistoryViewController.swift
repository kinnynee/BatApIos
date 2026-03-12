//
//  OrderHistoryViewController.swift
//  BatApIos
//
//  Created by Trần Kiên on 11/3/26.
//
import UIKit

class OrderHistoryViewController: UIViewController {

    // 1. Kéo thả tạo Outlet cho 3 nút
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var pendingButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        updateTabSelection(selectedButton: completedButton)
    }

    // 2. Kéo thả Action từ 3 nút vào CHUNG MỘT HÀM này
    @IBAction func tabTapped(_ sender: UIButton) {
        // Đổi màu giao diện
        updateTabSelection(selectedButton: sender)
        if sender == completedButton {
            print("Đang load danh sách Sân Đã hoàn thành...")
        } else if sender == pendingButton {
            print("Đang load danh sách Sân Đang chờ...")
        } else if sender == cancelButton {
            print("Đang load danh sách Sân Đã hủy...")
        }
    }

    // 3. Hàm xử lý logic đổi màu nền và màu chữ
    func updateTabSelection(selectedButton: UIButton) {
        let allTabs = [completedButton, pendingButton, cancelButton]
        
        for button in allTabs {
            if button == selectedButton {
                button?.backgroundColor = UIColor.systemGreen
                button?.setTitleColor(.white, for: .normal)
            } else {
                button?.backgroundColor = .clear
                button?.setTitleColor(.darkGray, for: .normal)
            }
        }
    }
}
