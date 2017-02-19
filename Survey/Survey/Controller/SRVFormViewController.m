//
//  SRVFormViewController.m
//  Survey
//
//  Created by Joan Molinas Ramon on 11/2/17.
//  Copyright © 2017 NSBeard. All rights reserved.
//

#import "SRVFormViewController.h"
#import "FEZDatabaseConnector.h"

@interface SRVFormViewController ()
@property (nonatomic, strong) NSArray *questions;
@property (nonatomic, strong) FEZDatabaseConnector *questionsConnector;
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
    [self initConnector];
}

#pragma mark - Inits -
- (void)initialize {

    XLFormDescriptor *formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Lavanda Laundry"];
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Característiques"];
    
    for (int i = 0; i < self.questions.count; i++) {
        NSDictionary *rowDict = self.questions[i];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:[rowDict[@"tag"] stringValue] rowType:XLFormRowDescriptorTypeBooleanSwitch title:rowDict[@"question"]];
        row.value = [NSNumber numberWithBool:NO];
        [section addFormRow:row];
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"%lu", (unsigned long)self.questions.count] rowType:XLFormRowDescriptorTypeTextView title:@"Suggerències"];
    [section addFormRow:row];
    [formDescriptor addFormSection:section];
    self.form = formDescriptor;
}

- (void)initConnector {
    _questionsConnector = [FEZDatabaseConnector linkWithDatabaseName:@"question"];
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
    [self.questionsConnector send:[self formValues] withCompletionBlock:^(NSError * _Nullable error) {
        [self reset];
    }];
}
    
- (void)reset {
    [self.form.formSections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XLFormSectionDescriptor* sectionDescriptor = (XLFormSectionDescriptor*)obj;
        [sectionDescriptor.formRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            XLFormRowDescriptor* row = (XLFormRowDescriptor*)obj;
            if ([row.rowType isEqualToString:XLFormRowDescriptorTypeBooleanSwitch]) {
                row.value = [NSNumber numberWithBool:NO];
            } else if ([row.rowType isEqualToString:XLFormRowDescriptorTypeTextView]){
                row.value = @"";
            }
            [self reloadFormRow:row];
        }];
    }];
}
    
    

@end
