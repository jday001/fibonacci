//
//  MyTableViewController.swift
//  Fibonacci
//
//  Created by Jeff Day on 2/4/15.
//  Copyright (c) 2015 JDay Apps, LLC. All rights reserved.
//

import UIKit

class MyTableViewController: UITableViewController {
    
    var fibArray: [Int] = Array()
    let fibGenerator = FibonacciGenerator()
    
    /// queue for recursive version
    private let recursiveQueue: dispatch_queue_t = dispatch_queue_create("com.jdayapps.fib2", DISPATCH_QUEUE_SERIAL)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // GCD recursive
        //dispatch_async(recursiveQueue, { () -> Void in
        
            // start with an arbitrary first 20 numbers in the sequence
            for (var i: Int = 0; i < 20; i++) {
                
                // FAST version
                // notice the abbreviated closure syntax (could also just have `{ (nextFib) in`
                self.fibGenerator.generateFibonacciAtN(i) { (nextFib: Int) in
                    self.fibArray.append(nextFib)
                    self.tableView.reloadData()
                }
                
                // dynamic without GCD
                /*
                self.fibGenerator.dynamicFibonacciAtN(i) { (nextFib: Int) in
                    self.fibArray.append(nextFib)
                    self.tableView.reloadData()
                }*/
                
                // SLOW version
                /*
                self.fibArray.append(self.fibGenerator.slowFibonacciAtN(i))
                self.tableView.reloadData()*/
                
                // GCD recursive
                /*
                self.fibArray.append(self.fibGenerator.slowFibonacciAtN(i))
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })*/
            }
        //})
    }

    
    
    // MARK: - UITableViewDataSource Methods

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fibArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath: indexPath) as UITableViewCell

        cell.textLabel?.text = "n(\(indexPath.row)): \(self.fibArray[indexPath.row])"

        return cell
    }
    
    
    
    // MARK: - UIScrollView Delegate Methods
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // determine how close we are to the bottom of the tableView
        let scrolledTo = scrollView.contentOffset.y + scrollView.bounds.height
        
        // as we get near the bottom, want to keep adding more rows
        if (scrolledTo + 100) > scrollView.contentSize.height {
            
            // FAST version -- dynamic with GCD
            // add more fibonacci numbers -- also notice more descriptive closure syntax
            self.fibGenerator.generateFibonacciAtN(self.tableView.numberOfRowsInSection(0),
                completion: { (nextFib: Int) -> () in
                
                    if nextFib > 0 {
                        self.fibArray.append(nextFib)
                        self.tableView.reloadData()
                    }
            })
            
            // dynamic without GCD
            /*
            self.fibGenerator.dynamicFibonacciAtN(self.tableView.numberOfRowsInSection(0),
                completion: { (nextFib: Int) -> () in
                    
                    if nextFib > 0 {
                        self.fibArray.append(nextFib)
                        self.tableView.reloadData()
                    }
            })*/
            
            // SLOW version
            //self.fibArray.append(self.fibGenerator.slowFibonacciAtN(self.tableView.numberOfRowsInSection(0)))
            //self.tableView.reloadData()
            
            // GCD recursive
            /*
            dispatch_async(recursiveQueue, { () -> Void in
                self.fibArray.append(self.fibGenerator.slowFibonacciAtN(self.tableView.numberOfRowsInSection(0)))
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            })*/
        }
    }
}
