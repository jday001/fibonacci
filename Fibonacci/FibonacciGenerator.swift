//
//  FibonacciGenerator.swift
//  Fibonacci
//
//  Created by Jeff Day on 2/4/15.
//  Copyright (c) 2015 JDay Apps, LLC. All rights reserved.
//

import UIKit

/**
    FibonacciGenerator is a class used to calculate the nth Fibonacci number in the sequence. It uses GCD,
    performing calculations in a serial queue to ensure numbers are added to the sequence in the correct
    order.

    If the Fibonacci number for a given n would cause an overflow according to the device's max integer
    value, `generateFibonacciAtN` returns -1 so the caller can gracefully handle the situation.
*/
class FibonacciGenerator {
    
    /// A closure type with an Int parameter.
    typealias FibonacciCompletion = (Int) -> ()

    /// A serial queue used to ensure Fibonacci numbers are added to `fibValues` in order.
    private let queue: dispatch_queue_t = dispatch_queue_create("com.jdayapps.fibonacciGenerator", DISPATCH_QUEUE_SERIAL)
    
    /// An array of Fibonacci numbers, i.e. 1, 1, 2, 3, 5, 8, etc...
    private var fibValues: [Int] = Array()
    
    
    /**
        A method to generate the nth value in a Fibonacci sequence. If n is a value so large that
        it would cause Int to overflow, a value of -1 will be returned by the completion handler.

        :param: n           An Int zero-based index for the position in the Fibonacci sequence.
        :param: completion  A completion handler passing either an Int value
                for the number in the Fibonacci sequence at index `n`, or -1 if the n value is so
                high that it would cause Int to overflow.
    */
    func generateFibonacciAtN(n: Int, completion: FibonacciCompletion) {
        
        // use a serial queue to make sure Fibonacci numbers are added to `fibValues` in order
        dispatch_async(queue, { () -> Void in
            
            // 1, 1, 2, 3, 5, 8, 13
            for (var i = 0; i <= n; i++) {
                
                if ((self.fibValues.count - 1) < i || self.fibValues.count == 0) {
                    
                    switch i {
                    case 0, 1: self.fibValues.append(1)
                    default:
                        
                        // check for an Int overflow -- the &+ operator will return 0 if the operation overflows
                        let nextFib = self.fibValues[i-1] &+ self.fibValues[i-2]
                        
                        if nextFib > 0 {
                            self.fibValues.append(nextFib)
                        } else {
                            
                            // Fibonacci number is big enough to overflow Int, return -1 and stop
                            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                completion(-1)
                            })
                            return
                        }
                    }
                }
            }
            
            // if we get this far, added a new Fibonacci number to the sequence -- call completion handler
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                completion(self.fibValues[n])
            })
        })
        
    }
    
    
    /**
        A slow, recursive method for calculating the Fibonacci sequence. Doesn't check for overflow,
        but you are unlikely to get that far anyway without serious patience.
    
        :param: n   An Int zero-based index for the position in the Fibonacci sequence.
    */
    func slowFibonacciAtN(n: Int) -> Int {
        if n == 0 || n == 1 {
            return 1
        } else {
            return slowFibonacciAtN(n - 1) + slowFibonacciAtN(n - 2)
        }
    }
    
    
    
    /**
        A method to generate the nth value in a Fibonacci sequence. If n is a value so large that
        it would cause Int to overflow, a value of -1 will be returned by the completion handler. This method
        does not offload any calculations from the main thread.
        
        :param: n           An Int zero-based index for the position in the Fibonacci sequence.
        :param: completion  A completion handler passing either an Int value
        for the number in the Fibonacci sequence at index `n`, or -1 if the n value is so
        high that it would cause Int to overflow.
    */
    func dynamicFibonacciAtN(n: Int, completion: FibonacciCompletion) {
            
        // 1, 1, 2, 3, 5, 8, 13
        for (var i = 0; i <= n; i++) {
            
            if ((self.fibValues.count - 1) < i || self.fibValues.count == 0) {
                
                switch i {
                case 0, 1: self.fibValues.append(1)
                default:
                    
                    // check for an Int overflow -- the &+ operator will return 0 if the operation overflows
                    let nextFib = self.fibValues[i-1] &+ self.fibValues[i-2]
                    
                    if nextFib > 0 {
                        self.fibValues.append(nextFib)
                    } else {
                        
                        // Fibonacci number is big enough to overflow Int, return -1 and stop
                        completion(-1)
                        return
                    }
                }
            }
        }
        
        // if we get this far, added a new Fibonacci number to the sequence -- call completion handler
        completion(self.fibValues[n])
    }
}
