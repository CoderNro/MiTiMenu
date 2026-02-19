#import <UIKit/UIKit.h>

// ─────────────────────────────────────────
//  MiTi Menu — Floating Overlay
// ─────────────────────────────────────────

@interface MiTiMenuView : UIView
@property (nonatomic, strong) UIButton *floatButton;
- (void)showMenu;
@end

@interface MiTiMenuView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIView      *overlay;
@property (nonatomic, strong) UIView      *card;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *links;
@end

@implementation MiTiMenuView

- (instancetype)init {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (!self) return nil;

    self.userInteractionEnabled = YES;
    self.windowLevel = UIWindowLevelAlert + 100;

    // ── Links ──
    self.links = @[
        @{ @"icon": @"🎬", @"title": @"YouTube — MiTi",  @"url": @"https://www.youtube.com/@ymt139" },
        // Thêm link nhóm ở đây sau
    ];

    [self setupFloatButton];
    return self;
}

// ─── Nút nổi góc phải ───────────────────
- (void)setupFloatButton {
    self.floatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat size = 54;
    CGRect screen = [UIScreen mainScreen].bounds;
    self.floatButton.frame = CGRectMake(screen.size.width - size - 16,
                                        screen.size.height * 0.35,
                                        size, size);
    self.floatButton.layer.cornerRadius  = size / 2;
    self.floatButton.layer.masksToBounds = YES;
    self.floatButton.clipsToBounds       = YES;

    // Gradient background
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame  = self.floatButton.bounds;
    grad.colors = @[
        (__bridge id)[UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:1].CGColor,
        (__bridge id)[UIColor colorWithRed:0.55 green:0.10 blue:0.90 alpha:1].CGColor,
    ];
    grad.startPoint = CGPointMake(0, 0);
    grad.endPoint   = CGPointMake(1, 1);
    [self.floatButton.layer insertSublayer:grad atIndex:0];

    // Shadow
    self.floatButton.layer.shadowColor   = [UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:0.6].CGColor;
    self.floatButton.layer.shadowOffset  = CGSizeMake(0, 4);
    self.floatButton.layer.shadowRadius  = 10;
    self.floatButton.layer.shadowOpacity = 1;
    self.floatButton.layer.masksToBounds = NO;

    // Label "M"
    UILabel *lbl = [[UILabel alloc] initWithFrame:self.floatButton.bounds];
    lbl.text          = @"M";
    lbl.textColor     = [UIColor whiteColor];
    lbl.font          = [UIFont boldSystemFontOfSize:22];
    lbl.textAlignment = NSTextAlignmentCenter;
    [self.floatButton addSubview:lbl];

    [self.floatButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];

    // Drag gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragButton:)];
    [self.floatButton addGestureRecognizer:pan];

    [self addSubview:self.floatButton];
}

- (void)dragButton:(UIPanGestureRecognizer *)pan {
    CGPoint delta = [pan translationInView:self];
    CGPoint center = self.floatButton.center;
    self.floatButton.center = CGPointMake(center.x + delta.x, center.y + delta.y);
    [pan setTranslation:CGPointZero inView:self];
}

