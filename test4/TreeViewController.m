//
//  TreeViewController.m
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import "TreeViewController.h"

@implementation TreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addScrollView];
    [self addGestureRecognizers];
}

- (void)addGestureRecognizers {
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPress.delegate = self;
    [self.view addGestureRecognizer:longPress];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tap.numberOfTapsRequired = 2;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)addScrollView {
    self.view.backgroundColor = [UIColor whiteColor];
    scrollview = [[UIScrollView alloc] initWithFrame:(self.view.frame)];
    scrollview.minimumZoomScale = 0.5;
    scrollview.maximumZoomScale = 1;
    treeview = [[UIView alloc] init];
    traversingtest = false;
    treeview = [Model initiateTreeMode: scrollview viewcontroller:self];
    scrollview.contentSize = CGSizeMake(treeview.frame.size.width, treeview.frame.size.height);
    scrollview.delegate = self;
    treeview.autoresizesSubviews = YES;
    [scrollview addSubview:treeview];
    [self.view addSubview:scrollview];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollview {
    return treeview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollview.bounds.size.width > scrollview.contentSize.width) ?
    (scrollview.bounds.size.width - scrollview.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollview.bounds.size.height > scrollview.contentSize.height) ?
    (scrollview.bounds.size.height - scrollview.contentSize.height) * 0.5 : 0.0;
    treeview.center = CGPointMake(scrollview.contentSize.width * 0.5 + offsetX, scrollview.contentSize.height * 0.5 + offsetY);
}

- (void)longPressed:(UILongPressGestureRecognizer *)longPress {
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            [Model setNewTreeNodeParentInPoint:[longPress locationInView:treeview]];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGPoint endPoint = [longPress locationInView:treeview];
            if ([Model getNewTreeNodeParent]) {
                if ([Model findNodeinPoint:endPoint InWorkmode:TreeMode]) {
                    [self nodeOptions:[Model findNodeinPoint:endPoint InWorkmode:TreeMode]];
                }
                else
                    if ([Model checkDrawingAvailabilityinPoint:endPoint UsingStrategy:[Model getTreeDrawingStrategy]])
                        [self inputNodeValueinPoint:endPoint WithParent:[Model getNewTreeNodeParent]];
                    else
                       [Model showAlert:@"You can't place nodes here!" WithTitle:@"Error" InWorkmode:TreeMode];
                break;
            }
        }
        default:
            break;
    }
}

- (void) alertTextFieldDidChange:(UITextField *)sender {
    UIAlertController * alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField * field = alertController.textFields.firstObject;
        okaction1.enabled = field.text.length > 1;
    }
}

- (void) tapped:(UITapGestureRecognizer *) tap {
    if (traversingtest) {
        if ([Model traversalTestinPoint:[tap locationInView: treeview]])
            traversingtest = false;
    }
    else {
        if (![Model findNodeinPoint:[tap locationInView: treeview] InWorkmode:TreeMode]) {
            [self generalOptions];
            [Model redrawTreeUsingStrategy:[Model getTreeDrawingStrategy]];
        }
        else {
            [Model rollUpWrapperForNode:[Model findNodeinPoint:[tap locationInView: treeview] InWorkmode:TreeMode] UsingStrategy:[Model getTreeDrawingStrategy]];
        }
    }
}

- (void) generalOptions {
    UIAlertController * actions = [UIAlertController alertControllerWithTitle:@"Options" message:@"Select tree's drawing view, or perform different actions" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * first = [UIAlertAction actionWithTitle:@"Redraw options" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
        [self redrawOptions];
    }];
    UIAlertAction * third = [UIAlertAction actionWithTitle:@"Traversal options" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
        [self traversalOptions];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction * last = [UIAlertAction actionWithTitle:@"Graphs" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
        GraphViewController * gvc = [[GraphViewController alloc] init];
        [Model setTreeDrawingStrategy:Graph];
        [gvc setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self presentViewController:gvc animated:YES completion:nil];
    }];
    UIAlertAction * deleteall = [UIAlertAction actionWithTitle:@"Delete All" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
        [Model deleteAllInWorkmode:TreeMode];
    }];
    [actions addAction:first];
    [actions addAction:third];
    [actions addAction:cancel];
    [actions addAction:last];
    [actions addAction:deleteall];
    actions.popoverPresentationController.sourceView = self.view;
    [self presentViewController:actions animated:YES completion:nil];
}

