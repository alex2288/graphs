//
//  GraphViewController.m
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import "GraphViewController.h"

@interface GraphViewController ()

@end

@implementation GraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addScrollView];
    [self addlongPress];
    [self addTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addScrollView {
    self.view.backgroundColor = [UIColor whiteColor];
    scrollview = [[UIScrollView alloc] initWithFrame:(self.view.frame)];
    scrollview.minimumZoomScale = 0.5;
    scrollview.maximumZoomScale = 1;
    graphview = [[UIView alloc] init];
    graphview = [Model initiateGraphMode:(CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)) scrollview:scrollview viewController:self];
    scrollview.contentSize = CGSizeMake(graphview.frame.size.width, graphview.frame.size.height);
    scrollview.delegate = self;
    graphview.autoresizesSubviews = YES;
    [scrollview addSubview:graphview];
    [self.view addSubview:scrollview];
}

- (void)addlongPress {
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPress.delegate = self;
    [self.view addGestureRecognizer:longPress];
}

- (void)addTap {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tap.numberOfTapsRequired = 2;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return graphview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollview.bounds.size.width > scrollview.contentSize.width) ?
    (scrollview.bounds.size.width - scrollview.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollview.bounds.size.height > scrollview.contentSize.height) ?
    (scrollview.bounds.size.height - scrollview.contentSize.height) * 0.5 : 0.0;
    graphview.center = CGPointMake(scrollview.contentSize.width * 0.5 + offsetX, scrollview.contentSize.height * 0.5 + offsetY);
}

CGPoint startlocation;
CGPoint endlocation;

- (void)longPressed:(UILongPressGestureRecognizer *)longPress {
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            startlocation = [longPress locationInView:graphview];
            [Model getstartNodeinPoint:startlocation];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            endlocation = [longPress locationInView:graphview];
            if ([Model checkPointsNodeBelongance:startlocation point:endlocation]) {
                [self nodeMenuAlert];
            }
            else if ([Model getendNodeinPoint:endlocation])
                [Model connectNodes];
            else
                if ([Model checkDrawingAvailabilityinPoint:endlocation UsingStrategy:Graph]) {
                    [self inputNodeValueinPoints:startlocation endlocation:endlocation];
                }
                else
                    [Model showAlert:@"You can't place nodes here!" WithTitle:@"Error" InWorkmode:GraphMode];
            break;
        }
        default:
            ;
            break;
    }
}

UIAlertAction * okaction;
UIAlertController * actionSheet;