// ─── Hiện menu ──────────────────────────
- (void)showMenu {
    if (self.overlay) return;
    CGRect screen = [UIScreen mainScreen].bounds;

    // Dimmed background
    self.overlay = [[UIView alloc] initWithFrame:screen];
    self.overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)];
    [self.overlay addGestureRecognizer:tap];
    [self insertSubview:self.overlay belowSubview:self.floatButton];

    // Card
    CGFloat cardW = MIN(screen.size.width - 40, 340);
    CGFloat cardH = 420;
    self.card = [[UIView alloc] initWithFrame:CGRectMake((screen.size.width - cardW)/2,
                                                          screen.size.height,
                                                          cardW, cardH)];
    self.card.layer.cornerRadius  = 24;
    self.card.layer.masksToBounds = NO;
    self.card.clipsToBounds       = YES;

    // Card gradient background
    CAGradientLayer *cardGrad = [CAGradientLayer layer];
    cardGrad.frame  = CGRectMake(0, 0, cardW, cardH);
    cardGrad.colors = @[
        (__bridge id)[UIColor colorWithRed:0.07 green:0.07 blue:0.15 alpha:0.98].CGColor,
        (__bridge id)[UIColor colorWithRed:0.10 green:0.10 blue:0.22 alpha:0.98].CGColor,
    ];
    cardGrad.startPoint = CGPointMake(0, 0);
    cardGrad.endPoint   = CGPointMake(1, 1);
    [self.card.layer insertSublayer:cardGrad atIndex:0];

    // Card shadow
    self.card.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.card.layer.shadowOffset  = CGSizeMake(0, 10);
    self.card.layer.shadowRadius  = 30;
    self.card.layer.shadowOpacity = 0.5;

    // ── Header ──
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cardW, 80)];

    // Header gradient line (top accent)
    CAGradientLayer *accentLine = [CAGradientLayer layer];
    accentLine.frame  = CGRectMake(0, 0, cardW, 3);
    accentLine.colors = @[
        (__bridge id)[UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:1].CGColor,
        (__bridge id)[UIColor colorWithRed:0.55 green:0.10 blue:0.90 alpha:1].CGColor,
    ];
    accentLine.startPoint = CGPointMake(0, 0);
    accentLine.endPoint   = CGPointMake(1, 0);
    [header.layer addSublayer:accentLine];

    // Avatar circle
    UIView *avatar = [[UIView alloc] initWithFrame:CGRectMake(20, 15, 46, 46)];
    avatar.layer.cornerRadius  = 23;
    avatar.layer.masksToBounds = YES;
    CAGradientLayer *avGrad = [CAGradientLayer layer];
    avGrad.frame  = avatar.bounds;
    avGrad.colors = @[
        (__bridge id)[UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:1].CGColor,
        (__bridge id)[UIColor colorWithRed:0.55 green:0.10 blue:0.90 alpha:1].CGColor,
    ];
    avGrad.startPoint = CGPointMake(0, 0);
    avGrad.endPoint   = CGPointMake(1, 1);
    [avatar.layer addSublayer:avGrad];

    UILabel *avLbl = [[UILabel alloc] initWithFrame:avatar.bounds];
    avLbl.text          = @"M";
    avLbl.textColor     = [UIColor whiteColor];
    avLbl.font          = [UIFont boldSystemFontOfSize:20];
    avLbl.textAlignment = NSTextAlignmentCenter;
    [avatar addSubview:avLbl];
    [header addSubview:avatar];

    // Name label
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(76, 18, cardW - 110, 22)];
    nameLbl.text      = @"MiTi";
    nameLbl.textColor = [UIColor whiteColor];
    nameLbl.font      = [UIFont boldSystemFontOfSize:18];
    [header addSubview:nameLbl];

    // Subtitle
    UILabel *subLbl = [[UILabel alloc] initWithFrame:CGRectMake(76, 42, cardW - 110, 18)];
    subLbl.text      = @"Menu Liên Kết";
    subLbl.textColor = [UIColor colorWithWhite:0.6 alpha:1];
    subLbl.font      = [UIFont systemFontOfSize:12];
    [header addSubview:subLbl];

    // Close button X
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(cardW - 44, 18, 32, 32);
    closeBtn.layer.cornerRadius  = 16;
    closeBtn.layer.masksToBounds = YES;
    closeBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [closeBtn addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:closeBtn];

    // Divider
    UIView *div = [[UIView alloc] initWithFrame:CGRectMake(20, 76, cardW - 40, 1)];
    div.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
    [header addSubview:div];

    [self.card addSubview:header];

    // ── TableView ──
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, cardW, cardH - 80)
                                                  style:UITableViewStylePlain];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled   = NO;
    [self.card addSubview:self.tableView];

    [self insertSubview:self.card aboveSubview:self.overlay];

    // ── Animate in ──
    [UIView animateWithDuration:0.08 animations:^{
        self.overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }];
    [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.card.frame = CGRectMake((screen.size.width - cardW)/2,
                                     (screen.size.height - cardH)/2,
                                     cardW, cardH);
    } completion:nil];
}

// ─── Đóng menu ──────────────────────────
- (void)closeMenu {
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat cardW = self.card.frame.size.width;
    CGFloat cardH = self.card.frame.size.height;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.card.frame = CGRectMake((screen.size.width - cardW)/2, screen.size.height, cardW, cardH);
        self.overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL done) {
        [self.card removeFromSuperview];
        [self.overlay removeFromSuperview];
        self.card      = nil;
        self.overlay   = nil;
        self.tableView = nil;
    }];
}

