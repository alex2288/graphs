//
//  GraphViewController.h
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import "InfoViewController.h"
#import "TreeViewController.h"

@interface GraphViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    UIScrollView * scrollview;
    UIView * graphview;
}

@end