- (void)nodeMenuAlert {
    actionSheet = [UIAlertController alertControllerWithTitle:@"Node options" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * first = [UIAlertAction actionWithTitle:@"Edit value" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [Model disableAlternate];
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Node value" message:@"To change current node value, input new value below." preferredStyle:UIAlertControllerStyleAlert];
        okaction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler: ^(UIAlertAction * action) {
            UITextField * str = alert.textFields.firstObject;
            //very ploho
            [Model changeNode:(TreeNode *)[GraphNode new] Valueto:str.text];
        }];
        UIAlertAction * cancelaction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"New value";
            [textField addTarget:self action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        }];
        okaction.enabled = false;
        [alert addAction:cancelaction];
        [alert addAction:okaction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
    UIAlertAction * second = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [Model disableAlternate];
        [Model deleteNodeinPoint:startlocation InWorkmode:GraphMode];
    }];
    UIAlertAction * dfs = [UIAlertAction actionWithTitle:@"Depth-First Search" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [Model disableAlternate];
        [Model startTraversalFromPoint: startlocation UsingTraversal:DepthFirstSearch];
    }];
    UIAlertAction * bfs = [UIAlertAction actionWithTitle:@"Breadth-First Search" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [Model disableAlternate];
        [Model startTraversalFromPoint: startlocation UsingTraversal:BreadthFirstSearch];
    }];
    UIAlertAction * path = [UIAlertAction actionWithTitle:@"Find Shortest Path" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [Model disableAlternate];
        [Model prepareForShortestPathSearchFromPoint:endlocation Alternate:NO];
    }];
    UIAlertAction * testpath = [UIAlertAction actionWithTitle:@"Shortest Path Test" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [Model disableAlternate];
        [Model shortestPathTestWrapperToPoint:endlocation];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }];
    [actionSheet addAction:first];
    [actionSheet addAction:bfs];
    [actionSheet addAction:dfs];
    [actionSheet addAction:path];
    [actionSheet addAction:testpath];
    [actionSheet addAction:second];
    [actionSheet addAction:cancel];
    actionSheet.popoverPresentationController.sourceView = self.view;
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)inputNodeValueinPoints: (CGPoint)startlocation endlocation:(CGPoint)endlocation {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Node value" message:@"To set node's value, input the value below." preferredStyle:UIAlertControllerStyleAlert];
    okaction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler: ^(UIAlertAction * action) {
        UITextField * str = alert.textFields.firstObject;
        [Model newNodeinPoints:startlocation endpoint:endlocation WithValue:str.text WithParent:nil UsingStrategy:Graph
         ];
    }];
    UIAlertAction * cancelaction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * textField) {
        textField.placeholder = @"Node value";
        [textField addTarget:self action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    okaction.enabled = false;
    [alert addAction:cancelaction];
    [alert addAction:okaction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertTextFieldDidChange:(UITextField *)sender {
    UIAlertController * alertController = (UIAlertController *) self.presentedViewController;
    if (alertController) {
        UITextField * login = alertController.textFields.firstObject;
        okaction.enabled = login.text.length > 1;
    }
}

- (void)tapped:(UITapGestureRecognizer *)tap {
    CGPoint location = [tap locationInView:graphview];
    if ([Model isTestEnabled]) {
        if ([Model isEndPointForShortestPathSet]) {
            [Model shortestPathTestinPoint:location];
        }
        else
            [Model setEndPointForShortestPathTest:location];
    }
    else {
        [Model restoreGraphView];
        if ([Model findNodeinPoint:location InWorkmode:GraphMode]) {
            //[Model disableAlternate];
            [Model selectNodeinPoint:location];
        }
        else
            [self optionsMenuAlert];
    }
}

- (void)optionsMenuAlert {
    actionSheet = [UIAlertController alertControllerWithTitle:@"Options" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * first = [UIAlertAction actionWithTitle:@"Graph theory" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [Model disableAlternate];
        InfoViewController * cnt = [[InfoViewController alloc] initWithSubject:@"Graph theory"];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:cnt] animated:YES completion:nil];
    }];
    
    UIAlertAction * second = [UIAlertAction actionWithTitle:@"Help" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [Model disableAlternate];
        InfoViewController * cnt = [[InfoViewController alloc] initWithSubject:@"Help"];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:cnt] animated:YES completion:nil];
    }];
    
    UIAlertAction * fourth = [UIAlertAction actionWithTitle:@"Take a Test" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [Model disableAlternate];
        InfoViewController * cnt = [[InfoViewController alloc] initWithSubject:@"Test"];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:cnt] animated:YES completion:nil];
    }];
    
    UIAlertAction * deleteall = [UIAlertAction actionWithTitle:@"Delete All" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [Model disableAlternate];
        [Model deleteAllInWorkmode:GraphMode];
    }];
    
    UIAlertAction * third = [UIAlertAction actionWithTitle:@"Trees" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        TreeViewController * cnt = [[TreeViewController alloc] init];
        [Model disableAlternate];
        //ploho
        [Model setTreeDrawingStrategy:CustomStrategy];
        [cnt setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self presentViewController:cnt animated:YES completion:nil];
    }];
    
    UIAlertAction * components = [UIAlertAction actionWithTitle:@"Connected Components" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [Model disableAlternate];
        [Model showConnectedComponents];
    }];
    
    UIAlertAction * apath = [UIAlertAction actionWithTitle:@"Show Alternate Path" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [Model showAlternatePath];
    }];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }];
    [actionSheet addAction:first];
    apath.enabled = [Model alternateEnabled];
    [actionSheet addAction:second];
    [actionSheet addAction:components];
    [actionSheet addAction:fourth];
    [actionSheet addAction:third];
    [actionSheet addAction:apath];
    [actionSheet addAction:deleteall];
    [actionSheet addAction:cancel];
    actionSheet.popoverPresentationController.sourceView = self.view;
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end