- (void) nodeOptions:(TreeNode *)node {
    UIAlertController * actions = [UIAlertController alertControllerWithTitle:@"Node options" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * first = [UIAlertAction actionWithTitle:@"Edit value" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Node value" message:@"To change current node value, input new value below." preferredStyle:UIAlertControllerStyleAlert];
        okaction1 = [UIAlertAction actionWithTitle:@"OK" style:
            //very ploho
            UIAlertActionStyleDefault handler: ^(UIAlertAction * action) {
            UITextField * str = alert.textFields.firstObject;
            [Model changeNode:node Valueto:str.text];
        }];
        UIAlertAction * cancelaction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * textField) {
            textField.placeholder = @"New value";
            [textField addTarget:self action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        }];
        okaction1.enabled = false;
        [alert addAction:cancelaction];
        [alert addAction:okaction1];
        alert.popoverPresentationController.sourceView = self.view;
        [self presentViewController:alert animated:YES completion:nil];
    }];
    UIAlertAction * second = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
        switch ([Model getTreeDrawingStrategy]) {
            case ClassicStrategy:
                [Model deleteNodeinPoint:node.coordinates1 InWorkmode:TreeMode];
                break;
            case CustomStrategy:
                [Model deleteNodeinPoint:node.coordinates InWorkmode:TreeMode];
            default:
                break;
        }
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction * coloredit = [UIAlertAction actionWithTitle:@"Change node color" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [actions dismissViewControllerAnimated:YES completion:nil];
            UIAlertController * color = [UIAlertController alertControllerWithTitle:@"Node colors" message:@"Select new node color from the following: " preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction * red = [UIAlertAction actionWithTitle:@"Red" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            node.layer.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0].CGColor;
            [color dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction * orange = [UIAlertAction actionWithTitle:@"Orange" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            node.layer.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:153.0f/255.0f blue:0.0f/255.0f alpha:1.0].CGColor;
            [color dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction * yellow = [UIAlertAction actionWithTitle:@"Yellow" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            node.layer.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:0.0f/255.0f alpha:1.0].CGColor;
            [color dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction * green = [UIAlertAction actionWithTitle:@"Green" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            node.layer.backgroundColor = [UIColor colorWithRed:5.0f/255.0f green:176.0f/255.0f blue:5.0f/255.0f alpha:1.0].CGColor;
            [color dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction * blue = [UIAlertAction actionWithTitle:@"Blue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            node.layer.backgroundColor = [UIColor colorWithRed:74.0f/255.0f green:134.0f/255.0f blue:232.0f/255.0f alpha:1.0].CGColor;
            [color dismissViewControllerAnimated:YES completion:nil];
            }];
        UIAlertAction * purple = [UIAlertAction actionWithTitle:@"Purple" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            node.layer.backgroundColor = [UIColor colorWithRed:188.0f/255.0f green:0.0f/255.0f blue:255.0f/255.0f alpha:1.0].CGColor;
            [color dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [color dismissViewControllerAnimated:YES completion:nil];
            }];
            [color addAction:red];
            [color addAction:orange];
            [color addAction:yellow];
            [color addAction:green];
            [color addAction:blue];
            [color addAction:purple];
            [color addAction:cancel];
            color.popoverPresentationController.sourceView = self.view;
            [self presentViewController:color animated:YES completion:nil];
        }];
        [actions addAction:first];
        [actions addAction:coloredit];
        [actions addAction:second];
        [actions addAction:cancel];
        if ([Model getTreeRoot] == node)
            second.enabled = false;
        actions.popoverPresentationController.sourceView = self.view;
        [self presentViewController:actions animated:YES completion:nil];
}

- (void)inputNodeValueinPoint: (CGPoint)endlocation WithParent:(TreeNode *) parent {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Node value" message:@"To set node's value, input the value below." preferredStyle:UIAlertControllerStyleAlert];
    okaction1 = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler: ^(UIAlertAction * action) {
        UITextField * str = alert.textFields.firstObject;
        //ploho
        [Model newNodeinPoints:endlocation endpoint:endlocation WithValue:str.text WithParent:parent UsingStrategy:[Model getTreeDrawingStrategy]];
    }];
    UIAlertAction * cancelaction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * textField) {
        textField.placeholder = @"Node value";
        [textField addTarget:self action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    okaction1.enabled = false;
    [alert addAction:okaction1];
    [alert addAction:cancelaction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) redrawOptions {
    UIAlertController * actions = [UIAlertController alertControllerWithTitle:@"Redraw options" message:@"Select tree's view from the following" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * first = [UIAlertAction actionWithTitle:@"Classic view" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
        [Model setTreeDrawingStrategy:ClassicStrategy];
        [Model redrawTreeUsingStrategy:[Model getTreeDrawingStrategy]];
    }];
    UIAlertAction * third = [UIAlertAction actionWithTitle:@"Custom view" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
        [Model setTreeDrawingStrategy:CustomStrategy];
        [Model redrawTreeUsingStrategy:[Model getTreeDrawingStrategy]];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
    }];
    [actions addAction:first];
    [actions addAction:third];
    [actions addAction:cancel];
    actions.popoverPresentationController.sourceView = self.view;
    [self presentViewController:actions animated:YES completion:nil];
}

- (void) traversalOptions {
    UIAlertController * actions = [UIAlertController alertControllerWithTitle:@"Traversal options" message:@"Select tree's traversal algorithm or complete a test" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * bfs = [UIAlertAction actionWithTitle:@"Breadth-first search" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
        [Model initTreeTraversingVariables];
        [Model TreeBFS:[Model getTreeRoot]];
    }];
    UIAlertAction * dfs = [UIAlertAction actionWithTitle:@"Depth-first search" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
        [Model initTreeTraversingVariables];
        [Model TreeDFS:[Model getTreeRoot]];
    }];
    UIAlertAction * bfstest = [UIAlertAction actionWithTitle:@"BFS Test" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
        traversingtest = true;
        [Model prepareForTraversingTest];
        [Model TreeBFS:[Model getTreeRoot]];
    }];
    UIAlertAction * dfstest = [UIAlertAction actionWithTitle:@"DFS Test" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
        traversingtest = true;
        [Model prepareForTraversingTest];
        [Model TreeDFS:[Model getTreeRoot]];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [actions dismissViewControllerAnimated:YES completion:nil];
    }];
    [actions addAction:bfs];
    [actions addAction:dfs];
    [actions addAction:bfstest];
    [actions addAction:dfstest];
    [actions addAction:cancel];
    actions.popoverPresentationController.sourceView = self.view;
    [self presentViewController:actions animated:YES completion:nil];
}

@end
