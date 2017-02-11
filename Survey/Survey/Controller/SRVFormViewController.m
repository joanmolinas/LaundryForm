//
//  SRVFormViewController.m
//  Survey
//
//  Created by Joan Molinas Ramon on 11/2/17.
//  Copyright © 2017 NSBeard. All rights reserved.
//

#import "SRVFormViewController.h"

@interface SRVFormViewController ()
@property (nonatomic, strong) NSArray *questions;
@end

@implementation SRVFormViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadQuestions];
        [self initialize];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadQuestions];
        [self initialize];
    }
    
    return self;
}

    
    
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Inits -
- (void)initialize {

    XLFormDescriptor *formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Lavanda Laundry"];
    formDescriptor.assignFirstResponderOnShow = YES;
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Viabilitat app"];
    
    for (int i = 0; i < self.questions.count; i++) {
        NSDictionary *rowDict = self.questions[i];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:[rowDict[@"tag"] stringValue] rowType:XLFormRowDescriptorTypeBooleanSwitch title:rowDict[@"question"]];
        row.value = @(0);
        [section addFormRow:row];
    }
    
    [formDescriptor addFormSection:section];
    self.form = formDescriptor;
}
    
#pragma mark - JSON - 
- (void)loadQuestions {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Questions" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    self.questions = json[@"questions"];
    
}
#pragma mark - Actions -
- (IBAction)save:(UIBarButtonItem *)sender {
    NSLog(@"%@", [self formValues]);
    [self reset];
    
}
    
- (void)reset {
    [self.form.formSections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XLFormSectionDescriptor* sectionDescriptor = (XLFormSectionDescriptor*)obj;
        [sectionDescriptor.formRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            XLFormRowDescriptor* row = (XLFormRowDescriptor*)obj;
            row.value = @(0);
            [self reloadFormRow:row];
        }];
    }];
}
    
    

@end
