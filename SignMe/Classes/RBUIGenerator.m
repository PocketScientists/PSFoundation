//
//  RBUIGenerator.m
//  SignMe
//
//  Created by Tretter Matthias on 25.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBUIGenerator.h"
#import "PSIncludes.h"
#import "UIControl+RBForm.h"
#import "RBRecipientsView.h"
#import "RBRecipient.h"
#import "RBClient+RBProperties.h"
#import "DocuSignService.h"
#import "RBTextField.h"

#define kRBLabelX                   30.f
#define kRBInputFieldPadding        30.f
#define kRBRowHeight                35.f
#define kRBRowPadding               11.f
#define kRBFormWidth                965.f

#define kRBFieldPositionBelow       @"below"
#define kRBFieldPositionRight       @"right"


#define stateList   [NSArray arrayWithObjects:@"Alabama", @"Alaska", @"Arizona", @"Arkansas", @"California", @"Colorado", @"Connecticut", @"Delaware", @"Florida", @"Georgia", @"Hawaii", @"Idaho", @"Illinois", @"Indiana", @"Iowa", @"Kansas", @"Kentucky", @"Louisiana", @"Maine", @"Maryland", @"Massachusetts", @"Michigan", @"Minnesota", @"Mississippi", @"Missouri", @"Montana", @"Nebraska", @"Nevada", @"New Hampshire", @"New Jersey", @"New Mexico", @"New York", @"North Carolina", @"North Dakota", @"Ohio", @"Oklahoma", @"Oregon", @"Pennsylvania", @"Rhode Island", @"South Carolina", @"South Dakota", @"Tennessee", @"Texas", @"Utah", @"Vermont", @"Virginia", @"Washington", @"West Virginia", @"Wisconsin", @"Wyoming", nil]

