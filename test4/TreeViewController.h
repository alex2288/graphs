//
//  TreeViewController.h
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import "GraphViewController.h"

@interface TreeViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    UIScrollView * scrollview;
    UIView * treeview;
    UIAlertAction * okaction1;
    BOOL traversingtest;
}

@end
