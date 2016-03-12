//
//  SmallThingTableViewCell.m
//  Small Things
//
//  Created by Leonardo S Rangel on 7/16/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//

#import "SmallThingTableViewCell.h"

@interface SmallThingTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end

@implementation SmallThingTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)configureCellWithTitle:(NSString *)title andSubtitle:(NSString *)subtitle {
    [_titleLabel setText:title];
    [_subtitleLabel setText:subtitle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