#define countryList [NSArray arrayWithObjects:@"Afghanistan", \
    @"Åland Islands", \
    @"Albania", \
    @"Algeria", \
    @"American Samoa", \
    @"Andorra", \
    @"Angola", \
    @"Anguilla", \
    @"Antarctica", \
    @"Antigua And Barbuda", \
    @"Argentina", \
    @"Armenia", \
    @"Aruba", \
    @"Australia", \
    @"Austria", \
    @"Azerbaijan", \
    @"Bahamas", \
    @"Bahrain", \
    @"Bangladesh", \
    @"Barbados", \
    @"Belarus", \
    @"Belgium", \
    @"Belize", \
    @"Benin", \
    @"Bermuda", \
    @"Bhutan", \
    @"Bolivia", \
    @"Bosnia And Herzegovina", \
    @"Botswana", \
    @"Bouvet Island", \
    @"Brazil", \
    @"British Indian Ocean Territory", \
    @"Brunei Darussalam", \
    @"Bulgaria", \
    @"Burkina Faso", \
    @"Burundi", \
    @"Cambodia", \
    @"Cameroon", \
    @"Canada", \
    @"Cape Verde", \
    @"Cayman Islands", \
    @"Central African Republic", \
    @"Chad", \
    @"Chile", \
    @"China", \
    @"Christmas Island", \
    @"Cocos (keeling) Islands", \
    @"Colombia", \
    @"Comoros", \
    @"Congo", \
    @"Congo, The Democratic Republic Of The", \
    @"Cook Islands", \
    @"Costa Rica", \
    @"CÔte D'ivoire", \
    @"Croatia", \
    @"Cuba", \
    @"Cyprus", \
    @"Czech Republic", \
    @"Denmark", \
    @"Djibouti", \
    @"Dominica", \
    @"Dominican Republic", \
    @"Ecuador", \
    @"Egypt", \
    @"El Salvador", \
    @"Equatorial Guinea", \
    @"Eritrea", \
    @"Estonia", \
    @"Ethiopia", \
    @"Falkland Islands (malvinas)", \
    @"Faroe Islands", \
    @"Fiji", \
    @"Finland", \
    @"France", \
    @"French Guiana", \
    @"French Polynesia", \
    @"French Southern Territories", \
    @"Gabon", \
    @"Gambia", \
    @"Georgia", \
    @"Germany", \
    @"Ghana", \
    @"Gibraltar", \
    @"Greece", \
    @"Greenland", \
    @"Grenada", \
    @"Guam", \
    @"Guatemala", \
    @"Guernsey", \
    @"Guinea", \
    @"Guinea-bissau", \
    @"Guyana", \
    @"Haiti", \
    @"Heard Island And Mcdonald Islands", \
    @"Holy See (vatican City State)", \
    @"Honduras", \
    @"Hong Kong", \
    @"Hungary", \
    @"Iceland", \
    @"India", \
    @"Indonesia", \
    @"Iran, Islamic Republic Of", \
    @"Iraq", \
    @"Ireland", \
    @"Isle Of Man", \
    @"Israel", \
    @"Italy", \
    @"Jamaica", \
    @"Japan", \
    @"Jersey", \
    @"Jordan", \
    @"Kazakhstan", \
    @"Kenya", \
    @"Kiribati", \
    @"Korea, Democratic People's Republic Of", \
    @"Korea, Republic Of", \
    @"Kuwait", \
    @"Kyrgyzstan", \
    @"Lao People's Democratic Republic", \
    @"Latvia", \
    @"Lebanon", \
    @"Lesotho", \
    @"Liberia", \
    @"Libyan Arab Jamahiriya", \
    @"Liechtenstein", \
    @"Lithuania", \
    @"Luxembourg", \
    @"Macao", \
    @"Macedonia, The Former Yugoslav Republic Of", \
    @"Madagascar", \
    @"Malawi", \
    @"Malaysia", \
    @"Maldives", \
    @"Mali", \
    @"Malta", \
    @"Marshall Islands", \
    @"Martinique", \
    @"Mauritania", \
    @"Mauritius", \
    @"Mayotte", \
    @"Mexico", \
    @"Micronesia, Federated States Of", \
    @"Moldova", \
    @"Monaco", \
    @"Mongolia", \
    @"Montserrat", \
    @"Morocco", \
    @"Mozambique", \
    @"Myanmar", \
    @"Namibia", \
    @"Nauru", \
    @"Nepal", \
    @"Netherlands", \
    @"Netherlands Antilles", \
    @"New Caledonia", \
    @"New Zealand", \
    @"Nicaragua", \
    @"Niger", \
    @"Nigeria", \
    @"Niue", \
    @"Norfolk Island", \
    @"Northern Mariana Islands", \
    @"Norway", \
    @"Oman", \
    @"Pakistan", \
    @"Palau", \
    @"Palestinian Territory, Occupied", \
    @"Panama", \
    @"Papua New Guinea", \
    @"Paraguay", \
    @"Peru", \
    @"Philippines", \
    @"Pitcairn", \
    @"Poland", \
    @"Portugal", \
    @"Puerto Rico", \
    @"Qatar", \
    @"RÉunion", \
    @"Romania", \
    @"Russian Federation", \
    @"Rwanda", \
    @"Saint Helena", \
    @"Saint Kitts And Nevis", \
    @"Saint Lucia", \
    @"Saint Pierre And Miquelon", \
    @"Saint Vincent And The Grenadines", \
    @"Samoa", \
    @"San Marino", \
    @"Sao Tome And Principe", \
    @"Saudi Arabia", \
    @"Senegal", \
    @"Seychelles", \
    @"Sierra Leone", \
    @"Singapore", \
    @"Slovakia", \
    @"Slovenia", \
    @"Solomon Islands", \
    @"Somalia", \
    @"South Africa", \
    @"South Georgia And The South Sandwich Islands", \
    @"Spain", \
    @"Sri Lanka", \
    @"Sudan", \
    @"Suriname", \
    @"Svalbard And Jan Mayen", \
    @"Swaziland", \
    @"Sweden", \
    @"Switzerland", \
    @"Syrian Arab Republic", \
    @"Taiwan, Province Of China", \
    @"Tajikistan", \
    @"Tanzania, United Republic Of", \
    @"Thailand", \
    @"Timor-leste", \
    @"Togo", \
    @"Tokelau", \
    @"Tonga", \
    @"Trinidad And Tobago", \
    @"Tunisia", \
    @"Turkey", \
    @"Turkmenistan", \
    @"Turks And Caicos Islands", \
    @"Tuvalu", \
    @"Uganda", \
    @"Ukraine", \
    @"United Arab Emirates", \
    @"United Kingdom", \
    @"United States", \
    @"Uruguay", \
    @"Uzbekistan", \
    @"Vanuatu", \
    @"Venezuela", \
    @"Viet Nam", \
    @"Virgin Islands, British", \
    @"Virgin Islands, U.s.", \
    @"Wallis And Futuna", \
    @"Western Sahara", \
    @"Yemen", \
    @"Zambia", \
    @"Zimbabwe", \
    nil]


@interface RBUIGenerator ()

@property (nonatomic, assign) RBTextField *previousTextField;

- (UILabel *)labelWithText:(NSString *)text;
- (UILabel *)titleLabelWithText:(NSString *)text;
- (UIControl *)inputFieldWithID:(NSString *)fieldID value:(NSString *)value datatype:(NSString *)datatype width:(CGFloat)width subtype:(NSString *)subtype;

- (void)createNextResponderChainWithControl:(UIControl *)control inView:(RBFormView *)view;

@end

@implementation RBUIGenerator

