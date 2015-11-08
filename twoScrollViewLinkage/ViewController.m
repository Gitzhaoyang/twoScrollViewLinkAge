//
//  ViewController.m
//  twoScrollViewLinkage
//
//  Created by mungo on 7/11/15.
//  Copyright © 2015 mungo. All rights reserved.
//

#import "ViewController.h"

//屏幕的宽和高
#define KSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define KSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
//最顶部状态栏的高度
#define KSTATUS_HEIGHT 20
//顶部items的scrollView的高度
#define KFIRST_SCROLLVIEW_HEIGHT 30
//根据计算，得到底部详情scrollView的高度
#define KSECOND_SCROLLVIEW_HEIGHT (KSCREEN_HEIGHT - KSTATUS_HEIGHT - KFIRST_SCROLLVIEW_HEIGHT)
//顶部scrollView每个item按钮的宽度
#define KFIRST_SCROLLVIEW_ITEM_WIDTH 55

@interface ViewController () <UIScrollViewDelegate>

//顶部items的scrollView
@property (nonatomic, weak) UIScrollView *firstScrollView;
//底部详情scrollView
@property (nonatomic, weak) UIScrollView *secondScrollView;
//顶部scrollView选中按钮的样式
@property (nonatomic, weak) UIImageView *selectedButtonImageView;
//item类型的数组
@property (nonatomic, strong) NSArray *itemsTitlesArray;
//为了方便，定义一个包含颜色的NSArray（自行取舍）
@property (nonatomic, strong) NSArray *colorArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addFirstScrollViewOnView];//添加顶部items的scrollView
    [self addSecondScrollViewOnView];//添加底部详情的scorllView
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy load
//定义items的标题
- (NSArray *) itemsTitlesArray {
    if (!_itemsTitlesArray) {
        _itemsTitlesArray = [NSArray arrayWithObjects:@"头条", @"科技", @"数码", @"热点", @"手机", @"社会", @"图片", @"直播", @"汽车", @"跟帖", @"军事", @"彩票", @"游戏", @"房产", nil];
    }
    
    return _itemsTitlesArray;
}
//颜色数组
- (NSArray *) colorArray {
    if (!_colorArray) {
        _colorArray = [NSArray arrayWithObjects:
                       [UIColor colorWithRed:240.0/255.0 green:89.0/255.0 blue:136.0/255.0 alpha:1.0],
                       [UIColor colorWithRed:0.0/255.0   green:179.0/255.0 blue:155.0/255.0 alpha:1.0],
                       [UIColor colorWithRed:244.0/255.0 green:131.0/255.0 blue:69.0/255.0 alpha:1.0],
                       [UIColor colorWithRed:241.0/255.0 green:90.0/255.0 blue:102.0/255.0 alpha:1.0],
                       [UIColor colorWithRed:0.0/255.0 green:179.0/255.0 blue:155.0/255.0 alpha:1.0],
                       [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:104.0/255.0 alpha:1.0],
                       nil];
    }
    
    return _colorArray;
}

