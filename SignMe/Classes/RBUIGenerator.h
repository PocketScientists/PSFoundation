//
//  RBUIGenerator.h
//  SignMe
//
//  Created by Tretter Matthias on 25.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RBFormView.h"
#import "RBForm.h"
#import "RBClient.h"
#import "RBDocument.h"

@interface RBUIGenerator : NSObject

- (RBFormView *)viewWithFrame:(CGRect)frame form:(RBForm *)form client:(RBClient *)client document:(RBDocument *)document;
+ (void)resizeFormView:(RBFormView *)formView withForm:(RBForm *)form;

@end

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