@synthesize previousTextField = previousTextField_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RBUIGenerator
////////////////////////////////////////////////////////////////////////

- (RBFormView *)viewWithFrame:(CGRect)frame form:(RBForm *)form client:(RBClient *)client document:(RBDocument *)document {
    RBFormView *view = [[[RBFormView alloc] initWithFrame:frame] autorelease];
    UIView *topLabel = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kRBRowHeight)] autorelease];
    UIView *topInputField = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kRBRowHeight)] autorelease];
    CGFloat realViewWidth = [[UIScreen mainScreen] applicationFrame].size.height; // Because of landscape we have to switch width/height
    CGFloat realViewHeight = view.bounds.size.width;
    CGFloat maxHeight = realViewHeight;
    NSInteger numberOfPages = form.numberOfSections + 1; // +1 for RecipientsView
    
    // iterate over all sections
    for (NSUInteger section=0;section < form.numberOfSections; section++) {
        // position top views on corresponding page of scrollView
        topLabel.frameTop =  - kRBRowHeight - kRBRowPadding;
        topLabel.frameLeft = kRBLabelX + section * realViewWidth;
        topInputField.frameTop =  - kRBRowHeight - kRBRowPadding;
        
        // a new section starts with a new "first" textfield
        self.previousTextField = nil;
        
        // add a section label to the page
        NSString *sectionTitleText = [form displayNameOfSection:section];
        if (sectionTitleText) {
            UILabel *sectionTitle = [self titleLabelWithText:sectionTitleText];
            [sectionTitle positionUnderView:topLabel padding:kRBRowPadding alignment:MTUIViewAlignmentLeftAligned];
            [view.innerScrollView addSubview:sectionTitle];
            
            // set new frames for anchor-views
            topLabel.frame = sectionTitle.frame;
            topInputField.frame = sectionTitle.frame;
            
        }

        for (NSUInteger subsection=0; subsection < [form numberOfSubsectionsInSection:section]; subsection++) {
            topLabel.frameLeft = kRBLabelX + section * realViewWidth;

            // add a section label to the page
            NSString *subSectionTitleText = [form displayNameOfSubsection:subsection inSection:section];
            if (subSectionTitleText) {
                UILabel *subSectionTitle = [self titleLabelWithText:subSectionTitleText];
                [subSectionTitle positionUnderView:topLabel padding:kRBRowPadding alignment:MTUIViewAlignmentLeftAligned];
                [view.innerScrollView addSubview:subSectionTitle];
                
                // set new frames for anchor-views
                topLabel.frame = subSectionTitle.frame;
                topInputField.frame = subSectionTitle.frame;
            }
            
            NSArray *fieldIDs = [form fieldIDsOfSubsection:subsection inSection:section];
            
            // iterate over all fields in the section
            for (NSString *fieldID in fieldIDs) {
                // get values
                NSString *labelText = [form valueForKey:kRBFormKeyLabel ofField:fieldID inSection:section];
                NSString *value = [form valueForKey:kRBFormKeyValue ofField:fieldID inSection:section];
                NSString *datatype = [form valueForKey:kRBFormKeyDatatype ofField:fieldID inSection:section];
                NSString *sizeString = [form valueForKey:kRBFormKeySize ofField:fieldID inSection:section];
                NSString *position = [form valueForKey:kRBFormKeyPosition ofField:fieldID inSection:section];
                NSString *subtype = [form valueForKey:kRBFormKeySubtype ofField:fieldID inSection:section];
                float size = sizeString == nil ? 1.0 : [sizeString floatValue];
                position = position == nil ? kRBFieldPositionBelow : position;
                
                // match values for client if there is no value set
                if (IsEmpty(value)) {
                    for (NSString *mapping in [RBClient propertyNamesForMapping]) {
                        if ([form fieldWithID:fieldID inSection:section matches:mapping]) {
                            value = [client valueForKey:mapping];
                        }
                    }
                }
                
                // create label and input field
                UILabel *label = [self labelWithText:labelText];
                UIControl *inputField = [self inputFieldWithID:fieldID value:value datatype:datatype width:kRBFormWidth * size - label.frameRight - kRBInputFieldPadding subtype:subtype];
                CGFloat heightDiff = kRBRowHeight - inputField.frameHeight; // Switch = 27 pt, TextField = 31 pt
                
                if ([inputField isKindOfClass:[RBTextField class]] && [subtype isEqualToString:@"list"]) {
                    NSString *listID = [form valueForKey:kRBFormKeyListID ofField:fieldID inSection:section];
                    if ([listID isEqualToString:@"states"]) {
                        ((RBTextField *)inputField).items = stateList;
                    }
                    else if ([listID isEqualToString:@"countries"]) {
                        ((RBTextField *)inputField).items = countryList;
                    }
                    else {
                        ((RBTextField *)inputField).items = [form listForID:listID];
                    }
                }
                
                inputField.formSection = section;
                
                // Setup chain to go from one textfield to the next
                [self createNextResponderChainWithControl:inputField inView:view];
                
                if ([position isEqualToString:kRBFieldPositionRight]) {
                    // position in Grid depending on anchor-views
                    label.frameTop = topLabel.frameTop;
                    label.frameLeft = topInputField.frameRight + kRBInputFieldPadding;
                    inputField.frameTop = topInputField.frameTop;
                    inputField.frameLeft = label.frameRight + kRBInputFieldPadding;
                    inputField.frameWidth -= kRBInputFieldPadding;
                }
                else {
                    topLabel.frameLeft = kRBLabelX + section * realViewWidth;

                    // position in Grid depending on anchor-views
                    [label positionUnderView:topLabel padding:kRBRowPadding alignment:MTUIViewAlignmentLeftAligned];
                    inputField.frameLeft = label.frameRight + kRBInputFieldPadding;
                    [inputField positionUnderView:topInputField padding:(kRBRowPadding + heightDiff/2.f) alignment:MTUIViewAlignmentUnchanged];
                }
                [view.innerScrollView addSubview:label];
                [view.innerScrollView addSubview:inputField];
                
                // set new frames for anchor-views
                topLabel.frame = label.frame;
                topInputField.frame = inputField.frame;
                topInputField.frameTop += heightDiff/2.f;
                
                maxHeight = MAX(maxHeight, topInputField.frameBottom);
            }
        }
    }
    
    // Add RecipientsView
    RBRecipientsView *recipientsView = [[[RBRecipientsView alloc] initWithFrame:CGRectMake(form.numberOfSections*realViewWidth, 0.f, 1024.f, 475.f)] autorelease];
    
    for (RBRecipient *recipient in [document.recipients allObjects]) {
        NSDictionary *dictionaryRepresentation = [recipient dictionaryWithValuesForKeys:XARRAY(kRBRecipientPersonID, kRBRecipientEmailID)];
        [recipientsView.recipients addObject:dictionaryRepresentation];
    }
    
    recipientsView.maxNumberOfRecipients = form.numberOfRecipients;
    recipientsView.subject = document.subject;
    
    [view.innerScrollView addSubview:recipientsView];
    
    // update pageControl on view (isn't displayed yet, because it is not a subview of the scrollView)
    view.pageControl.numberOfPages = numberOfPages;
    
    // enable vertical scrolling
    [view setInnerScrollViewSize:CGSizeMake(realViewWidth*numberOfPages, maxHeight)];
    view.contentSize = CGSizeMake(realViewWidth, maxHeight + 10.f);
    
    return view;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (UILabel *)labelWithText:(NSString *)text {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000.f, kRBRowHeight)] autorelease];
    
    label.autoresizingMask = UIViewAutoresizingNone;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = kRBColorMain;
    label.font = [UIFont fontWithName:kRBFontName size:16];
    label.textAlignment = UITextAlignmentLeft;
    label.text = text;
    [label sizeToFit];
    label.frameHeight = kRBRowHeight;
    
    return label;
}

