//
//  HomeViewController.swift
//  Final Project Stellar
//
//  Created by Michael Tapia on 3/31/24.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createPostTapped(_ sender: UIButton) {
        let postView = UIView()
                postView.backgroundColor = .white
                postView.layer.cornerRadius = 10
                // Add other UI elements (labels, image views, etc.) to the postView

                // Calculate the position for the new post view
                let newYPosition = scrollView.contentSize.height
                postView.frame = CGRect(x: 0, y: newYPosition, width: scrollView.bounds.width, height: 200)

                // Add the post view to the scroll view
                scrollView.addSubview(postView)

                // Update the scroll view's content size
                scrollView.contentSize.height += postView.frame.height
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