#pragma mark - config the view
//添加第一个scrollview
- (void) addFirstScrollViewOnView {
    //**1.设置顶部类型scrollView
    UIScrollView *firstScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, KSTATUS_HEIGHT, KSCREEN_WIDTH, KFIRST_SCROLLVIEW_HEIGHT)];
    firstScrollView.bounces = NO;//禁止反弹
    firstScrollView.showsHorizontalScrollIndicator = NO;//禁止显示水平滚动条
    //设置scrollView的内容大小，宽度为 宏定义顶部按钮的宽度 ＊ items数组的数量
    firstScrollView.contentSize = CGSizeMake(self.itemsTitlesArray.count * KFIRST_SCROLLVIEW_ITEM_WIDTH, KFIRST_SCROLLVIEW_HEIGHT);
    self.firstScrollView = firstScrollView;
    [self.view addSubview:firstScrollView];//添加到self.view

    //**2.为第一个scrollView添加buttons
    for (int i = 0; i < self.itemsTitlesArray.count; i ++) {
        UIButton *itemButton = [[UIButton alloc] initWithFrame:CGRectMake(i * KFIRST_SCROLLVIEW_ITEM_WIDTH, 0, KFIRST_SCROLLVIEW_ITEM_WIDTH, KFIRST_SCROLLVIEW_HEIGHT)];//注意左边距的写法
        [itemButton setTitle:[self.itemsTitlesArray objectAtIndex:i] forState:UIControlStateNormal];//标题
        itemButton.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];//背景颜色
        [itemButton setTitleColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0] forState:UIControlStateNormal];//标题颜色
        itemButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [firstScrollView addSubview:itemButton];//添加到第一个scrollView
        
        //定义第一个顶部item的按钮样式
        if (i == 0) {
            itemButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            [itemButton setTitleColor:[UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0f] forState:UIControlStateNormal];
        }
        
        itemButton.tag = 100 + i;
        [itemButton addTarget:self action:@selector(itemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

//添加第二个scrollview
- (void) addSecondScrollViewOnView {
    //**1.设置底部详情scrollView
    UIScrollView *secondScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, KSTATUS_HEIGHT + KFIRST_SCROLLVIEW_HEIGHT, KSCREEN_WIDTH, KSECOND_SCROLLVIEW_HEIGHT)];
    secondScrollView.pagingEnabled = YES;//分页
    secondScrollView.bounces = NO;//禁止反弹
    secondScrollView.delegate = self;
    //设置内容大小，宽度为 屏幕的宽度 * items数组的数量
    secondScrollView.contentSize = CGSizeMake(self.itemsTitlesArray.count * KSCREEN_WIDTH, KSECOND_SCROLLVIEW_HEIGHT);
    self.secondScrollView = secondScrollView;
    [self.view addSubview:secondScrollView];
    //**2.添加Views
    for (int i = 0; i < self.itemsTitlesArray.count; i ++) {
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(i * KSCREEN_WIDTH, 0, KSCREEN_WIDTH, KSECOND_SCROLLVIEW_HEIGHT)];
        bottomView.backgroundColor = [self.colorArray objectAtIndex:(i % 6)];
        //为了方便观察，放置一个label，如果需要其它控件自行替换（如若新闻，用tableView）
        UILabel *flagLabel = [[UILabel alloc] initWithFrame:bottomView.bounds];
        flagLabel.font = [UIFont systemFontOfSize:50.0f];
        flagLabel.textColor = [UIColor whiteColor];
        flagLabel.textAlignment = NSTextAlignmentCenter;
        flagLabel.text = [NSString stringWithFormat:@"%@", [self.itemsTitlesArray objectAtIndex:i]];
        [bottomView addSubview:flagLabel];
        
        [secondScrollView addSubview:bottomView];
    }
}

#pragma mark - item button clicked 

- (void) itemButtonClicked:(UIButton *)button {
    NSInteger buttonTag = button.tag - 100;
    [UIView animateWithDuration:0.3 animations:^{
        self.selectedButtonImageView.center = button.center;
        self.secondScrollView.contentOffset = CGPointMake(buttonTag * KSCREEN_WIDTH, 0);
    }];
   
}

#pragma mark - scrollView delegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    //移动顶部选中的按钮
    CGFloat secondScrollViewContentOffsetX = scrollView.contentOffset.x - 1;
    //获取选中按钮的序号
    int buttonTag = (secondScrollViewContentOffsetX) / KSCREEN_WIDTH;
   
//    CGFloat fingerDistance = secondScrollViewContentOffsetX - KSCREEN_WIDTH * buttonTag;
//    NSLog(@"%f",fingerDistance);
//    UIButton *buttonNext = (UIButton *)[self.view viewWithTag:(buttonTag + 100 + 1)];
//    buttonNext.titleLabel.font = [UIFont systemFontOfSize:(14.0 + fingerDistance * 2 / 160.0)];
//    [buttonNext setTitleColor:[UIColor colorWithRed:(0.4f + 3 * fingerDistance / 1600) green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
//    UIButton *buttonCurr = (UIButton *)[self.view viewWithTag:(buttonTag + 100)];
//    buttonCurr.titleLabel.font = [UIFont systemFontOfSize:(18.0 - fingerDistance * 2 / 160.0)];
//    [buttonCurr setTitleColor:[UIColor colorWithRed:(1.0f - 3 * fingerDistance / 1600) green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
//
////    NSLog(@"%f", secondScrollViewContentOffsetX);
//    
//    //判断左滑还是右划
//    static float newx = 0;
//    static float oldx = 0;
//    newx = secondScrollViewContentOffsetX;
//    if (newx != oldx) {
//        if (newx > oldx) {
//             NSLog(@"右划 %d", buttonTag);
//        } else {
//            NSLog(@"左滑 %d", buttonTag);
//        }
//        
//        oldx = newx;
//    }
}


@end
