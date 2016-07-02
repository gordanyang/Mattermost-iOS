//
//  KGChatCommonTableViewCell.m
//  Mattermost
//
//  Created by Igor Vedeneev on 14.06.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

#import "KGChatCommonTableViewCell.h"
#import <Masonry/Masonry.h>
#import "UIFont+KGPreparedFont.h"
#import "UIColor+KGPreparedColor.h"
#import <ActiveLabel/ActiveLabel-Swift.h>
#import "KGPost.h"
#import "KGUser.h"
#import "NSDate+DateFormatter.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "NSString+HeightCalculation.h"
#import "UIImage+Resize.h"
#import "KGPreferences.h"

@interface KGChatCommonTableViewCell ()

@end

@implementation KGChatCommonTableViewCell

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setup];
        [self setupAvatarImageView];
        [self setupNameLabel];
        [self setupDateLabel];
        [self setupMessageLabel];
    }
    
    return self;
}

+ (void)load {
    messageQueue = [[NSOperationQueue alloc] init];
    [messageQueue setMaxConcurrentOperationCount:1];
}


#pragma mark - Setup

- (void)setup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setupAvatarImageView {
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 40, 40)];
    self.avatarImageView.backgroundColor = [UIColor whiteColor];
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.avatarImageView];
}

- (void)setupNameLabel {
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.nameLabel.numberOfLines = 1;
    self.nameLabel.backgroundColor = [UIColor whiteColor];
    self.nameLabel.font = [UIFont kg_semibold16Font];
    self.nameLabel.textColor = [UIColor kg_blackColor];
    [self addSubview:self.nameLabel];
}

- (void)setupDateLabel {
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.dateLabel.numberOfLines = 1;
    self.dateLabel.backgroundColor = [UIColor whiteColor];
    self.dateLabel.font = [UIFont kg_regular13Font];
    self.dateLabel.textColor = [UIColor kg_lightGrayColor];
    [self addSubview:self.dateLabel];
}

- (void)setupMessageLabel {
    self.messageLabel = [[ActiveLabel alloc] init];
    self.messageLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.backgroundColor = [UIColor whiteColor];
    self.messageLabel.font = [UIFont kg_regular15Font];
    self.messageLabel.textColor = [UIColor kg_blackColor];
    [self addSubview:self.messageLabel];
    
    [self.messageLabel setURLColor:[UIColor kg_blueColor]];
    [self.messageLabel setURLSelectedColor:[UIColor blueColor]];
    [self.messageLabel setMentionSelectedColor:[UIColor blueColor]];
    [self.messageLabel setHashtagColor:[UIColor kg_greenColorForAlert]];
    [self.messageLabel setMentionColor:[UIColor kg_blueColor]];
    
    self.messageLabel.layer.shouldRasterize = YES;
    self.messageLabel.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.messageLabel.layer.drawsAsynchronously = YES;

    self.messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.messageLabel.preferredMaxLayoutWidth = 200.f;

    [self.messageLabel handleMentionTap:^(NSString *string) {
        self.mentionTapHandler(string);
    }];
    [self.messageLabel handleURLTap:^(NSURL *url) {
        [[UIApplication sharedApplication] openURL:url];
    }];
}


#pragma mark - Configuration

- (void)configureWithObject:(id)object {
    if ([object isKindOfClass:[KGPost class]]) {
        self.post = object;
        
        __weak typeof(self) wSelf = self;
        
        self.messageOperation = [[NSBlockOperation alloc] init];
        [self.messageOperation addExecutionBlock:^{
            if (!wSelf.messageOperation.isCancelled) {
                dispatch_sync(dispatch_get_main_queue(), ^(void){
                    wSelf.messageLabel.attributedText = wSelf.post.attributedMessage;
              });
            }
        }];
        [messageQueue addOperation:self.messageOperation];
        
        self.nameLabel.text = _post.author.nickname;
        _dateString = [_post.createdAt timeFormatForMessages];
        self.dateLabel.text = _dateString;
        
        UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.post.author.imageUrl.absoluteString];
        if (cachedImage) {
            wSelf.avatarImageView.image = KGRoundedImage(cachedImage, CGSizeMake(40, 40));
        } else {
            [self.avatarImageView setImageWithURL:self.post.author.imageUrl
                                 placeholderImage:KGRoundedPlaceholderImage(CGSizeMake(40.f, 40.f))
                                          options:SDWebImageHandleCookies
                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                            wSelf.avatarImageView.image = KGRoundedImage(image, CGSizeMake(40, 40));
                                        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [self.avatarImageView removeActivityIndicator];
        }
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat textWidth = KGScreenWidth() - 61.f;
    self.backgroundColor = [UIColor kg_whiteColor];
    self.messageLabel.backgroundColor = [UIColor greenColor];
    
    CGFloat nameWidth = [[self class] widthOfString:self.post.author.nickname withFont:[UIFont kg_semibold16Font]];
    CGFloat timeWidth = [[self class] widthOfString:_dateString withFont:[UIFont kg_regular13Font]];
    self.messageLabel.frame = CGRectMake(53, 36, ceilf(textWidth), self.post.heightValue);
    self.nameLabel.frame = CGRectMake(53, 8, nameWidth, 20);
    self.dateLabel.frame = CGRectMake(_nameLabel.frame.origin.x + nameWidth + 5, 8, ceilf(timeWidth), 20);
}

+ (CGFloat)heightWithObject:(id)object {
    KGPost *adapter = object;
    return adapter.heightValue + 24 + 20;
}


+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    if (string) {
        NSDictionary *attributes = @{ NSFontAttributeName : font };
        return  ceilf([[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width);
    }
    
    return 0.00001;
}


- (void)prepareForReuse {
    _avatarImageView.image = KGRoundedPlaceholderImage(CGSizeMake(40.f, 40.f));
    _messageLabel.text = nil;
    [_messageOperation cancel];
}


@end
