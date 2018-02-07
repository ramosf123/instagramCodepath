//
//  HomeViewController.swift
//  Instagram
//
//  Created by Farid Ramos on 2/6/18.
//  Copyright © 2018 Farid Ramos. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var posts: [PFObject] = []
    var refreshData: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData = UIRefreshControl()
        refreshData.addTarget(self, action: #selector(HomeViewController.didPullToRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshData, at: 0)
        tableView.delegate = self
        tableView.dataSource = self
        
        getPosts()
    }
    
    @objc func didPullToRefresh(_ refreshData: UIRefreshControl) {
        getPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogOut(_ sender: Any) {
        PFUser.logOutInBackground(block: { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Successful loggout")
                // Load and show the login view controller
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let login = storyboard.instantiateViewController(withIdentifier: "LoginScreen") as! LoginViewController
                self.present(login, animated: true, completion: nil)
            }
        })
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    @IBAction func composeBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "composeSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        let post = posts[indexPath.row]
        
        if let imageObject = post["media"] as? PFFile {
            imageObject.getDataInBackground(block: {
                (imageFile: Data!, error: Error!) -> Void in
                if error == nil {
                    let image = UIImage(data: imageFile)
                    cell.postImage.image = image
                }
            })
        }
        
        if let caption = post["caption"] as? String {
            cell.captionLabel.text = caption
        }
        
        return cell
    }
    
    func getPosts() {
        let query = PFQuery(className: "Post")
        query.addDescendingOrder("createdAt")
        query.limit = 20
        
        query.findObjectsInBackground(block: {(posts, err) in
            if err != nil {
                print(err?.localizedDescription)
                self.refreshData.endRefreshing()
            } else if let posts = posts {
                self.posts = posts
                self.tableView.reloadData()
                self.refreshData.endRefreshing()
            }
        })
        
    }

}