- (UILabel *)titleLabelWithText:(NSString *)text {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000.f, kRBRowHeight)] autorelease];
    
    label.autoresizingMask = UIViewAutoresizingNone;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = kRBColorDetail;
    label.font = [UIFont fontWithName:kRBFontName size:20];
    label.textAlignment = UITextAlignmentLeft;
    label.text = [text uppercaseString];
    [label sizeToFit];
    label.frameHeight = kRBRowHeight + 10.0f;
    
    return label;
}

- (UIControl *)inputFieldWithID:(NSString *)fieldID value:(NSString *)value datatype:(NSString *)datatype width:(CGFloat)width subtype:(NSString *)subtype {
    UIControl *control = [UIControl controlWithID:fieldID datatype:datatype size:CGSizeMake(width, kRBRowHeight) subtype:subtype];
    
    [control configureControlUsingValue:value];
    
    return control;
}

- (void)createNextResponderChainWithControl:(UIControl *)control inView:(RBFormView *)view {
    if ([control isKindOfClass:[RBTextField class]]) {
        RBTextField *textField = (RBTextField *)control;
        
        textField.delegate = view;
        
        if (![textField.subtype isEqualToString:@"list"] &&
            ![textField.subtype isEqualToString:@"date"] &&
            ![textField.subtype isEqualToString:@"datetime"] &&
            ![textField.subtype isEqualToString:@"time"] ) {
            self.previousTextField.nextField = (UITextField *)control;
            self.previousTextField = textField;
        }
    }
}

@end
