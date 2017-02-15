//
//  SMAlertViewButton.h
//  SMAlertView
//
//  Created by WWLy on 13/02/2017.
//  Copyright © 2017 WWLy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMAlertViewButton : UIButton

typedef void (^SMActionBlock)(void);
typedef BOOL (^SMValidationBlock)(void);
typedef NSDictionary* (^CompleteButtonFormatBlock)(void);
typedef NSDictionary* (^ButtonFormatBlock)(void);

// Action Types
typedef NS_ENUM(NSInteger, SMActionType)
{
    SMNone,
    SMSelector,
    SMBlock
};

/** Set button action type.
 *
 * Holds the button action type.
 */
@property SMActionType actionType;

/** Set action button block.
 *
 * TODO
 */
@property (copy, nonatomic) SMActionBlock actionBlock;

/** Set Complete button format block.
 *
 * Holds the complete button format block.
 * Support keys : backgroundColor, borderWidth, borderColor, textColor
 */
@property (copy, nonatomic) CompleteButtonFormatBlock completeButtonFormatBlock;

/** Set button format block.
 *
 * Holds the button format block.
 * Support keys : backgroundColor, borderWidth, borderColor, textColor
 */
@property (copy, nonatomic) ButtonFormatBlock buttonFormatBlock;

/** Set SMButton color.
 *
 * Set SMButton color.
 */
@property (strong, nonatomic) UIColor *defaultBackgroundColor UI_APPEARANCE_SELECTOR;

/** Set Target object.
 *
 * Target is an object that holds the information necessary to send a message to another object when an event occurs.
 */
@property id target;

/** Set selector id.
 *
 * A selector is the name used to select a method to execute for an object,
 * or the unique identifier that replaces the name when the source code is compiled.
 */
@property SEL selector;

/** Parse button configuration
 *
 * Parse ButtonFormatBlock and CompleteButtonFormatBlock setting custom configuration.
 * Set keys : backgroundColor, borderWidth, borderColor, textColor
 */
- (void)parseConfig:(NSDictionary *)buttonConfig;

/** Init method
 *
 */
- (instancetype)initWithWindowWidth:(CGFloat)windowWidth;

/** Adjust width of the button according to the width of the alert and
 * the number of buttons. Only used when buttons are horizontally aligned.
 *
 * @param windowWidth The width of the alert.
 * @param numberOfButtons The number of buttons in the alert.
 */
- (void)adjustWidthWithWindowWidth:(CGFloat)windowWidth numberOfButtons:(NSUInteger)numberOfButtons;

@end
