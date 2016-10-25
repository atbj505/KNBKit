//
//  KNBScaleImageCell.m
//  KenuoTraining
//
//  Created by Robert on 16/3/10.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "KNBScaleImageCell.h"

@implementation KNBScaleImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.scaleImage = [[KNBScaleImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.scaleImage];
    }
    return self;
}

@end
