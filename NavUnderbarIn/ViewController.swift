//
//  ViewController.swift
//  NavUnderbarIn
//
//  Created by Admin on 22/08/2017.
//  Copyright © 2017 1C Rarus. All rights reserved.
//

import UIKit

class ViewController: B32UnderViewController {

    var cellColor: [Int] = []
    var cellHeight: [CGFloat] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        underLabelText = "Hello world Hello world Hello world Hello world Hello world Hello world Hello world Hello world "

        tableView.delegate = self
        tableView.dataSource = self
        
        for _ in 0..<20 {
            cellColor.append(Int(arc4random_uniform(3)+1))
            cellHeight.append(CGFloat(arc4random_uniform(40)+30))
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "TableCell\(cellColor[indexPath.row])")!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
}


extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = (storyboard.instantiateViewController(withIdentifier: arc4random_uniform(2) == 0 ? "SecondVC" : "NewController") as! B32UnderViewController)
        if let _newVC = newVC as? NewViewController {
            if(arc4random_uniform(2) == 0) {
                _newVC.underLabelText = "Hello world Hello world Hello world Hello world Hello world Hello world Hello world Hello world"
            }
        }
        self.navigationController?.pushViewController(newVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(cellHeight[indexPath.row])
    }
}
