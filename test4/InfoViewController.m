//
//  InfoViewController.m
//  test4
//
//  Created by Alex Riznychenko on 22.02.17.
//  Copyright © 2017 Alex Riznychenko. All rights reserved.
//

#import "InfoViewController.h"

@implementation InfoViewController

static NSString * help;
static NSString * theory;
static NSArray * questions;
static NSString * correct;
static UITextView * textView;
static int currentQuestion = 0;
static int result = 0;

- (instancetype)initWithSubject:(NSString *)subject {
    if (self = [super init]) {
        _contentType = subject;
    }
    return self;
}

- (instancetype)initWithTest {
    if (self = [super init]) {
        _contentType = @"Test";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:@"Dismiss" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.title = _contentType;
    [self getData]; 
    [self.view addSubview: [self textOnSubject:_contentType]];
}

- (void)getData {
    NSString * path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSString * jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error = nil;
    NSDictionary * object = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    if(!error) {
        if ([_contentType isEqualToString:@"Graph theory"]) {
            theory = [object objectForKey:@"theory"];
        }
        else if ([_contentType isEqualToString:@"Help"]) {
            help = [object objectForKey:@"help"];
        }
        else if ([_contentType isEqualToString:@"Test"]) {
            questions = [object objectForKey:@"questions"];
        }
    }
    else
        NSLog(@"Error in parsing JSON");
}

- (void) dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITextView *) textOnSubject: (NSString *)subject  {
    CGRect scrn = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    textView = [[UITextView alloc] initWithFrame:scrn];
    if ([subject  isEqual: @"Graph theory"]) {
        [textView setText:theory];
    }
    else if ([subject  isEqual: @"Help"]) {
        [textView setText:help];
    }
    else if ([subject  isEqual: @"Test"]) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ question %d/%lu", _contentType, currentQuestion+1, (unsigned long)questions.count];
        [textView setText:[questions[currentQuestion] objectForKey:@"question"]];
        [textView addSubview:[self button1]];
        [textView addSubview:[self button2]];
    }
    [textView setEditable:false];
    [textView setSelectable:false];
    [textView setFont:[UIFont systemFontOfSize:15]];
    return textView;
}

- (UIButton *) button1 {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(textView.bounds.origin.x, 400, 80, 30);
    [button setTitle:@"Answer 1" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(checkAnswer1:) forControlEvents:UIControlEventTouchDown];
    return button;
}

- (UIButton *) button2  {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(textView.bounds.size.width-85, 400, 80, 30);
    [button setTitle:@"Answer 2" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(checkAnswer2:) forControlEvents:UIControlEventTouchDown];
    
    return button;
}

- (void) checkAnswer1: (id)sender {
    if ([[questions[currentQuestion] objectForKey:@"correct answer"] intValue] == 1) {
        [self showResultAlert:YES ForAnswer:1];
        result++;
    }
    else
        [self showResultAlert:NO ForAnswer:1];
}

- (void) checkAnswer2: (id)sender {
    if ([[questions[currentQuestion] objectForKey:@"correct answer"] intValue] == 2) {
        [self showResultAlert:YES ForAnswer:2];
        result++;
    }
    else
        [self showResultAlert:NO ForAnswer:2];
}

- (void)showResultAlert: (BOOL)correct ForAnswer:(int)answer {
    NSString * currentResult;
    if (correct) {
        currentResult = @"Correct!";
    }
    else {
        currentResult = @"Incorrect!";
    }
    NSString * str;
    if (answer == 0)
        str = [NSString stringWithFormat:@"Test completed!\nYour result: %d out of %lu", result, (unsigned long)questions.count];
    else
        str = [NSString stringWithFormat:@"Your answer: %d\nYour result: %@", answer, currentResult];
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Result:" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelaction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (currentQuestion+1 <= [questions count]) {
            currentQuestion++;
            self.navigationItem.title = [NSString stringWithFormat:@"%@ question %d/%lu", _contentType, currentQuestion+1, (unsigned long)questions.count];
            if(currentQuestion < [questions count])
                [textView setText:[questions[currentQuestion] objectForKey:@"question"]];
        }
        ///после полного прохождения теста он кидает на второй вопрос вместо первого
        NSLog(@"count %lu", (unsigned long)[questions count]);
        if (currentQuestion == questions.count) {
            [self showResultAlert:YES ForAnswer:0];
            currentQuestion = 0;
            result = 0;
            [self textOnSubject:_contentType];
        }
        [alert dismissViewControllerAnimated:YES completion:nil];}];
    [alert addAction:cancelaction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