// ─── TableView ──────────────────────────
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s {
    return self.links.count;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)ip {
    return 68;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    // Clear subviews
    for (UIView *v in cell.contentView.subviews) [v removeFromSuperview];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle  = UITableViewCellSelectionStyleNone;

    NSDictionary *item = self.links[ip.row];
    CGFloat w = tv.frame.size.width;

    // Row card
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(16, 8, w - 32, 52)];
    row.layer.cornerRadius  = 14;
    row.layer.masksToBounds = YES;
    row.backgroundColor     = [UIColor colorWithWhite:1 alpha:0.05];
    [cell.contentView addSubview:row];

    // Icon circle
    UIView *iconBg = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 32, 32)];
    iconBg.layer.cornerRadius  = 16;
    iconBg.layer.masksToBounds = YES;
    CAGradientLayer *ig = [CAGradientLayer layer];
    ig.frame  = iconBg.bounds;
    ig.colors = @[
        (__bridge id)[UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:0.3].CGColor,
        (__bridge id)[UIColor colorWithRed:0.55 green:0.10 blue:0.90 alpha:0.3].CGColor,
    ];
    ig.startPoint = CGPointMake(0, 0);
    ig.endPoint   = CGPointMake(1, 1);
    [iconBg.layer addSublayer:ig];

    UILabel *iconLbl = [[UILabel alloc] initWithFrame:iconBg.bounds];
    iconLbl.text          = item[@"icon"];
    iconLbl.font          = [UIFont systemFontOfSize:16];
    iconLbl.textAlignment = NSTextAlignmentCenter;
    [iconBg addSubview:iconLbl];
    [row addSubview:iconBg];

    // Title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(52, 8, row.frame.size.width - 72, 20)];
    title.text      = item[@"title"];
    title.textColor = [UIColor whiteColor];
    title.font      = [UIFont boldSystemFontOfSize:14];
    [row addSubview:title];

    // URL
    UILabel *url = [[UILabel alloc] initWithFrame:CGRectMake(52, 28, row.frame.size.width - 72, 16)];
    url.text      = item[@"url"];
    url.textColor = [UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:0.8];
    url.font      = [UIFont systemFontOfSize:11];
    [row addSubview:url];

    // Arrow
    UILabel *arrow = [[UILabel alloc] initWithFrame:CGRectMake(row.frame.size.width - 24, 15, 20, 22)];
    arrow.text      = @"›";
    arrow.textColor = [UIColor colorWithWhite:0.4 alpha:1];
    arrow.font      = [UIFont boldSystemFontOfSize:20];
    [row addSubview:arrow];

    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip {
    NSDictionary *item = self.links[ip.row];
    NSURL *url = [NSURL URLWithString:item[@"url"]];
    if (url) [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end

// ─────────────────────────────────────────
//  Window host để overlay ở trên tất cả
// ─────────────────────────────────────────
@interface MiTiWindow : UIWindow
@end
@implementation MiTiWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    // Cho phép touch pass-through nếu không phải button/card
    if (hit == self) return nil;
    return hit;
}
@end

// ─────────────────────────────────────────
//  Constructor — chạy khi dylib load
// ─────────────────────────────────────────
static MiTiWindow   *gWindow;
static MiTiMenuView *gMenu;

__attribute__((constructor))
static void MiTiInit(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{

        UIWindowScene *scene = nil;
        for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
            if ([s isKindOfClass:[UIWindowScene class]]) {
                scene = (UIWindowScene *)s;
                break;
            }
        }

        gWindow = [[MiTiWindow alloc] initWithWindowScene:scene];
        gWindow.windowLevel         = UIWindowLevelAlert + 100;
        gWindow.backgroundColor     = [UIColor clearColor];
        gWindow.userInteractionEnabled = YES;

        gMenu = [[MiTiMenuView alloc] init];
        gWindow.rootViewController            = [[UIViewController alloc] init];
        gWindow.rootViewController.view.frame = [UIScreen mainScreen].bounds;
        [gWindow.rootViewController.view addSubview:gMenu];
        [gWindow makeKeyAndVisible];
    });
}
